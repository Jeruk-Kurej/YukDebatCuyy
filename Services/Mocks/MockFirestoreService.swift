//
//  MockFirestoreService.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Mock implementation of Firestore database operations for offline prototyping.
class MockFirestoreService: FirestoreServiceProtocol {
    func saveDocument(collection: String, documentId: String, data: [String: Any]) async throws {
        print("Mock: Saved document to \(collection)")
    }
    
    func updateTransactional(collection: String, documentId: String, data: [String: Any]) async throws {
        print("Mock: Transactional update executed")
    }
    
    func deleteDocument(collection: String, documentId: String) async throws {
        print("Mock: Deleted document from \(collection)")
    }
    
    func attachSnapshotListener(collection: String, documentId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Dummy data lobi untuk testing UI
        let dummyLobby: [String: Any] = [
            "id": documentId,
            "hostId": "user_dummy_1",
            "motionCategory": "Pendidikan",
            "state": "PREPARING"
        ]
        completion(.success(dummyLobby))
    }
}
