import Foundation
import FirebaseFirestore
import Combine

class EvaluationViewModel: ObservableObject {
    @Published var pendingRequests: [CaseBuildingNoteModel] = []
    // TAMBAHAN: Variabel untuk menampung riwayat review juri
    @Published var historyRequests: [CaseBuildingNoteModel] = []
    
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
                        argumentsRichText: data["argumentsRichText"] as? String ?? "",
                        visibility: .publicAccess,
                        isFeedbackRequested: true,
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                        feedbackText: data["feedbackText"] as? String,
                        feedbackProviderName: data["feedbackProviderName"] as? String
                    )
                }
                self.pendingRequests.sort { $0.updatedAt < $1.updatedAt }
            }
    }
    
    // TAMBAHAN: Fungsi untuk mengambil history berdasarkan nama juri
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
                        argumentsRichText: data["argumentsRichText"] as? String ?? "",
                        visibility: .publicAccess,
                        isFeedbackRequested: data["isFeedbackRequested"] as? Bool ?? false,
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                        feedbackText: data["feedbackText"] as? String,
                        feedbackProviderName: data["feedbackProviderName"] as? String
                    )
                }
                // Urutkan dari review yang paling baru
                self.historyRequests.sort { $0.updatedAt > $1.updatedAt }
            }
    }
    
    func submitFeedback(noteId: String, feedbackText: String, providerName: String) {
        let db = Firestore.firestore()
        db.collection("case_notes").document(noteId).updateData([
            "feedbackText": feedbackText,
            "feedbackProviderName": providerName,
            "isFeedbackRequested": false
        ]) { error in
            if let error = error {
                print("Gagal mengirim feedback: \(error.localizedDescription)")
            }
        }
    }
}
