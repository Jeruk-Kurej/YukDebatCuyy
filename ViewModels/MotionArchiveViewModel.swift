import Foundation
import Combine

class MotionArchiveViewModel: ObservableObject {
    // State Utama
    @Published var motionsList: [MotionModel] = []
    @Published var savedNotes: [CaseBuildingNoteModel] = []
    
    // State Pencarian (Search)
    @Published var searchText: String = ""
    
    // Services
    private let apiProxy: CloudFunctionsProtocol
    private let localCache: CoreDataStorageProtocol
    
    init(apiProxy: CloudFunctionsProtocol, localCache: CoreDataStorageProtocol) {
        self.apiProxy = apiProxy
        self.localCache = localCache
        loadDummyData() // Simulasi data awal
    }
    
    // Computed Property untuk fitur Search yang Real-time
    var filteredMotions: [MotionModel] {
        if searchText.isEmpty { return motionsList }
        return motionsList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredNotes: [CaseBuildingNoteModel] {
        if searchText.isEmpty { return savedNotes }
        return savedNotes.filter { $0.motionTitle.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - Motion Logic (Generate)
    func triggerFetchMotion() {
        Task {
            do {
                let response = try await apiProxy.callExternalAPI(endpoint: "get-random-motion", parameters: [:])
                let newMotion = MotionModel(
                    id: response["id"] as? String ?? UUID().uuidString,
                    title: response["title"] as? String ?? "Mosi Baru",
                    category: response["category"] as? String ?? "Umum"
                )
                DispatchQueue.main.async { self.motionsList.insert(newMotion, at: 0) }
            } catch {
                print("Error fetching motion: \(error)")
            }
        }
    }
    
    // MARK: - CRUD Case Building Notes
    func saveNote(_ note: CaseBuildingNoteModel) {
        // Jika note sudah ada, update. Jika belum, tambahkan (Create/Update).
        if let index = savedNotes.firstIndex(where: { $0.id == note.id }) {
            savedNotes[index] = note
        } else {
            savedNotes.insert(note, at: 0)
        }
    }
    
    func deleteNote(at offsets: IndexSet) {
        savedNotes.remove(atOffsets: offsets)
    }
    
    func requestFeedback(for noteId: String) {
        if let index = savedNotes.firstIndex(where: { $0.id == noteId }) {
            savedNotes[index].isFeedbackRequested = true
            // Di sini nantinya kamu mengirim notifikasi ke database/API untuk Adjudicator
            print("Feedback requested for note: \(noteId)")
        }
    }
    
    private func loadDummyData() {
        motionsList = [MotionModel(id: "m1", title: "Dewan ini akan melarang penggunaan AI di kampus", category: "Pendidikan")]
        savedNotes = [CaseBuildingNoteModel(id: "n1", motionTitle: "THW ban AI", argumentsRichText: "AI membuat mahasiswa malas...", visibility: .privateAccess, isFeedbackRequested: false, updatedAt: Date())]
    }
}
