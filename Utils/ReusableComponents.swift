//
//  ReusableComponents.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import SwiftUI

/// Reusable button component following the YukDebat interactive standards.
/// Encapsulates styling to adhere to the DRY (Don't Repeat Yourself) principle.


/// Standardized section header for UI typography hierarchy.
struct DesignHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}

/// Dynamic banner for displaying error or success states adhering to NFR Robustness.


// MARK: - Modern iOS Toast / HUD (HIG Compliant)
