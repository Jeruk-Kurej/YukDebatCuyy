//
//  CompetitionModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Encapsulates all details regarding a debate competition uploaded by a Promoter.
/// Includes the ReviewStatus to support the Admin moderation workflow before going public.
struct CompetitionModel: Codable, Identifiable {
    let id: String
    let promoterId: String
    var name: String
    var description: String
    var eventDate: Date
    var registrationUrl: String
    var posterStorageUrl: String
    var status: ReviewStatus
}
