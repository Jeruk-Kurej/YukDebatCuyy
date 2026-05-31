//
//  CompetitionCard.swift
//  YukDebatCuyy
//

import SwiftUI

/// A card displaying a competition's poster, name, and current status.
struct CompetitionCard: View {

    // MARK: - Properties

    let comp: CompetitionModel
    let isPending: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if comp.posterStorageUrl.starts(with: "http") {
                AsyncImage(url: URL(string: comp.posterStorageUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()
            } else if let imageData = Data(
                base64Encoded: comp.posterStorageUrl,
                options: .ignoreUnknownCharacters
            ),
                let uiImage = UIImage(data: imageData)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(comp.name)
                        .font(.title3.bold())
                        .foregroundStyle(Color.textCharcoal)
                        .lineLimit(1)

                    Spacer()

                    if isPending {
                        Text("PENDING")
                            .font(.caption2.bold())
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.orange.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }

                Text(comp.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(16)
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
        .padding(.horizontal, 24)
        .padding(.vertical, 6)
    }
}

// MARK: - Preview
#Preview {
    CompetitionCard(
        comp: CompetitionModel(
            id: "1",
            promoterId: "1",
            name: "NUDC 2026",
            description: "National University Debating Championship",
            eventDate: Date(),
            registrationUrl: "",
            posterStorageUrl: "",
            status: .active
        ),
        isPending: false
    )
}
