//
//  AdjudicatorRequestModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 30/05/26.
//

import FirebaseFirestore
import Foundation

/// Model untuk menyimpan data pengajuan seorang debater menjadi Juri (Adjudicator).
struct AdjudicatorRequestModel: Identifiable, Equatable {
    // MARK: - Properties
    let id: String
    let userId: String
    let userEmail: String
    let fullName: String
    let experience: String
    let certificateUrl: String
    var status: ReviewStatus
    let submittedAt: Date
}
