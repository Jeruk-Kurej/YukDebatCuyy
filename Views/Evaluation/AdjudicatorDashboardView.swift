//
//  AdjudicatorDashboardView.swift
//  YukDebatCuyy
//

import SwiftUI

/// The central workspace for Adjudicators to review debater case building notes.
struct AdjudicatorDashboardView: View {

    // MARK: - Properties

    @ObservedObject var motionViewModel: MotionArchiveViewModel
    @StateObject private var evalVM = EvaluationViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedNote: CaseBuildingNoteModel? = nil
    @State private var selectedTab = 0

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("Adjudicator Tabs", selection: $selectedTab) {
                        Text("Needs Review").tag(0)
                        Text("Review History").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.bgCream)

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if selectedTab == 0 {
                                if evalVM.pendingRequests.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 60))
                                            .foregroundStyle(
                                                .purple.opacity(0.5)
                                            )
                                        Text("All caught up!").font(
                                            .title3.bold()
                                        )
                                        Text(
                                            "No review requests from debaters at the moment."
                                        ).font(.subheadline).foregroundStyle(
                                            .secondary
                                        ).multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 80)
                                } else {
                                    ForEach(evalVM.pendingRequests) { note in
                                        Button(action: { selectedNote = note })
                                        {
                                            AdjudicatorPendingCard(note: note)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            } else {
                                if evalVM.historyRequests.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "clock.fill").font(
                                            .system(size: 60)
                                        ).foregroundStyle(.gray.opacity(0.5))
                                        Text("No history yet.").font(
                                            .title3.bold()
                                        )
                                        Text(
                                            "You haven't provided feedback on any notes."
                                        ).font(.subheadline).foregroundStyle(
                                            .secondary
                                        ).multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 80)
                                } else {
                                    ForEach(evalVM.historyRequests) { note in
                                        AdjudicatorHistoryCard(note: note)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationTitle("Adjudicator Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                evalVM.fetchPendingFeedbacks()
                if let juriName = authVM.currentUser?.name {
                    evalVM.fetchEvaluationHistory(providerName: juriName)
                }
            }
            .sheet(item: $selectedNote) { note in
                ProvideFeedbackSheet(note: note, evalVM: evalVM)
                    .environmentObject(authVM)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AdjudicatorDashboardView(
        motionViewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
    .environmentObject(AuthViewModel())
}
