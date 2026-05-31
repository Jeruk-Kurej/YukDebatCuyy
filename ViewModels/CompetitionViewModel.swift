import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import UIKit

/// Handles the business logic for creating and displaying Debate Competitions.
class CompetitionViewModel: ObservableObject {

    // MARK: - Published Properties (State)
    @Published var activeCompetitions: [CompetitionModel] = []
    @Published var myPendingCompetitions: [CompetitionModel] = []

    // MARK: - Published Properties (Form Data)
    @Published var name: String = ""
    @Published var desc: String = ""
    @Published var selectedImageData: Data? = nil

    // MARK: - Published Properties (UI Feedback)
    @Published var statusMsg: String? = nil
    @Published var isLoading: Bool = false
    @Published var isUploadSuccess: Bool = false

    // MARK: - Private Properties
    private let db = Firestore.firestore()

    // MARK: - Methods
    /// Fetches all active competitions and the current user's pending competitions.
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

    /// Helper method to safely map Firestore documents to `CompetitionModel`.
    private func mapToModel(doc: QueryDocumentSnapshot) -> CompetitionModel {
        let data = doc.data()
        return CompetitionModel(
            id: doc.documentID,
            promoterId: data["promoterId"] as? String ?? "",
            promoterEmail: data["promoterEmail"] as? String ?? "Unknown Email",
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

    /// Processes image data, compresses it to Base64, and uploads the competition record.
    func submitCompetitionData() {
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
            "promoterEmail": userEmail,
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

    /// Clears form fields upon successful submission.
    private func resetForm() {
        self.name = ""
        self.desc = ""
        self.selectedImageData = nil
    }
}
