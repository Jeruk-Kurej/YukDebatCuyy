//
//  CompetitionView.swift
//  YukDebatCuyy
//

import SwiftUI

/// The main feed for browsing active competitions and viewing pending submissions.
struct CompetitionView: View {

    // MARK: - Properties

    @StateObject private var viewModel = CompetitionViewModel()
    @State private var showUploadForm = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if !viewModel.myPendingCompetitions.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Pending Admin Approval")
                                    .font(.headline)
                                    .foregroundStyle(Color.textCharcoal)
                                    .padding(.horizontal, 24)

                                ForEach(viewModel.myPendingCompetitions) {
                                    comp in
                                    CompetitionCard(comp: comp, isPending: true)
                                }
                            }
                        }

                        VStack(alignment: .leading) {
                            Text(
                                viewModel.activeCompetitions.isEmpty
                                    ? "No active competitions."
                                    : "Latest Competitions"
                            )
                            .font(.headline)
                            .foregroundStyle(Color.textCharcoal)
                            .padding(.horizontal, 24)

                            ForEach(viewModel.activeCompetitions) { comp in
                                CompetitionCard(comp: comp, isPending: false)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }

                Button(action: { showUploadForm = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.btnPositive)
                        .clipShape(Circle())
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
                .padding(.trailing, 24)
                .padding(.bottom, 110)
            }
            .navigationTitle("Competitions")
            .onAppear { viewModel.fetchCompetitions() }
            .sheet(isPresented: $showUploadForm) {
                UploadFormCompetition(viewModel: viewModel)
            }
            .modernToast(
                message: $viewModel.statusMsg,
                isError: viewModel.statusMsg?.contains("Failed") == true
                    || viewModel.statusMsg?.contains("Select") == true
            )
        }
    }
}

// MARK: - Preview
#Preview {
    CompetitionView()
}
