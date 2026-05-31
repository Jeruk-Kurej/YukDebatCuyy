//
//  ProfileMenuRow.swift
//  YukDebatCuyy
//

import SwiftUI

/// A reusable UI component representing a single row in the profile settings menu.
/// Ensures consistent typography, spacing, and icon alignment.
struct ProfileMenuRow: View {

    // MARK: - Properties

    let icon: String
    let title: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentWalnut)
                .frame(width: 24)

            Text(title)
                .font(.system(.body, design: .default, weight: .medium))
                .foregroundStyle(Color.textCharcoal)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(Color.gray.opacity(0.5))
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        ProfileMenuRow(
            icon: "person.text.rectangle",
            title: "Edit Account Information"
        )
        Divider().padding(.leading, 40)
        ProfileMenuRow(icon: "bell.badge.fill", title: "System Notifications")
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .background(Color.bgCream)
}
