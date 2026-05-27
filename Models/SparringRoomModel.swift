//
//  ParticipantModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Represents the data structure for a Sparring Room (open spar) session.
/// Contains pure domain logic without any database or UI code.
struct SparringRoomModel: Codable, Identifiable {
    let id: String
    let hostId: String
    let scheduledTime: Date
    let motionCategory: String
    let specialNotes: String
    let needAdjudicator: Bool
    let meetingLink: String
    let accessType: VisibilityType
    var state: RoomState
    var participants: [ParticipantModel]
    
    /// Checks if the room has reached its maximum capacity (8 participants for BP).
    func isRoomFull() -> Bool {
        return participants.count >= 8
    }
    
    /// Validates if the room has an even number of complete teams.
    func hasIdealTeams() -> Bool {
        return participants.count > 0 && participants.count % 2 == 0
    }
}
