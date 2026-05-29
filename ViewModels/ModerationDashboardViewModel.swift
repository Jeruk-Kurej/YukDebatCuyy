import Foundation
import FirebaseFirestore
import Combine

class ModerationDashboardViewModel: ObservableObject {
    @Published var pendingList: [CompetitionModel] = []
    @Published var approvedList: [CompetitionModel] = []
    
    private let db = Firestore.firestore()
    
    func fetchAllModeration() {
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
                    promoterEmail: data["promoterEmail"] as? String ?? "Unknown Email", // <-- Tangkap emailnya
                    name: data["name"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    eventDate: (data["eventDate"] as? Timestamp)?.dateValue() ?? Date(),
                    registrationUrl: data["registrationUrl"] as? String ?? "",
                    posterStorageUrl: data["posterUrl"] as? String ?? "",
                    status: ReviewStatus(rawValue: status) ?? .pending
                )
                
                if status == "PENDING" { tempPending.append(model) }
                else if status == "ACTIVE" { tempApproved.append(model) }
            }
            
            self.pendingList = tempPending
            self.approvedList = tempApproved
        }
    }
    
    func updateStatus(compId: String, to status: String) {
        db.collection("competitions").document(compId).updateData(["status": status])
    }
}
