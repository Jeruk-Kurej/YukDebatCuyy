//
//  CoreDataStorageProtocol.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Manages local persistent cache for robust offline-first case building mechanisms.
protocol CoreDataStorageProtocol {
    func saveLocalDraft(noteId: String, title: String, content: String) async throws
    func executeLRUEviction(maxSizeInBytes: Int) throws
}
