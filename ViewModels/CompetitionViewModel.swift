import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import UIKit  // <-- Wajib untuk kompresi dan render UIImage

class CompetitionViewModel: ObservableObject {
    @Published var activeCompetitions: [CompetitionModel] = []
    @Published var myPendingCompetitions: [CompetitionModel] = []

    // Form Data
    @Published var name: String = ""
    @Published var desc: String = ""
    @Published var selectedImageData: Data? = nil

    // Status UI
    @Published var statusMsg: String? = nil
    @Published var isLoading: Bool = false
    @Published var isUploadSuccess: Bool = false

    private let db = Firestore.firestore()

    func fetchCompetitions() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        db.collection("competitions").whereField("status", isEqualTo: "ACTIVE")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.activeCompetitions = docs.compactMap {
                    self.mapToModel(doc: $0)
                }
            }

        db.collection("competitions")
            .whereField("promoterId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "PENDING")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.myPendingCompetitions = docs.compactMap {
                    self.mapToModel(doc: $0)
                }
            }
    }

    private func mapToModel(doc: QueryDocumentSnapshot) -> CompetitionModel {
        let data = doc.data()
        return CompetitionModel(
            id: doc.documentID,
            promoterId: data["promoterId"] as? String ?? "",
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            eventDate: (data["eventDate"] as? Timestamp)?.dateValue() ?? Date(),
            registrationUrl: data["registrationUrl"] as? String ?? "",
            posterStorageUrl: data["posterUrl"] as? String ?? "",
            status: ReviewStatus(
                rawValue: data["status"] as? String ?? "PENDING"
            ) ?? .pending
        )
    }

    // LOGIKA JALAN TIKUS: Bypass Storage dengan Base64
    func submitCompetitionData() {
        // REVISI: Cegah akun tanpa email valid untuk submit
        guard let currentUserId = Auth.auth().currentUser?.uid,
            let userEmail = Auth.auth().currentUser?.email, !userEmail.isEmpty
        else {
            self.statusMsg = "Akses ditolak: Akun/Email tidak valid."
            return
        }

        guard let imageData = selectedImageData else {
            self.statusMsg = "Select a poster image first!"
            return
        }

        isLoading = true
        self.statusMsg = "Uploading competition..."

        let newDocRef = db.collection("competitions").document()

        guard let uiImage = UIImage(data: imageData),
            let compressedData = uiImage.jpegData(compressionQuality: 0.1)
        else {
            self.statusMsg = "Failed to process image."
            self.isLoading = false
            return
        }

        let base64String = compressedData.base64EncodedString()

        let data: [String: Any] = [
            "id": newDocRef.documentID,
            "promoterId": currentUserId,
            "promoterEmail": userEmail,  // Email asli tersimpan!
            "name": self.name,
            "description": self.desc,
            "posterUrl": base64String,
            "status": "PENDING",
            "eventDate": Timestamp(date: Date().addingTimeInterval(864000)),
            "registrationUrl": "https://forms.gle/dummy",
        ]

        newDocRef.setData(data) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.statusMsg =
                        "Failed to save: \(error.localizedDescription)"
                } else {
                    self.statusMsg = "Successfully submitted! Pending approval."
                    self.isUploadSuccess = true
                    self.resetForm()
                }
            }
        }
    }

    private func resetForm() {
        self.name = ""
        self.desc = ""
        self.selectedImageData = nil
    }
}
