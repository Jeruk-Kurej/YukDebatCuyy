//
//  MotionModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import Foundation

/// Holds the data for a debate motion fetched from the external API or local fallback.
/// Separated to manage wishlist state efficiently without cluttering user profiles.
struct MotionModel: Codable, Identifiable {
    let id: String
    let title: String
    let category: String
    var isWishlisted: Bool
}
