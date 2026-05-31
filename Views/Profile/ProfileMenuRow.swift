//
//  ProfileMenuRow.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 30/05/26.
//

import SwiftUI

struct ProfileMenuRow: View {
    let icon: String
    let title: String
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
