//
//  CaseBuildingNoteModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Defines the structure for debater strategy notes.
/// Includes visibility and feedback states to fulfill UC01 and UC04 integration.
struct CaseBuildingNoteModel: Codable, Identifiable {
    // MARK: - Properties
    let id: String
    var ownerId: String
    var motionTitle: String
    var argumentsRichText: String
    var visibility: VisibilityType
    
    // Boolean variables strictly use 'is', 'has', 'should', or 'can' prefix
    var isFeedbackRequested: Bool
    var updatedAt: Date

    var feedbackText: String?
    var feedbackProviderName: String?

    // MARK: - Methods
    /// Validates if the note has sufficient content before allowing cloud synchronization.
    func validateContent() -> Bool {
        return !motionTitle.isEmpty && argumentsRichText.count >= 50
    }
}
