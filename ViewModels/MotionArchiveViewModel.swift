//
//  MotionArchiveViewModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import Foundation
import Combine
import SwiftUI

class MotionArchiveViewModel: ObservableObject {
    @Published var motionsList: [MotionModel] = []
    @Published var savedNotes: [CaseBuildingNoteModel] = []
    @Published var searchText: String = ""
    
    // State untuk interaktivitas tombol & Mencegah Spam
    @Published var isGenerating: Bool = false
    
    private let apiProxy: CloudFunctionsProtocol
    private let localCache: CoreDataStorageProtocol
    
    init(apiProxy: CloudFunctionsProtocol, localCache: CoreDataStorageProtocol) {
        self.apiProxy = apiProxy
        self.localCache = localCache
        loadDummyData()
    }
    
    var filteredMotions: [MotionModel] {
        if searchText.isEmpty { return motionsList }
        return motionsList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredNotes: [CaseBuildingNoteModel] {
        if searchText.isEmpty { return savedNotes }
        return savedNotes.filter { $0.motionTitle.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - Motion Logic (Generate dengan Anti-Spam Cooldown)
    func triggerFetchMotion() {
        guard !isGenerating else { return } // Mencegah klik bertubi-tubi
        isGenerating = true
        
        Task {
            do {
                let response = try await apiProxy.callExternalAPI(endpoint: "get-random-motion", parameters: [:])
                let newMotion = MotionModel(
                    id: response["id"] as? String ?? UUID().uuidString,
                    title: response["title"] as? String ?? "Mosi Baru",
                    category: response["category"] as? String ?? "Umum",
                    isWishlisted: false
                )
                
                DispatchQueue.main.async {
                    self.motionsList.insert(newMotion, at: 0)
                }
                
                // Mencegah Glitch UI: Paksa cooldown 0.6 detik sebelum bisa diklik lagi
                try await Task.sleep(nanoseconds: 600_000_000)
                
                DispatchQueue.main.async { self.isGenerating = false }
                
            } catch {
                DispatchQueue.main.async { self.isGenerating = false }
                print("Error fetching motion: \(error)")
            }
        }
    }
    
    // MARK: - Pindah Mosi ke My Notes (Perbaikan Interaktif)
    func createNoteFromMotion(_ motion: MotionModel) {
        // Cegah duplikasi jika sudah pernah di-save
        guard !savedNotes.contains(where: { $0.motionTitle == motion.title }) else { return }
        
        let newNote = CaseBuildingNoteModel(
            id: UUID().uuidString,
            ownerId: "user_me",
            motionTitle: motion.title,
            argumentsRichText: "",
            visibility: .privateAccess,
            isFeedbackRequested: false,
            updatedAt: Date()
        )
        
        // Ubah status tombol di List
        if let idx = motionsList.firstIndex(where: { $0.id == motion.id }) {
            motionsList[idx].isWishlisted = true
        }
        
        savedNotes.insert(newNote, at: 0)
    }
    
    // MARK: - CRUD Normal
    func saveNote(_ note: CaseBuildingNoteModel) {
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
        }
    }
    
    private func loadDummyData() {
        motionsList = [
            MotionModel(id: "m1", title: "Dewan ini akan melarang penggunaan AI sebagai instrumen kelulusan", category: "Pendidikan & Teknologi", isWishlisted: false)
        ]
        savedNotes = [
            CaseBuildingNoteModel(id: "n1", ownerId: "user_me", motionTitle: "THW ban AI in Universities", argumentsRichText: "Argumen 1: ...", visibility: .privateAccess, isFeedbackRequested: false, updatedAt: Date())
        ]
    }
}
