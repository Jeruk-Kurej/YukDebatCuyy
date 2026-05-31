//
//  AdminAdjudicatorRow.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 30/05/26.
//

import SwiftUI

struct AdminAdjudicatorRow: View {
    let req: AdjudicatorRequestModel
    let onApprove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "briefcase.fill").foregroundStyle(.purple)
                VStack(alignment: .leading) {
                    Text(req.fullName).font(.subheadline.bold())
                    Text(req.userEmail).font(.caption).foregroundStyle(
                        .secondary
                    )
                }
            }
            .padding(.horizontal, 16).padding(.top, 16)

            if let imageData = Data(
                base64Encoded: req.certificateUrl,
                options: .ignoreUnknownCharacters
            ),
                let uiImage = UIImage(data: imageData)
            {
                Image(uiImage: uiImage).resizable().scaledToFill()
                    .frame(height: 150).frame(maxWidth: .infinity).clipped()
            }

            Text(req.experience).font(.subheadline).foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            Button(action: onApprove) {
                Text("Approve to Adjudicator").font(.subheadline.bold()).frame(
                    maxWidth: .infinity
                ).padding(.vertical, 12)
                    .background(Color.purple).foregroundStyle(.white).clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
            }
            .padding(16)
        }
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .padding(.horizontal, 20)
    }
}
