//
//  MotionRequestModel.swift
//  YukDebatCuyy
//

import Foundation

/// Defines the structure for a custom motion submitted by a Debater.
/// Used to facilitate the Admin moderation workflow (FR-6.1).
struct MotionRequestModel: Codable, Identifiable {

    // MARK: - Properties

    let id: String
    let title: String
    let category: String
    let submitterId: String
    var status: ReviewStatus
    let submittedAt: Date
}
