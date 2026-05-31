//
//  AdminAdjudicatorHistoryRow.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct AdminAdjudicatorHistoryRow: View {
    let req: AdjudicatorRequestModel

    var body: some View {
        HStack(spacing: 16) {
            // AVATAR KECIL
            ZStack {
                Circle().fill(Color.purple.opacity(0.2))
                Image(systemName: "briefcase.fill")
                    .foregroundStyle(.purple)
            }
            .frame(width: 48, height: 48)

            // INFO
            VStack(alignment: .leading, spacing: 4) {
                Text(req.fullName).font(.headline).foregroundStyle(
                    Color.textCharcoal
                ).lineLimit(1)
                Text(req.userEmail).font(.caption).foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()

            // STATUS BADGE STATIS (Bukan Tombol)
            Image(systemName: "checkmark")
                .font(.title2).foregroundStyle(Color.btnPositive)
        }
        .padding(16).background(Color.white).clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .padding(.horizontal, 20)
    }
}
