//
//  Color.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import SwiftUI

/// Extends standard Color to provide a Single Source of Truth for YukDebat's design system.
/// This prevents hardcoding hex values across different View files.
extension Color {
    static let bgCream = Color(red: 244 / 255, green: 241 / 255, blue: 234 / 255)
    static let textCharcoal = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
    static let btnPositive = Color(red: 58 / 255, green: 90 / 255, blue: 64 / 255)
    static let btnNeutral = Color(red: 43 / 255, green: 58 / 255, blue: 74 / 255)
    static let btnNegative = Color(red: 169 / 255, green: 74 / 255, blue: 74 / 255)
    static let accentWalnut = Color(red: 92 / 255, green: 64 / 255, blue: 51 / 255)
}
