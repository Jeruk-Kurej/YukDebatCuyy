import Combine
import FirebaseFirestore
import Foundation

class ModerationDashboardViewModel: ObservableObject {
    @Published var pendingList: [CompetitionModel] = []
    @Published var approvedList: [CompetitionModel] = []

    @Published var pendingAdjudicators: [AdjudicatorRequestModel] = []
    // TAMBAHAN: State penampung history Juri
    @Published var approvedAdjudicators: [AdjudicatorRequestModel] = []

    private let db = Firestore.firestore()

    func fetchAllModeration() {
        // 1. TARIK DATA KOMPETISI
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

        // 2. TARIK DATA PENGAJUAN JURI (SUDAH DIPERBAIKI)
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
    }

    func updateStatus(compId: String, to status: String) {
        db.collection("competitions").document(compId).updateData([
            "status": status
        ])
    }

    func approveAdjudicator(reqId: String, userId: String) {
        let batch = db.batch()

        let reqRef = db.collection("adjudicator_requests").document(reqId)
        batch.updateData(["status": "ACTIVE"], forDocument: reqRef)

        let userRef = db.collection("users").document(userId)
        batch.updateData(["role": "ADJUDICATOR"], forDocument: userRef)

        batch.commit { error in
            if let error = error {
                print(
                    "Error approving adjudicator: \(error.localizedDescription)"
                )
            }
        }
    }
}
