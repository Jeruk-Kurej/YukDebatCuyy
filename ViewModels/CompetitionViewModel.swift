import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class CompetitionViewModel: ObservableObject {
    @Published var competitions: [CompetitionModel] = []
    
    // Status Upload
    @Published var statusMsg: String? = nil
    @Published var isLoading: Bool = false
    @Published var isUploadSuccess: Bool = false
    
    // Form Data
    @Published var name: String = ""
    @Published var desc: String = ""

    private let db = Firestore.firestore()

    // Ambil Lomba yang statusnya ACTIVE saja (Untuk User Biasa)
    func fetchCompetitions() {
        db.collection("competitions")
            .whereField("status", isEqualTo: "ACTIVE") // Filter hanya lomba aktif
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self.competitions = documents.compactMap { doc -> CompetitionModel? in
                    let data = doc.data()
                    return CompetitionModel(
                        id: doc.documentID,
                        promoterId: data["promoterId"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        eventDate: (data["eventDate"] as? Timestamp)?.dateValue() ?? Date(),
                        registrationUrl: data["registrationUrl"] as? String ?? "",
                        posterStorageUrl: data["posterUrl"] as? String ?? "",
                        status: .active
                    )
                }
            }
    }

    // Submit Lomba Baru (Otomatis status PENDING)
    func submitCompetitionData() {
        isLoading = true
        isUploadSuccess = false
        
        let newId = UUID().uuidString
        let promoterId = Auth.auth().currentUser?.uid ?? "unknown_promoter"
        
        // Data yang dikirim ke Firebase
        let data: [String: Any] = [
            "id": newId,
            "promoterId": promoterId,
            "name": name,
            "description": desc,
            "posterUrl": "", // Nanti disesuaikan jika Firebase Storage sudah ready
            "status": "PENDING", // <-- LOGIKA PENDING ADA DI SINI
            "eventDate": Timestamp(date: Date().addingTimeInterval(864000)),
            "registrationUrl": "https://docs.google.com/forms"
        ]

        db.collection("competitions").document(newId).setData(data) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.statusMsg = "Gagal menambahkan: \(error.localizedDescription)"
                } else {
                    self.statusMsg = "Berhasil! Lomba berstatus PENDING dan menunggu persetujuan Admin."
                    self.isUploadSuccess = true
                    // Reset Form
                    self.name = ""
                    self.desc = ""
                }
            }
        }
    }
}
