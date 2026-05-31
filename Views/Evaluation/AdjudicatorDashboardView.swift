import SwiftUI

struct AdjudicatorDashboardView: View {
    @ObservedObject var motionViewModel: MotionArchiveViewModel
    @StateObject private var evalVM = EvaluationViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedNote: CaseBuildingNoteModel? = nil
    @State private var selectedTab = 0  // 0: Pending, 1: History

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // SEGMENTED CONTROL HIG STYLE
                    Picker("Juri Tabs", selection: $selectedTab) {
                        Text("Butuh Review").tag(0)
                        Text("History Review").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.bgCream)

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if selectedTab == 0 {
                                // --- TAB 0: PENDING REQUESTS ---
                                if evalVM.pendingRequests.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 60))
                                            .foregroundStyle(
                                                .purple.opacity(0.5)
                                            )
                                        Text("Semua beres!").font(
                                            .title3.bold()
                                        )
                                        Text(
                                            "Tidak ada permintaan ulasan dari debater saat ini."
                                        ).font(.subheadline).foregroundStyle(
                                            .secondary
                                        ).multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 80)
                                } else {
                                    ForEach(evalVM.pendingRequests) { note in
                                        Button(action: {
                                            selectedNote = note
                                        }) {
                                            AdjudicatorPendingCard(note: note)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            } else {
                                // --- TAB 1: HISTORY REVIEW ---
                                if evalVM.historyRequests.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "clock.fill").font(
                                            .system(size: 60)
                                        ).foregroundStyle(.gray.opacity(0.5))
                                        Text("Belum ada history.").font(
                                            .title3.bold()
                                        )
                                        Text(
                                            "Anda belum memberikan feedback pada catatan manapun."
                                        ).font(.subheadline).foregroundStyle(
                                            .secondary
                                        ).multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 80)
                                } else {
                                    ForEach(evalVM.historyRequests) { note in
                                        AdjudicatorHistoryCard(note: note)  // Read-only card
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationTitle("Dashboard Juri")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                evalVM.fetchPendingFeedbacks()
                // Panggil history berdasarkan nama juri yang login
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


