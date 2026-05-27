//
//  CompetitionCard.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct CompetitionCard: View {
    let comp: CompetitionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(comp.name)
                .font(.system(.title3, design: .serif, weight: .bold))

            Text(comp.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Link(
                "Daftar Sekarang",
                destination: URL(string: comp.registrationUrl) ?? URL(
                    string: "https://google.com"
                )!
            )
            .font(.subheadline.bold())
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.btnPositive)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CompetitionCard(
        comp: CompetitionModel(
            id: "1",
            promoterId: "P1",
            name: "Debat Nasional",
            description: "Lomba besar",
            eventDate: Date(),
            registrationUrl: "",
            posterStorageUrl: "",
            status: .active
        )
    )
    .padding()
}
