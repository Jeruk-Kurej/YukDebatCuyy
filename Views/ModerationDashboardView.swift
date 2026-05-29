import SwiftUI

struct ModerationDashboardView: View {
    @ObservedObject var viewModel: ModerationDashboardViewModel
    @State private var selectedTab = 0  // 0: Pending, 1: History

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // SEGMENTED CONTROL HIG STYLE
                    Picker("Admin Tabs", selection: $selectedTab) {
                        Text("Pending Approval").tag(0)
                        Text("Approved History").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.bgCream)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            if selectedTab == 0 {
                                // TAB 1: PENDING CARDS
                                if viewModel.pendingList.isEmpty {
                                    Text("All clear. No pending competitions.")
                                        .font(.subheadline).foregroundStyle(
                                            .secondary
                                        ).padding(.top, 40)
                                } else {
                                    ForEach(viewModel.pendingList) { comp in
                                        AdminPendingCard(comp: comp) { action in
                                            viewModel.updateStatus(
                                                compId: comp.id,
                                                to: action == .approve
                                                    ? "ACTIVE" : "REJECTED"
                                            )
                                        }
                                    }
                                }
                            } else {
                                // TAB 2: HISTORY LIST (COMPACT ROW)
                                if viewModel.approvedList.isEmpty {
                                    Text("No approved competitions yet.")
                                        .font(.subheadline).foregroundStyle(
                                            .secondary
                                        ).padding(.top, 40)
                                } else {
                                    ForEach(viewModel.approvedList) { comp in
                                        AdminHistoryRow(comp: comp)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.bottom, 120)  // FIX: Agar tidak tertutup Custom Tab Bar
                    }
                }
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.fetchAllModeration() }
        }
    }
}

enum AdminAction { case approve, reject }

// KARTU PENDING (Besar, Mewah, Ada Data User)
struct AdminPendingCard: View {
    let comp: CompetitionModel
    let onAction: (AdminAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 1. INFO PENDAFTAR (SUBMITTER)
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.accentWalnut)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Submitted by").font(.caption2).foregroundStyle(
                        .secondary
                    )
                    Text(comp.promoterEmail ?? "User").font(.subheadline.bold())
                        .foregroundStyle(Color.textCharcoal)
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 16)

            // 2. POSTER LOMBA
            if !comp.posterStorageUrl.isEmpty {
                if comp.posterStorageUrl.starts(with: "http") {
                    AsyncImage(url: URL(string: comp.posterStorageUrl)) {
                        image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 180).frame(maxWidth: .infinity).clipped()
                } else if let imageData = Data(
                    base64Encoded: comp.posterStorageUrl,
                    options: .ignoreUnknownCharacters
                ),
                    let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                        .frame(height: 180).frame(maxWidth: .infinity).clipped()
                }
            }

            // 3. DETAIL LOMBA
            VStack(alignment: .leading, spacing: 6) {
                Text(comp.name).font(.title3.bold()).foregroundStyle(
                    Color.textCharcoal
                )
                Text(comp.description).font(.subheadline).foregroundStyle(
                    .secondary
                ).lineLimit(3)
            }
            .padding(.horizontal, 16)

            // 4. TOMBOL AKSI
            HStack(spacing: 12) {
                Button(action: { onAction(.reject) }) {
                    Text("Reject").font(.subheadline.bold()).frame(
                        maxWidth: .infinity
                    ).padding(.vertical, 12)
                        .background(Color.btnNegative.opacity(0.1))
                        .foregroundStyle(Color.btnNegative).clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
                }
                Button(action: { onAction(.approve) }) {
                    Text("Approve").font(.subheadline.bold()).frame(
                        maxWidth: .infinity
                    ).padding(.vertical, 12)
                        .background(Color.btnPositive).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 16)
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
        .padding(.horizontal, 20)
    }
}

// KARTU HISTORY (Kecil, Rapi, Compact)
struct AdminHistoryRow: View {
    let comp: CompetitionModel

    var body: some View {
        HStack(spacing: 16) {
            // THUMBNAIL KECIL
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

            // INFO
            VStack(alignment: .leading, spacing: 4) {
                Text(comp.name).font(.headline).foregroundStyle(
                    Color.textCharcoal
                ).lineLimit(1)
                Text(comp.promoterEmail ?? "User").font(.caption)
                    .foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()

            // STATUS BADGE
            Image(systemName: "checkmark.seal.fill")
                .font(.title2).foregroundStyle(Color.btnPositive)
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
