//
//  AdjudicatorRequestViewModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 30/05/26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import Combine

class AdjudicatorRequestViewModel: ObservableObject {
    @Published var experience: String = ""
    @Published var selectedImageData: Data? = nil

    @Published var statusMsg: String? = nil
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var hasPendingRequest: Bool = false

    private let db = Firestore.firestore()

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
            "id": newDocRef.documentID,
            "userId": userId,
            "userEmail": userEmail,
            "fullName": userName,
            "experience": self.experience,
            "certificateUrl": base64String,
            "status": "PENDING",
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
