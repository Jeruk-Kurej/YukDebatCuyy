//
//  MotionExplorerViewModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation
import Combine

/// Manages the state and logic for fetching and archiving debate motions (UC03).
/// Adheres to Dependency Inversion via CloudFunctionsProtocol and Repository Pattern.
class MotionExplorerViewModel: ObservableObject {
    
    // Dependencies matching the Class Diagram
    private let apiProxy: CloudFunctionsProtocol
    private let localCache: CoreDataStorageProtocol
    
    // Published Properties
    @Published var motionsList: [MotionModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init(apiProxy: CloudFunctionsProtocol, localCache: CoreDataStorageProtocol) {
        self.apiProxy = apiProxy
        self.localCache = localCache
    }
    
    func triggerFetchMotion() {
        self.isLoading = true
        self.errorMessage = nil
        
        Task {
            do {
                // Proxies external request to hide API keys securely
                let data = try await apiProxy.callExternalAPI(endpoint: "/api/random-motion", parameters: [:])
                
                let newMotion = MotionModel(
                    id: data["id"] as? String ?? UUID().uuidString,
                    title: data["title"] as? String ?? "Mosi tidak ditemukan",
                    category: data["category"] as? String ?? "Umum",
                    isWishlisted: false
                )
                
                DispatchQueue.main.async {
                    // Memasukkan mosi baru di urutan teratas array
                    self.motionsList.insert(newMotion, at: 0)
                    self.isLoading = false
                }
            } catch {
                self.loadFallbackLocal()
            }
        }
    }
    
    func saveToWishlist(motion: MotionModel) {
        // Toggle status wishlist di UI
        if let index = motionsList.firstIndex(where: { $0.id == motion.id }) {
            motionsList[index].isWishlisted.toggle()
            // Di skenario nyata, ini akan disave ke lokal/cloud
        }
    }
    
    private func loadFallbackLocal() {
        DispatchQueue.main.async {
            self.errorMessage = "Koneksi API gagal (Timeout). Menampilkan data fallback lokal."
            self.isLoading = false
            // Simulasi memuat mosi dari cache SQLite
        }
    }
}
