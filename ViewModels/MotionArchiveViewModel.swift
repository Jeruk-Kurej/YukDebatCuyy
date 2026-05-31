//
//  MotionArchiveViewModel.swift
//  YukDebatCuyy
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

/// Manages fetching random motions, synchronizing case building notes, and submitting custom motions.
class MotionArchiveViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var motionsList: [MotionModel] = []
    @Published var searchText: String = ""
    @Published var myNotes: [CaseBuildingNoteModel] = []
    @Published var communityNotes: [CaseBuildingNoteModel] = []

    @Published var isGenerating: Bool = false
    @Published var isLoading: Bool = false
    @Published var statusMessage: String? = nil

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
    private let db = Firestore.firestore()

    // MARK: - Initialization

    init(apiProxy: CloudFunctionsProtocol, localCache: CoreDataStorageProtocol)
    {
        self.apiProxy = apiProxy
        self.localCache = localCache
        loadDefaultMotions()
    }

    // MARK: - Methods

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

    /// Submits a user-generated custom motion to Firestore for Admin moderation (FR-6.1).
    func submitCustomMotion(title: String, category: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        let newId = UUID().uuidString
        let data: [String: Any] = [
            "id": newId,
            "title": title,
            "category": category,
            "submitterId": userId,
            "status": ReviewStatus.pending.rawValue,
            "submittedAt": Timestamp(date: Date()),
        ]

        db.collection("motion_requests").document(newId).setData(data) {
            [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.statusMessage =
                        "Gagal mengirim: \(error.localizedDescription)"
                } else {
                    self?.statusMessage =
                        "Mosi berhasil dikirim untuk direviu Admin!"
                }
            }
        }
    }

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

        db.collection("case_notes").document(noteToSave.id).setData(
            data,
            merge: true
        )
    }

    func requestFeedback(for noteId: String) {
        db.collection("case_notes").document(noteId).updateData([
            "isFeedbackRequested": true
        ])
    }

    func deleteNoteFromFirestore(noteId: String) {
        db.collection("case_notes").document(noteId).delete()
    }

    func fetchMyNotes(userId: String) {
        db.collection("case_notes").whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self.myNotes = self.mapDocumentsToNotes(documents)
            }
    }

    func fetchCommunityNotes() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        db.collection("case_notes").whereField(
            "visibility",
            isEqualTo: "PUBLIC"
        )
        .addSnapshotListener { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let allPublic = self.mapDocumentsToNotes(documents)
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

    /// Populates the initial view with 20 high-quality, uniquely phrased BP motions in Indonesian.
    private func loadDefaultMotions() {
        motionsList = [
            MotionModel(
                id: "m1",
                title:
                    "Melarang secara penuh penggunaan kecerdasan buatan (AI) di seluruh institusi pendidikan formal.",
                category: "Education",
                isWishlisted: false
            ),
            MotionModel(
                id: "m2",
                title:
                    "Menyesali glorifikasi budaya kerja berlebihan (hustle culture) di kalangan generasi muda.",
                category: "Politics & Social",
                isWishlisted: false
            ),
            MotionModel(
                id: "m3",
                title:
                    "Sebagai negara berkembang, memprioritaskan pertumbuhan ekonomi di atas pelestarian lingkungan hidup.",
                category: "Economy & Business",
                isWishlisted: false
            ),
            MotionModel(
                id: "m4",
                title:
                    "Menetapkan batas maksimal kekayaan pribadi bagi setiap individu warga negara.",
                category: "Economy & Business",
                isWishlisted: false
            ),
            MotionModel(
                id: "m5",
                title:
                    "Mendukung penerapan sistem empat hari kerja dalam seminggu secara nasional.",
                category: "Economy & Business",
                isWishlisted: false
            ),
            MotionModel(
                id: "m6",
                title:
                    "Menurunkan batas usia minimum hak pilih dalam pemilihan umum menjadi 16 tahun.",
                category: "Politics & Social",
                isWishlisted: false
            ),
            MotionModel(
                id: "m7",
                title:
                    "Menyesali munculnya fenomena budaya pembatalan (Cancel Culture) di media sosial.",
                category: "Politics & Social",
                isWishlisted: false
            ),
            MotionModel(
                id: "m8",
                title:
                    "Melarang segala bentuk kampanye dan iklan politik berbayar di platform media sosial.",
                category: "Politics & Social",
                isWishlisted: false
            ),
            MotionModel(
                id: "m9",
                title:
                    "Mempercayai bahwa gerakan feminis progresif harus secara aktif menentang institusi pernikahan.",
                category: "Politics & Social",
                isWishlisted: false
            ),
            MotionModel(
                id: "m10",
                title:
                    "Menghapus sistem hukuman mati untuk semua jenis tindak pidana tanpa terkecuali.",
                category: "Law & Constitution",
                isWishlisted: false
            ),
            MotionModel(
                id: "m11",
                title:
                    "Mendukung mekanisme pemilihan langsung hakim agung oleh rakyat.",
                category: "Law & Constitution",
                isWishlisted: false
            ),
            MotionModel(
                id: "m12",
                title:
                    "Memberikan status 'subjek hukum' (legal personhood) kepada entitas ekosistem alam seperti sungai dan hutan.",
                category: "Law & Constitution",
                isWishlisted: false
            ),
            MotionModel(
                id: "m13",
                title:
                    "Menentang privatisasi program eksplorasi luar angkasa oleh perusahaan komersial.",
                category: "Science & Tech",
                isWishlisted: false
            ),
            MotionModel(
                id: "m14",
                title:
                    "Menyesali dominasi bahasa asing tertentu sebagai standar utama dalam publikasi jurnal akademik global.",
                category: "Education",
                isWishlisted: false
            ),
            MotionModel(
                id: "m15",
                title:
                    "Mewajibkan calon orang tua untuk lulus tes kelayakan mengasuh anak sebelum diizinkan memiliki keturunan.",
                category: "Politics & Social",
                isWishlisted: false
            ),
            MotionModel(
                id: "m16",
                title:
                    "Sebagai Bank Sentral, segera menerbitkan mata uang digital secara independen (CBDC).",
                category: "Economy & Business",
                isWishlisted: false
            ),
            MotionModel(
                id: "m17",
                title:
                    "Mengizinkan narapidana berpartisipasi dalam uji coba medis berisiko tinggi demi pengurangan masa tahanan.",
                category: "Law & Constitution",
                isWishlisted: false
            ),
            MotionModel(
                id: "m18",
                title:
                    "Menyesali komersialisasi gerakan keadilan sosial oleh korporasi-korporasi multinasional.",
                category: "Politics & Social",
                isWishlisted: false
            ),
            MotionModel(
                id: "m19",
                title:
                    "Menerapkan sistem Pendapatan Dasar Universal (Universal Basic Income) untuk membasmi kemiskinan struktural.",
                category: "Economy & Business",
                isWishlisted: false
            ),
            MotionModel(
                id: "m20",
                title:
                    "Menuntut penikmat seni untuk selalu memisahkan karya seni dari rekam jejak moralitas pembuatnya.",
                category: "Arts & Culture",
                isWishlisted: false
            ),
        ]
    }
}
