//
//  AdminPendingCard.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 30/05/26.
//

import SwiftUI

// KARTU PENDING (Besar, Mewah, Ada Data User)
struct AdminPendingCard: View {
    let comp: CompetitionModel
    let onAction: (AdminAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 1. INFO PENDAFTAR (SUBMITTER)
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.accentWalnut)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Submitted by").font(.caption2).foregroundStyle(
                        .secondary
                    )
                    Text(comp.promoterEmail ?? "User").font(.subheadline.bold())
                        .foregroundStyle(Color.textCharcoal)
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 16)

            // 2. POSTER LOMBA
            if !comp.posterStorageUrl.isEmpty {
                if comp.posterStorageUrl.starts(with: "http") {
                    AsyncImage(url: URL(string: comp.posterStorageUrl)) {
                        image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 180).frame(maxWidth: .infinity).clipped()
                } else if let imageData = Data(
                    base64Encoded: comp.posterStorageUrl,
                    options: .ignoreUnknownCharacters
                ),
                    let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                        .frame(height: 180).frame(maxWidth: .infinity).clipped()
                }
            }

            // 3. DETAIL LOMBA
            VStack(alignment: .leading, spacing: 6) {
                Text(comp.name).font(.title3.bold()).foregroundStyle(
                    Color.textCharcoal
                )
                Text(comp.description).font(.subheadline).foregroundStyle(
                    .secondary
                ).lineLimit(3)
            }
            .padding(.horizontal, 16)

            // 4. TOMBOL AKSI
            HStack(spacing: 12) {
                Button(action: { onAction(.reject) }) {
                    Text("Reject").font(.subheadline.bold()).frame(
                        maxWidth: .infinity
                    ).padding(.vertical, 12)
                        .background(Color.btnNegative.opacity(0.1))
                        .foregroundStyle(Color.btnNegative).clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
                }
                Button(action: { onAction(.approve) }) {
                    Text("Approve").font(.subheadline.bold()).frame(
                        maxWidth: .infinity
                    ).padding(.vertical, 12)
                        .background(Color.btnPositive).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
        .padding(.horizontal, 20)
    }
}
