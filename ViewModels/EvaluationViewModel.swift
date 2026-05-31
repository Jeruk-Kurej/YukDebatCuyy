//
//  EvaluationViewModel.swift
//  YukDebatCuyy
//

import Combine
import FirebaseFirestore
import Foundation

/// Manages the data flow for Adjudicators evaluating Case Building Notes and Sparring Sessions.
class EvaluationViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var pendingRequests: [CaseBuildingNoteModel] = []
    @Published var historyRequests: [CaseBuildingNoteModel] = []
    @Published var mySparringEvaluations: [EvaluationModel] = []

    // MARK: - Methods

    func fetchPendingFeedbacks() {
        let db = Firestore.firestore()
        db.collection("case_notes")
            .whereField("isFeedbackRequested", isEqualTo: true)
            .whereField("visibility", isEqualTo: "PUBLIC")
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                self.pendingRequests = docs.compactMap { doc in
                    let data = doc.data()
                    if data["feedbackText"] != nil { return nil }

                    return CaseBuildingNoteModel(
                        id: doc.documentID,
                        ownerId: data["ownerId"] as? String ?? "",
                        motionTitle: data["motionTitle"] as? String ?? "",
                        argumentsRichText: data["argumentsRichText"] as? String
                            ?? "",
                        visibility: .publicAccess,
                        isFeedbackRequested: true,
                        updatedAt: (data["updatedAt"] as? Timestamp)?
                            .dateValue() ?? Date(),
                        feedbackText: data["feedbackText"] as? String,
                        feedbackProviderName: data["feedbackProviderName"]
                            as? String
                    )
                }
                self.pendingRequests.sort { $0.updatedAt < $1.updatedAt }
            }
    }

    func fetchEvaluationHistory(providerName: String) {
        let db = Firestore.firestore()
        db.collection("case_notes")
            .whereField("feedbackProviderName", isEqualTo: providerName)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                self.historyRequests = docs.compactMap { doc in
                    let data = doc.data()
                    return CaseBuildingNoteModel(
                        id: doc.documentID,
                        ownerId: data["ownerId"] as? String ?? "",
                        motionTitle: data["motionTitle"] as? String ?? "",
                        argumentsRichText: data["argumentsRichText"] as? String
                            ?? "",
                        visibility: .publicAccess,
                        isFeedbackRequested: data["isFeedbackRequested"]
                            as? Bool ?? false,
                        updatedAt: (data["updatedAt"] as? Timestamp)?
                            .dateValue() ?? Date(),
                        feedbackText: data["feedbackText"] as? String,
                        feedbackProviderName: data["feedbackProviderName"]
                            as? String
                    )
                }
                self.historyRequests.sort { $0.updatedAt > $1.updatedAt }
            }
    }

    func submitFeedback(
        noteId: String,
        feedbackText: String,
        providerName: String
    ) {
        let db = Firestore.firestore()
        db.collection("case_notes").document(noteId).updateData([
            "feedbackText": feedbackText,
            "feedbackProviderName": providerName,
            "isFeedbackRequested": false,
        ])
    }

    func fetchMySparringEvaluations(userId: String) {
        let db = Firestore.firestore()
        db.collection("evaluations").addSnapshotListener { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            let allEvals = docs.compactMap { doc -> EvaluationModel? in
                let data = doc.data()
                return EvaluationModel(
                    id: doc.documentID,
                    targetId: data["targetId"] as? String ?? "",
                    adjudicatorId: data["adjudicatorId"] as? String ?? "",
                    speakerScores: data["speakerScores"] as? [String: Int]
                        ?? [:],
                    narrativeFeedback: data["narrativeFeedback"] as? String
                        ?? "",
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
                        ?? Date()
                )
            }
            self.mySparringEvaluations = allEvals.filter {
                $0.speakerScores.keys.contains(userId)
            }
        }
    }

    /// BUSINESS LOGIC: Handles raw data from the UI, applies default scores, and persists to the database.
    /// Fulfills FR-4.1 and FR-4.2 while strictly adhering to the Single Responsibility Principle.
    func submitSparringEvaluation(
        room: SparringRoomModel,
        adjudicatorId: String,
        feedback: String,
        rawScores: [String: Int]
    ) {
        let db = Firestore.firestore()
        let evalId = UUID().uuidString

        var finalScores = rawScores
        for p in room.participants {
            if finalScores[p.userId] == nil {
                finalScores[p.userId] = 75  // Menetapkan default score BP format
            }
        }

        let data: [String: Any] = [
            "id": evalId,
            "targetId": room.id,
            "adjudicatorId": adjudicatorId,
            "speakerScores": finalScores,
            "narrativeFeedback": feedback,
            "createdAt": Timestamp(date: Date()),
        ]

        db.collection("evaluations").document(evalId).setData(data) { error in
            if let error = error {
                print(
                    "Error submitting evaluation: \(error.localizedDescription)"
                )
            }
        }
    }
}
