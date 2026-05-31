//
//  ModerationDashboardViewModel.swift
//  YukDebatCuyy
//

import Combine
import FirebaseFirestore
import Foundation

/// Provides comprehensive data aggregation for the Admin Moderation Dashboard.
class ModerationDashboardViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var pendingList: [CompetitionModel] = []
    @Published var approvedList: [CompetitionModel] = []
    @Published var pendingAdjudicators: [AdjudicatorRequestModel] = []
    @Published var approvedAdjudicators: [AdjudicatorRequestModel] = []

    @Published var allUsers: [UserModel] = []
    @Published var publicNotes: [CaseBuildingNoteModel] = []
    @Published var pendingMotions: [MotionRequestModel] = []

    // MARK: - Private Properties

    private let db = Firestore.firestore()

    // MARK: - Methods

    func fetchAllModeration() {
        // Fetch Competitions
        db.collection("competitions").addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            var tempPending: [CompetitionModel] = []
            var tempApproved: [CompetitionModel] = []
            for doc in docs {
                let data = doc.data()
                let status = data["status"] as? String ?? "PENDING"
                let model = CompetitionModel(
                    id: doc.documentID,
                    promoterId: data["promoterId"] as? String ?? "",
                    promoterEmail: data["promoterEmail"] as? String
                        ?? "Unknown Email",
                    name: data["name"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    eventDate: (data["eventDate"] as? Timestamp)?.dateValue()
                        ?? Date(),
                    registrationUrl: data["registrationUrl"] as? String ?? "",
                    posterStorageUrl: data["posterUrl"] as? String ?? "",
                    status: ReviewStatus(rawValue: status) ?? .pending
                )
                if status == "PENDING" {
                    tempPending.append(model)
                } else if status == "ACTIVE" {
                    tempApproved.append(model)
                }
            }
            self.pendingList = tempPending
            self.approvedList = tempApproved
        }

        // Fetch Adjudicator Requests
        db.collection("adjudicator_requests").addSnapshotListener {
            snapshot,
            _ in
            guard let docs = snapshot?.documents else { return }
            var tempPendingAdj: [AdjudicatorRequestModel] = []
            var tempApprovedAdj: [AdjudicatorRequestModel] = []
            for doc in docs {
                let data = doc.data()
                let status = data["status"] as? String ?? "PENDING"
                let model = AdjudicatorRequestModel(
                    id: doc.documentID,
                    userId: data["userId"] as? String ?? "",
                    userEmail: data["userEmail"] as? String ?? "",
                    fullName: data["fullName"] as? String ?? "",
                    experience: data["experience"] as? String ?? "",
                    certificateUrl: data["certificateUrl"] as? String ?? "",
                    status: ReviewStatus(rawValue: status) ?? .pending,
                    submittedAt: (data["submittedAt"] as? Timestamp)?
                        .dateValue() ?? Date()
                )
                if status == "PENDING" {
                    tempPendingAdj.append(model)
                } else if status == "ACTIVE" {
                    tempApprovedAdj.append(model)
                }
            }
            self.pendingAdjudicators = tempPendingAdj
            self.approvedAdjudicators = tempApprovedAdj
        }

        // Fetch Custom Motion Requests
        db.collection("motion_requests").whereField(
            "status",
            isEqualTo: "PENDING"
        ).addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self.pendingMotions = docs.compactMap { doc in
                let data = doc.data()
                return MotionRequestModel(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "",
                    category: data["category"] as? String ?? "General",
                    submitterId: data["submitterId"] as? String ?? "",
                    status: .pending,
                    submittedAt: (data["submittedAt"] as? Timestamp)?
                        .dateValue() ?? Date()
                )
            }
        }

        // Fetch Users and Notes
        db.collection("users").addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self.allUsers = docs.compactMap { doc in
                let data = doc.data()
                return UserModel(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "Unknown",
                    email: data["email"] as? String ?? "",
                    role: UserRole(
                        rawValue: data["role"] as? String ?? "DEBATER"
                    ) ?? .debater,
                    isActive: data["isActive"] as? Bool ?? true,
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
                        ?? Date()
                )
            }
        }

        db.collection("case_notes").whereField(
            "visibility",
            isEqualTo: "PUBLIC"
        ).addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self.publicNotes = docs.compactMap { doc in
                let data = doc.data()
                return CaseBuildingNoteModel(
                    id: doc.documentID,
                    ownerId: data["ownerId"] as? String ?? "",
                    motionTitle: data["motionTitle"] as? String ?? "",
                    argumentsRichText: data["argumentsRichText"] as? String
                        ?? "",
                    visibility: .publicAccess,
                    isFeedbackRequested: data["isFeedbackRequested"] as? Bool
                        ?? false,
                    updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                        ?? Date(),
                    feedbackText: data["feedbackText"] as? String,
                    feedbackProviderName: data["feedbackProviderName"]
                        as? String
                )
            }
        }
    }

    // MARK: - Modification Methods

    func updateStatus(compId: String, to status: String) {
        db.collection("competitions").document(compId).updateData([
            "status": status
        ])
    }
    func suspendUser(userId: String, isActive: Bool) {
        db.collection("users").document(userId).updateData([
            "isActive": isActive
        ])
    }
    func deletePublicNote(noteId: String) {
        db.collection("case_notes").document(noteId).delete()
    }
    func rejectMotionRequest(reqId: String) {
        db.collection("motion_requests").document(reqId).updateData([
            "status": "REJECTED"
        ])
    }

    func approveAdjudicator(reqId: String, userId: String) {
        let batch = db.batch()
        batch.updateData(
            ["status": "ACTIVE"],
            forDocument: db.collection("adjudicator_requests").document(reqId)
        )
        batch.updateData(
            ["role": "ADJUDICATOR"],
            forDocument: db.collection("users").document(userId)
        )
        batch.commit { _ in }
    }

    /// Approves a motion and saves it into the official motions collection.
    func approveMotionRequest(req: MotionRequestModel) {
        let batch = db.batch()
        batch.updateData(
            ["status": "ACTIVE"],
            forDocument: db.collection("motion_requests").document(req.id)
        )

        let officialMotionData: [String: Any] = [
            "id": req.id,
            "title": req.title,
            "category": req.category,
        ]
        batch.setData(
            officialMotionData,
            forDocument: db.collection("motions").document(req.id)
        )
        batch.commit { _ in }
    }
}
