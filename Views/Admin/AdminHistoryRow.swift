//
//  AdminHistoryRow.swift
//  YukDebatCuyy
//

import SwiftUI

/// A read-only row displaying a previously approved competition.
struct AdminHistoryRow: View {
    let comp: CompetitionModel
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if comp.posterStorageUrl.starts(with: "http") {
                    AsyncImage(url: URL(string: comp.posterStorageUrl)) {
                        image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                } else if let imageData = Data(
                    base64Encoded: comp.posterStorageUrl,
                    options: .ignoreUnknownCharacters
                ), let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 60, height: 60).clipShape(
                RoundedRectangle(cornerRadius: 8)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(comp.name).font(.headline).foregroundStyle(
                    Color.textCharcoal
                ).lineLimit(1)
                Text(comp.promoterEmail ?? "User").font(.caption)
                    .foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Image(systemName: "checkmark").font(.title2)
                .foregroundStyle(Color.btnPositive)
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
#Preview {
    AdminHistoryRow(
        comp: CompetitionModel(
            id: "1",
            promoterId: "u1",
            name: "Test Comp",
            description: "",
            eventDate: Date(),
            registrationUrl: "",
            posterStorageUrl: "",
            status: .active
        )
    )
}
