//
//  MockCloudStorage.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Mock implementation for cloud blob media storage.
class MockCloudStorage: CloudStorageProtocol {
    // MARK: - Methods
    func uploadPosterFile(fileData: Data) async throws -> String {
        // PERBAIKAN: Indentasi dikembalikan menjadi 4 spasi
        try await Task.sleep(nanoseconds: 500_000_000)
        return "https://dummy-storage.com/posters/poster_\(UUID().uuidString).jpg"
    }
    
    func deletePosterFile(fileUrl: String) async throws {
        print("Mock: Deleted poster at \(fileUrl)")
    }
}
