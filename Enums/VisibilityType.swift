//
//  VisibilityType.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Defines the access control level for notes, sparring rooms, or user-generated content.
enum VisibilityType: String, Codable {
    case publicAccess = "PUBLIC"
    case privateAccess = "PRIVATE"
}
