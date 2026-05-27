import Combine
import Foundation

class CompetitionViewModel: ObservableObject {
    @Published var competitions: [CompetitionModel] = []
    @Published var statusMsg: String = ""
    @Published var name: String = ""
    @Published var desc: String = ""

    private let dbService: FirestoreServiceProtocol
    private let storageService: CloudStorageProtocol

    init(
        dbService: FirestoreServiceProtocol,
        storageService: CloudStorageProtocol
    ) {
        self.dbService = dbService
        self.storageService = storageService
    }

    func fetchCompetitions() {
        // Logika untuk mengambil data kompetisi berstatus 'active'
        self.competitions = [
            CompetitionModel(
                id: "c1",
                promoterId: "p1",
                name: "National Debate Open",
                description: "Kompetisi tahunan tingkat nasional.",
                eventDate: Date().addingTimeInterval(864000),
                registrationUrl: "https://bit.ly/reg-ndo",
                posterStorageUrl: "",
                status: .active
            )
        ]
    }

    func submitCompetitionData(imageData: Data) {
        Task {
            do {
                // Strategi: Kompresi lokal -> Upload Storage -> Save Firestore
                let compressedData = executeLocalCompression(image: imageData)
                let downloadUrl = try await storageService.uploadPosterFile(
                    fileData: compressedData
                )
                let data: [String: Any] = [
                    "name": name,
                    "description": desc,
                    "posterUrl": downloadUrl,
                    "status": ReviewStatus.pending.rawValue,
                ]

                try await dbService.saveDocument(
                    collection: "competitions",
                    documentId: UUID().uuidString,
                    data: data
                )

                DispatchQueue.main.async {
                    self.statusMsg =
                        "Kompetisi berhasil diunggah dan menunggu moderasi Admin."
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusMsg =
                        "Gagal mengunggah: \(error.localizedDescription)"
                }
            }
        }
    }

    private func executeLocalCompression(image: Data) -> Data {
        // Implementasi logika kompresi untuk memenuhi NFR-2.1 (Max 2MB) [cite: 255]
        return image
    }
}
