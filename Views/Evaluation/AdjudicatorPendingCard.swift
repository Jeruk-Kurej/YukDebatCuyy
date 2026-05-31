//
//  AdjudicatorPendingCard.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct AdjudicatorPendingCard: View {
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
                Text("BUTUH REVIEW").font(.caption2.bold()).foregroundStyle(
                    .white
                ).padding(.horizontal, 8).padding(.vertical, 4).background(
                    Color.purple
                ).clipShape(Capsule())
            }
            Text(note.motionTitle).font(.headline).foregroundStyle(
                Color.textCharcoal
            ).lineLimit(2).multilineTextAlignment(.leading)
            Text(note.argumentsRichText).font(.subheadline).foregroundStyle(
                .secondary
            ).lineLimit(2).multilineTextAlignment(.leading)
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
