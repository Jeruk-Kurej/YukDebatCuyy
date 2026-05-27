//
//  LocalCoreDataStorage.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Sandboxed simulation of thread-safe local file persistence operations.
class LocalCoreDataStorage: CoreDataStorageProtocol {
    func saveLocalDraft(noteId: String, title: String, content: String) async throws {
        print("Mock CoreData: Draft \(noteId) autosaved locally.")
    }
    
    func executeLRUEviction(maxSizeInBytes: Int) throws {
        print("Mock CoreData: LRU Eviction checked for memory limit.")
    }
}
