//
//  RoleSlotType.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Represents the specific debate position or role assigned to a participant in a British Parliamentary (BP) format.
enum RoleSlotType: String, Codable {
    case openingGovt = "OG"
    case openingOpp = "OO"
    case closingGovt = "CG"
    case closingOpp = "CO"
}
