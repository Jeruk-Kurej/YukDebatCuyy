//
//  AdjudicatorHistoryCard.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct AdjudicatorHistoryCard: View {
    let note: CaseBuildingNoteModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(
                    note.updatedAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                ).font(.caption).foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("SUDAH DI-REVIEW")
                }
                .font(.caption2.bold()).foregroundStyle(Color.btnPositive)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.btnPositive.opacity(0.1)).clipShape(Capsule())
            }
            Text(note.motionTitle).font(.headline).foregroundStyle(
                Color.textCharcoal
            ).lineLimit(2).multilineTextAlignment(.leading)

            // Tampilkan cuplikan feedback yang diberikan Juri
            if let feedback = note.feedbackText {
                Divider()
                Text("Feedback Anda:").font(.caption.bold()).foregroundStyle(
                    .purple
                )
                Text(feedback).font(.subheadline).foregroundStyle(
                    Color.textCharcoal
                ).lineLimit(3).multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .padding(.horizontal, 24)
    }
}
