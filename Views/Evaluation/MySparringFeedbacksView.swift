//
//  MySparringFeedbacksView.swift
//  YukDebatCuyy
//

import SwiftUI

/// Displays narrative feedbacks received by the Debater from Adjudicators after sparring sessions.
struct MySparringFeedbacksView: View {

    // MARK: - Properties

    @StateObject private var viewModel = EvaluationViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 16) {
                    if viewModel.mySparringEvaluations.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "star.bubble.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.purple.opacity(0.3))

                            Text("No feedbacks yet.")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 80)
                    } else {
                        ForEach(viewModel.mySparringEvaluations) { eval in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(
                                        eval.createdAt.formatted(
                                            date: .abbreviated,
                                            time: .shortened
                                        )
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Image(systemName: "briefcase.fill")
                                        Text(eval.adjudicatorId)
                                    }
                                    .font(.caption2.bold())
                                    .foregroundStyle(.purple)
                                    .padding(.horizontal, 8).padding(
                                        .vertical,
                                        4
                                    )
                                    .background(Color.purple.opacity(0.1))
                                    .clipShape(Capsule())
                                }

                                Text("Feedback:")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.textCharcoal)

                                Text(eval.narrativeFeedback)
                                    .font(.body)
                                    .foregroundStyle(Color.textCharcoal)
                                    .lineSpacing(4)
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
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Sparring Feedbacks")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = authVM.currentUser?.id {
                viewModel.fetchMySparringEvaluations(userId: userId)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MySparringFeedbacksView()
        .environmentObject(AuthViewModel())
}
