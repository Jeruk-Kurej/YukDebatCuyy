import SwiftUI

struct ExploreMotionListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {

            // TOMBOL GENERATE
            Button(action: { viewModel.triggerFetchMotion() }) {
                HStack(spacing: 8) {
                    if viewModel.isGenerating {
                        ProgressView().tint(.white)
                        Text("Mencari Mosi...").font(.subheadline.bold())
                    } else {
                        Image(systemName: "sparkles")
                        Text("Generate Random Motion").font(.subheadline.bold())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.isGenerating
                        ? Color.btnPositive.opacity(0.6) : Color.btnPositive
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(viewModel.isGenerating ? 0.97 : 1.0)
                .animation(
                    .easeInOut(duration: 0.2),
                    value: viewModel.isGenerating
                )
            }
            .padding([.horizontal, .top])
            .disabled(viewModel.isGenerating)

            // LIST MOSI
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredMotions) { motion in
                    let isSaved =
                        motion.isWishlisted
                        || viewModel.myNotes.contains(where: {
                            $0.motionTitle == motion.title
                        })

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack {
                                Image(systemName: "tag.fill").font(.caption)
                                Text(motion.category.uppercased()).font(
                                    .system(size: 10, weight: .black)
                                )
                            }
                            .foregroundStyle(Color.accentWalnut)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.accentWalnut.opacity(0.08))
                            .clipShape(Capsule())

                            Spacer()
                        }

                        Text(motion.title)
                            .font(.system(.body, design: .serif, weight: .bold))
                            .foregroundStyle(Color.textCharcoal)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        if authVM.currentUser?.role != .admin {
                            Divider().padding(.vertical, 4)

                            Button(action: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    viewModel.createNoteFromMotion(motion)
                                }
                            }) {
                                HStack {
                                    Image(
                                        systemName: isSaved
                                            ? "checkmark.circle.fill"
                                            : "plus.circle.fill"
                                    )
                                    Text(
                                        isSaved
                                            ? "Tersimpan di Catatan"
                                            : "Simpan ke Catatan"
                                    )
                                }
                                .font(.subheadline.bold())
                                .foregroundStyle(
                                    isSaved ? Color.btnPositive : .white
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    isSaved
                                        ? Color.btnPositive.opacity(0.15)
                                        : Color.btnNeutral
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(isSaved)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14).stroke(
                            Color.black.opacity(0.04),
                            lineWidth: 1
                        )
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)
            .animation(
                .spring(response: 0.4, dampingFraction: 0.8),
                value: viewModel.filteredMotions
            )
        }
        // PERBAIKAN BUG: Ambil data "myNotes" secara langsung saat layar Explore ini terbuka
        .onAppear {
            if let userId = authVM.currentUser?.id {
                viewModel.fetchMyNotes(userId: userId)
            }
        }
    }
}
