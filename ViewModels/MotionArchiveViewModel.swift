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
        loadDummyData()
    }
    
    // Computed Property untuk Fitur Search Real-time (FR-3.2)
    var filteredMotions: [MotionModel] {
        if searchText.isEmpty { return motionsList }
        return motionsList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredNotes: [CaseBuildingNoteModel] {
        if searchText.isEmpty { return savedNotes }
        return savedNotes.filter { $0.motionTitle.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - Motion Logic (Generate UC03)
    func triggerFetchMotion() {
        Task {
            do {
                let response = try await apiProxy.callExternalAPI(endpoint: "get-random-motion", parameters: [:])
                
                // Perbaikan: Menyertakan isWishlisted agar sesuai dengan MotionModel.swift
                let newMotion = MotionModel(
                    id: response["id"] as? String ?? UUID().uuidString,
                    title: response["title"] as? String ?? "Mosi Baru",
                    category: response["category"] as? String ?? "Umum",
                    isWishlisted: false
                )
                
                DispatchQueue.main.async {
                    self.motionsList.insert(newMotion, at: 0)
                }
            } catch {
                print("Error fetching motion from Proxy Cloud: \(error)")
            }
        }
    }
    
    // MARK: - CRUD Case Building Notes (UC01)
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
    
    // MARK: - Evaluation Feedback Link (UC04 Integration)
    func requestFeedback(for noteId: String) {
        if let index = savedNotes.firstIndex(where: { $0.id == noteId }) {
            savedNotes[index].isFeedbackRequested = true
            print("Sukses menautkan note \(noteId) ke antrean Adjudicator.")
        }
    }
    
    private func loadDummyData() {
        motionsList = [
            MotionModel(id: "m1", title: "Dewan ini akan melarang penggunaan AI sebagai instrumen kelulusan di Universitas Ciputra", category: "Pendidikan & Teknologi", isWishlisted: false)
        ]
        savedNotes = [
            CaseBuildingNoteModel(id: "n1", ownerId: "user_me", motionTitle: "THW ban AI in Universities", argumentsRichText: "Argumen dasar: Penggunaan kecerdasan buatan yang tidak terukur dapat mengikis fondasi pemikiran kritis mahasiswa Informatika.", visibility: .privateAccess, isFeedbackRequested: false, updatedAt: Date())
        ]
    }
}
