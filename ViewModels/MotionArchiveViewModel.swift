//
//  MotionArchiveViewModel.swift
//  YukDebatCuyy
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

/// Manages fetching random motions and synchronizing user case building notes with Firestore.
class MotionArchiveViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var motionsList: [MotionModel] = []
    @Published var searchText: String = ""
    @Published var myNotes: [CaseBuildingNoteModel] = []
    @Published var communityNotes: [CaseBuildingNoteModel] = []
    @Published var isGenerating: Bool = false

    // MARK: - Computed Properties

    var filteredMotions: [MotionModel] {
        if searchText.isEmpty { return motionsList }
        return motionsList.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Private Properties

    private let apiProxy: CloudFunctionsProtocol
    private let localCache: CoreDataStorageProtocol

    // MARK: - Initialization

    init(apiProxy: CloudFunctionsProtocol, localCache: CoreDataStorageProtocol)
    {
        self.apiProxy = apiProxy
        self.localCache = localCache
        loadDummyData()
    }

    // MARK: - Methods

    /// Fetches a random debate motion from an external API with cooldown protection.
    func triggerFetchMotion() {
        guard !isGenerating else { return }
        isGenerating = true

        Task {
            do {
                let response = try await apiProxy.callExternalAPI(
                    endpoint: "get-random-motion",
                    parameters: [:]
                )
                let newMotion = MotionModel(
                    id: response["id"] as? String ?? UUID().uuidString,
                    title: response["title"] as? String ?? "New Motion",
                    category: response["category"] as? String ?? "General",
                    isWishlisted: false
                )

                DispatchQueue.main.async {
                    self.motionsList.insert(newMotion, at: 0)
                }
                try await Task.sleep(nanoseconds: 600_000_000)
                DispatchQueue.main.async { self.isGenerating = false }
            } catch {
                DispatchQueue.main.async { self.isGenerating = false }
                print("Error fetching motion: \(error)")
            }
        }
    }

    /// Converts a generated motion into an editable case-building note.
    func createNoteFromMotion(_ motion: MotionModel) {
        guard !myNotes.contains(where: { $0.motionTitle == motion.title })
        else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }

        if let idx = motionsList.firstIndex(where: { $0.id == motion.id }) {
            motionsList[idx].isWishlisted = true
        }

        let newNote = CaseBuildingNoteModel(
            id: UUID().uuidString,
            ownerId: userId,
            motionTitle: motion.title,
            argumentsRichText: "",
            visibility: .privateAccess,
            isFeedbackRequested: false,
            updatedAt: Date()
        )
        saveNote(newNote)
    }

    /// Persists note updates to Firestore.
    func saveNote(_ note: CaseBuildingNoteModel) {
        var noteToSave = note
        if noteToSave.ownerId == "user_me" || noteToSave.ownerId.isEmpty {
            noteToSave.ownerId = Auth.auth().currentUser?.uid ?? "unknown"
        }

        var data: [String: Any] = [
            "id": noteToSave.id,
            "ownerId": noteToSave.ownerId,
            "motionTitle": noteToSave.motionTitle,
            "argumentsRichText": noteToSave.argumentsRichText,
            "visibility": noteToSave.visibility.rawValue,
            "isFeedbackRequested": noteToSave.isFeedbackRequested,
            "updatedAt": Timestamp(date: noteToSave.updatedAt),
        ]

        if let fText = noteToSave.feedbackText { data["feedbackText"] = fText }
        if let fProv = noteToSave.feedbackProviderName {
            data["feedbackProviderName"] = fProv
        }

        let db = Firestore.firestore()
        db.collection("case_notes").document(noteToSave.id).setData(
            data,
            merge: true
        ) { error in
            if let error = error {
                print("Error save: \(error.localizedDescription)")
            }
        }
    }

    func requestFeedback(for noteId: String) {
        let db = Firestore.firestore()
        db.collection("case_notes").document(noteId).updateData([
            "isFeedbackRequested": true
        ])
    }

    func deleteNoteFromFirestore(noteId: String) {
        let db = Firestore.firestore()
        db.collection("case_notes").document(noteId).delete { error in
            if let error = error {
                print("Gagal menghapus catatan: \(error.localizedDescription)")
            }
        }
    }

    func fetchMyNotes(userId: String) {
        let db = Firestore.firestore()
        db.collection("case_notes").whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.myNotes = self.mapDocumentsToNotes(documents)
            }
    }

    /// Fetches all public notes for the community feed.
    func fetchCommunityNotes() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("case_notes")
            .whereField("visibility", isEqualTo: "PUBLIC")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }

                let allPublic = self.mapDocumentsToNotes(documents)
                // Filter out user's own notes so they only see others' notes
                self.communityNotes = allPublic.filter {
                    $0.ownerId != currentUserId
                }
            }
    }

    private func mapDocumentsToNotes(_ documents: [QueryDocumentSnapshot])
        -> [CaseBuildingNoteModel]
    {
        let notes = documents.compactMap { doc -> CaseBuildingNoteModel? in
            let data = doc.data()
            let visibilityStr = data["visibility"] as? String ?? "PRIVATE"
            let visibility: VisibilityType =
                (visibilityStr == "PUBLIC" || visibilityStr == "public")
                ? .publicAccess : .privateAccess

            return CaseBuildingNoteModel(
                id: doc.documentID,
                ownerId: data["ownerId"] as? String ?? "",
                motionTitle: data["motionTitle"] as? String ?? "",
                argumentsRichText: data["argumentsRichText"] as? String ?? "",
                visibility: visibility,
                isFeedbackRequested: data["isFeedbackRequested"] as? Bool
                    ?? false,
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                    ?? Date(),
                feedbackText: data["feedbackText"] as? String,
                feedbackProviderName: data["feedbackProviderName"] as? String
            )
        }
        return notes.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func loadDummyData() {
        motionsList = [
            MotionModel(
                id: "m1",
                title:
                    "This house would ban artificial intelligence in education",
                category: "Education & Tech",
                isWishlisted: false
            )
        ]
    }
}
