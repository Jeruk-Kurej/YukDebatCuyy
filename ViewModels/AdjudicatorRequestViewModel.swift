import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import UIKit

/// Manages the user flow for requesting an Adjudicator Role Upgrade.
class AdjudicatorRequestViewModel: ObservableObject {

    // MARK: - Published Properties (Form)
    @Published var experience: String = ""
    @Published var selectedImageData: Data? = nil

    // MARK: - Published Properties (State)
    @Published var statusMsg: String? = nil
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var hasPendingRequest: Bool = false

    // MARK: - Private Properties
    private let db = Firestore.firestore()

    // MARK: - Methods
    /// Checks if the current user already has an ongoing upgrade request.
    func checkExistingRequest() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("adjudicator_requests")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "PENDING")
            .getDocuments { snapshot, _ in
                DispatchQueue.main.async {
                    self.hasPendingRequest =
                        !(snapshot?.documents.isEmpty ?? true)
                }
            }
    }

    /// Encodes the certificate image to Base64 and submits the application to Firestore.
    func submitRequest(userName: String, userEmail: String) {
        guard let userId = Auth.auth().currentUser?.uid,
            let imageData = selectedImageData
        else {
            self.statusMsg = "Pilih foto sertifikat/bukti terlebih dahulu!"
            return
        }

        isLoading = true
        self.statusMsg = "Mengirim pengajuan..."

        guard let uiImage = UIImage(data: imageData),
            let compressedData = uiImage.jpegData(compressionQuality: 0.1)
        else {
            self.statusMsg = "Gagal memproses gambar."
            self.isLoading = false
            return
        }

        let base64String = compressedData.base64EncodedString()
        let newDocRef = db.collection("adjudicator_requests").document()

        let data: [String: Any] = [
            "id": newDocRef.documentID, "userId": userId,
            "userEmail": userEmail,
            "fullName": userName, "experience": self.experience,
            "certificateUrl": base64String, "status": "PENDING",
            "submittedAt": Timestamp(date: Date()),
        ]

        newDocRef.setData(data) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.statusMsg =
                        "Gagal mengirim: \(error.localizedDescription)"
                } else {
                    self.statusMsg =
                        "Berhasil diajukan! Menunggu validasi Admin."
                    self.isSuccess = true
                    self.hasPendingRequest = true
                }
            }
        }
    }
}
