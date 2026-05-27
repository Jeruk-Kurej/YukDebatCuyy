//
//  UserModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Represents the user's identity and system access rights.
/// Crucial for authorizing actions like moderation (Admin) or adjudication (Adjudicator).
struct UserModel: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var role: UserRole
    var isActive: Bool
    let createdAt: Date
}
