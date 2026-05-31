//
//  ModerationDashboardView.swift
//  YukDebatCuyy
//

import SwiftUI

/// The central hub for Admin users to moderate competitions, adjudicators, motions, and content.
struct ModerationDashboardView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: ModerationDashboardViewModel
    @State private var selectedTab = 0

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("Admin Tabs", selection: $selectedTab) {
                        Text("Pending").tag(0)
                        Text("History").tag(1)
                        Text("Users & Content").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.bgCream)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            if selectedTab == 0 {
                                // 1. MOTIONS
                                Section(
                                    header: Text("Custom Motions")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.blue).padding(
                                            .horizontal,
                                            24
                                        ).frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                ) {
                                    if viewModel.pendingMotions.isEmpty {
                                        Text("No pending motion requests.")
                                            .font(.caption).foregroundStyle(
                                                .secondary
                                            ).padding(.horizontal, 24)
                                    } else {
                                        ForEach(viewModel.pendingMotions) {
                                            req in
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(req.title).font(
                                                        .headline
                                                    ).lineLimit(2)
                                                    Text(req.category).font(
                                                        .caption
                                                    ).foregroundStyle(
                                                        Color.accentWalnut
                                                    )
                                                }
                                                Spacer()
                                                Button(action: {
                                                    viewModel
                                                        .rejectMotionRequest(
                                                            reqId: req.id
                                                        )
                                                }) {
                                                    Image(
                                                        systemName:
                                                            "xmark.circle.fill"
                                                    ).font(.title2)
                                                        .foregroundStyle(
                                                            Color.btnNegative
                                                        )
                                                }
                                                Button(action: {
                                                    viewModel
                                                        .approveMotionRequest(
                                                            req: req
                                                        )
                                                }) {
                                                    Image(
                                                        systemName:
                                                            "checkmark"
                                                    ).font(.title2)
                                                        .foregroundStyle(
                                                            Color.btnPositive
                                                        )
                                                }
                                                .padding(.leading, 8)
                                            }
                                            .padding(16).background(Color.white)
                                            .clipShape(
                                                RoundedRectangle(
                                                    cornerRadius: 12
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(
                                                    cornerRadius: 12
                                                ).stroke(
                                                    Color.black.opacity(0.05),
                                                    lineWidth: 1
                                                )
                                            )
                                            .padding(.horizontal, 20)
                                        }
                                    }
                                }

                                Divider().padding(.vertical, 16)

                                // 2. COMPETITIONS
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

                                // 3. ADJUDICATORS
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

                            } else if selectedTab == 1 {
                                // HISTORY TAB
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
                                            AdminHistoryRow(comp: comp)
                                        }
                                    }
                                }

                                Divider().padding(.vertical, 16)

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
                                            AdminAdjudicatorHistoryRow(req: req)
                                        }
                                    }
                                }

                            } else {
                                // USERS & CONTENT TAB
                                Section(
                                    header: Text("User Management").font(
                                        .subheadline.bold()
                                    ).foregroundStyle(.blue).padding(
                                        .horizontal,
                                        24
                                    ).frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                ) {
                                    ForEach(viewModel.allUsers) { user in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(user.name).font(.headline)
                                                Text(user.email).font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Button(action: {
                                                viewModel.suspendUser(
                                                    userId: user.id,
                                                    isActive: !user.isActive
                                                )
                                            }) {
                                                Text(
                                                    user.isActive
                                                        ? "Suspend"
                                                        : "Unsuspend"
                                                )
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    user.isActive
                                                        ? Color.btnNegative
                                                        : Color.btnPositive
                                                )
                                                .clipShape(Capsule())
                                            }
                                        }
                                        .padding(16).background(Color.white)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 12)
                                        )
                                        .padding(.horizontal, 20)
                                    }
                                }

                                Divider().padding(.vertical, 16)

                                Section(
                                    header: Text("Public Notes Moderation")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.red).padding(
                                            .horizontal,
                                            24
                                        ).frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                ) {
                                    ForEach(viewModel.publicNotes) { note in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(note.motionTitle).font(
                                                    .headline
                                                ).lineLimit(1)
                                                Text("ID: \(note.id)").font(
                                                    .caption
                                                ).foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            Button(action: {
                                                viewModel.deletePublicNote(
                                                    noteId: note.id
                                                )
                                            }) {
                                                Image(systemName: "trash.fill")
                                                    .foregroundStyle(
                                                        Color.btnNegative
                                                    )
                                            }
                                        }
                                        .padding(16).background(Color.white)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 12)
                                        )
                                        .padding(.horizontal, 20)
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

// MARK: - Preview

#Preview {
    ModerationDashboardView(viewModel: ModerationDashboardViewModel())
}
