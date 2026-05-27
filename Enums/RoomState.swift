//
//  RoomState.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

enum RoomState: String, Codable {
    case preparing = "PREPARING"
    case ongoing = "ONGOING"
    case done = "DONE"
    case cancelled = "CANCELLED"
}
