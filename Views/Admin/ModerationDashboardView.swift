import SwiftUI

struct ModerationDashboardView: View {
    @ObservedObject var viewModel: ModerationDashboardViewModel
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("Admin Tabs", selection: $selectedTab) {
                        Text("Pending Approval").tag(0)
                        Text("Approved History").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.bgCream)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            if selectedTab == 0 {
                                // --- SEKSI 1: KOMPETISI PENDING ---
                                Section(
                                    header: Text("Competitions").font(
                                        .subheadline.bold()
                                    ).foregroundStyle(.orange).padding(
                                        .horizontal,
                                        24
                                    ).frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                ) {
                                    if viewModel.pendingList.isEmpty {
                                        Text("No pending competitions.").font(
                                            .caption
                                        ).foregroundStyle(.secondary).padding(
                                            .horizontal,
                                            24
                                        )
                                    } else {
                                        ForEach(viewModel.pendingList) { comp in
                                            AdminPendingCard(comp: comp) {
                                                action in
                                                viewModel.updateStatus(
                                                    compId: comp.id,
                                                    to: action == .approve
                                                        ? "ACTIVE" : "REJECTED"
                                                )
                                            }
                                        }
                                    }
                                }

                                Divider().padding(.vertical, 16)

                                // --- SEKSI 2: JURI PENDING ---
                                Section(
                                    header: Text("Adjudicator Requests").font(
                                        .subheadline.bold()
                                    ).foregroundStyle(.purple).padding(
                                        .horizontal,
                                        24
                                    ).frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                ) {
                                    if viewModel.pendingAdjudicators.isEmpty {
                                        Text("No pending adjudicator requests.")
                                            .font(.caption).foregroundStyle(
                                                .secondary
                                            ).padding(.horizontal, 24)
                                    } else {
                                        ForEach(viewModel.pendingAdjudicators) {
                                            req in
                                            AdminAdjudicatorRow(req: req) {
                                                viewModel.approveAdjudicator(
                                                    reqId: req.id,
                                                    userId: req.userId
                                                )
                                            }
                                        }
                                    }
                                }

                            } else {
                                // --- TAB 2: HISTORY LIST ---
                                // SEKSI 1: HISTORY KOMPETISI
                                Section(
                                    header: Text("Approved Competitions").font(
                                        .subheadline.bold()
                                    ).foregroundStyle(.green).padding(
                                        .horizontal,
                                        24
                                    ).frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                ) {
                                    if viewModel.approvedList.isEmpty {
                                        Text("No approved competitions yet.")
                                            .font(.caption).foregroundStyle(
                                                .secondary
                                            ).padding(.horizontal, 24)
                                    } else {
                                        ForEach(viewModel.approvedList) {
                                            comp in
                                            AdminHistoryRow(comp: comp)  // DIJAMIN TANPA TOMBOL
                                        }
                                    }
                                }

                                Divider().padding(.vertical, 16)

                                // SEKSI 2: HISTORY JURI
                                Section(
                                    header: Text("Approved Adjudicators").font(
                                        .subheadline.bold()
                                    ).foregroundStyle(.purple).padding(
                                        .horizontal,
                                        24
                                    ).frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                ) {
                                    if viewModel.approvedAdjudicators.isEmpty {
                                        Text("No approved adjudicators yet.")
                                            .font(.caption).foregroundStyle(
                                                .secondary
                                            ).padding(.horizontal, 24)
                                    } else {
                                        ForEach(viewModel.approvedAdjudicators)
                                        { req in
                                            AdminAdjudicatorHistoryRow(req: req)  // DIJAMIN TANPA TOMBOL
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.fetchAllModeration() }
        }
    }
}
