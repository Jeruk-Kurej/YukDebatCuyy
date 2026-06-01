//
//  RoomState.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Represents the current life-cycle state of a sparring room.
enum RoomState: String, Codable {
    case waiting = "WAITING"
    case preparing = "PREPARING"
    case ongoing = "ONGOING"
    case done = "DONE"
    case cancelled = "CANCELLED"
}
