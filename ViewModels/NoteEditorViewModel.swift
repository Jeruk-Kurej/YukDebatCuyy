//
//  CaseBuildingViewModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation
import Combine

/// Handles reactive state for the Case Building editor (UC01).
/// Synchronizes data to Cloud Firestore or local CoreData based on network availability.
class NoteEditorViewModel: ObservableObject {
    
    // Dependency Injection Protocols
    private let dbService: FirestoreServiceProtocol
    private let localCache: CoreDataStorageProtocol
    
    // Published properties based strictly on Class Diagram
    @Published var currentNote: CaseBuildingNoteModel
    @Published var saveStatus: String? = nil
    @Published var isOffline: Bool = false
    
    init(dbService: FirestoreServiceProtocol, localCache: CoreDataStorageProtocol) {
        self.dbService = dbService
        self.localCache = localCache
        
        // Inisialisasi model catatan kosong saat layar pertama dibuka
        self.currentNote = CaseBuildingNoteModel(
            id: UUID().uuidString,
            ownerId: "user_dummy",
            motionTitle: "",
            argumentsRichText: "",
            visibility: .privateAccess,
            isFeedbackRequested: false,
            updatedAt: Date()
        )
    }
    
    // MARK: - Intents
    
    func initNoteState(noteId: String) {
        // Logika untuk memuat data note yang sudah ada
    }
    
    func updateVisibility(isPublic: Bool) {
        currentNote.visibility = isPublic ? .publicAccess : .privateAccess
    }
    
    func requestFeedback() {
        guard currentNote.visibility == .publicAccess else {
            self.saveStatus = "Ubah visibilitas menjadi Publik sebelum meminta evaluasi."
            self.isOffline = true
            return
        }
        self.saveStatus = "Permintaan evaluasi berhasil dikirim ke antrean Juri."
        self.isOffline = false
    }
    
    private func bindDataOnChange() {
        // Logika internal untuk auto-save (memenuhi NFR-5.1)
    }
    
    private func autoSaveDraftLocal() {
        // Eksekusi core data
    }
    
    func pushDataCloud() {
        // Validasi input sebelum menyimpan
        guard currentNote.validateContent() else {
            self.saveStatus = "Judul mosi dan argumen (min. 50 karakter) tidak boleh kosong."
            self.isOffline = true // Menggunakan warna merah (error) dari isOffline
            return
        }
        
        Task {
            do {
                // Strategy 1: Attempt Cloud Save
                let data: [String: Any] = [
                    "title": currentNote.motionTitle,
                    "content": currentNote.argumentsRichText
                ]
                try await dbService.saveDocument(collection: "notes", documentId: currentNote.id, data: data)
                
                DispatchQueue.main.async {
                    self.isOffline = false
                    self.saveStatus = "Catatan berhasil tersimpan di Cloud."
                }
            } catch {
                // Strategy 2: Fallback to Local Storage on network failure
                do {
                    try await localCache.saveLocalDraft(noteId: currentNote.id, title: currentNote.motionTitle, content: currentNote.argumentsRichText)
                    
                    DispatchQueue.main.async {
                        self.isOffline = true
                        self.saveStatus = "Koneksi terputus. Draf disimpan secara aman di perangkat."
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isOffline = true
                        self.saveStatus = "Gagal menyimpan data secara total."
                    }
                }
            }
        }
    }
}
