//
//  ReviewStatus.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Represents the moderation status of user-submitted content or adjudicator requests.
enum ReviewStatus: String, Codable {
    case pending = "PENDING"
    case active = "ACTIVE"
    case rejected = "REJECTED"
}
