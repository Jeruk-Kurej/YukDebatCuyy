//
//  CloudStorageProtocol.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Outlines media storage actions for uploading and removing large binary objects.
protocol CloudStorageProtocol {
    func uploadPosterFile(fileData: Data) async throws -> String
    func deletePosterFile(fileUrl: String) async throws
}
