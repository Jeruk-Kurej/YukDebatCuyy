//
//  RegMode.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Defines whether a participant joins a sparring room individually or with a teammate.
enum RegMode: String, Codable {
    case solo = "SOLO"
    case team = "TEAM"
}
