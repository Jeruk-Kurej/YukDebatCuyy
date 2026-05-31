//
//  NoteCard.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct NoteCard: View {
    let note: CaseBuildingNoteModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    Image(
                        systemName: note.visibility == .publicAccess
                            ? "globe" : "lock.fill"
                    )
                    Text(note.visibility == .publicAccess ? "PUBLIK" : "PRIVAT")
                }
                .font(.caption.bold())
                .foregroundStyle(
                    note.visibility == .publicAccess
                        ? Color.btnPositive : Color.btnNegative
                )
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(
                    note.visibility == .publicAccess
                        ? Color.btnPositive.opacity(0.1)
                        : Color.btnNegative.opacity(0.1)
                )
                .clipShape(Capsule())

                Spacer()

                Text(note.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(note.motionTitle)
                .font(.headline)
                .foregroundStyle(Color.textCharcoal)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 4)
    }
}
