//
//  AdjudicatorPendingCard.swift
//  YukDebatCuyy
//

import SwiftUI

/// A card for notes awaiting review.
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
                Text("NEEDS REVIEW").font(.caption2.bold()).foregroundStyle(
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
        .padding(16).background(Color.white).clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        ).padding(.horizontal, 24)
    }
}
#Preview {
    AdjudicatorPendingCard(
        note: CaseBuildingNoteModel(
            id: "1",
            ownerId: "",
            motionTitle: "Motion Title",
            argumentsRichText: "Arguments...",
            visibility: .publicAccess,
            isFeedbackRequested: true,
            updatedAt: Date()
        )
    )
}
