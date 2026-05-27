//
//  UserRole.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

enum UserRole: String, Codable {
    case debater = "DEBATER"
    case adjudicator = "ADJUDICATOR"
    case promoter = "PROMOTER"
    case admin = "ADMIN"
}
