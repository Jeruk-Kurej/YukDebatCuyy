//
//  UserRole.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Defines the access level and role-based permissions of a user within the application.
enum UserRole: String, Codable {
    case debater = "DEBATER"
    case adjudicator = "ADJUDICATOR"
    case promoter = "PROMOTER"
    case admin = "ADMIN"
}
