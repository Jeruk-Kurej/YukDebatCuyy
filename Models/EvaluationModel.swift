//
//  EvaluationModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Stores adjudicator feedback and numerical scores for a sparring session or case-building note.
/// Provides built-in logic to determine team rankings to keep business rules in the Model layer.
struct EvaluationModel: Codable, Identifiable {
    let id: String
    let targetId: String
    let adjudicatorId: String
    var speakerScores: [String: Int]
    var narrativeFeedback: String
    let createdAt: Date
    
    /// Calculates the rank of each team based on the accumulated speaker scores.
    func calculateTeamRankings() -> [String: Int] {
        // TODO: Sum scores per team and rank them
        return [:]
    }
}
