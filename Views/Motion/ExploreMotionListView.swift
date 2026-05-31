//
//  ExploreMotionListView.swift
//  YukDebatCuyy
//

import SwiftUI

/// Displays a list of random or searchable debate motions.
/// Allows Debaters to generate new motions, suggest custom ones, or save them.
struct ExploreMotionListView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var showingSubmitSheet = false

    // MARK: - Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                // Generate Button
                Button(action: { viewModel.triggerFetchMotion() }) {
                    HStack(spacing: 8) {
                        if viewModel.isGenerating {
                            ProgressView().tint(.white)
                            Text("Searching Motion...")
                                .font(.subheadline.bold())
                        } else {
                            Image(systemName: "sparkles")
                            Text("Generate Random Motion")
                                .font(.subheadline.bold())
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
                }
                .disabled(viewModel.isGenerating)

                // Suggest Custom Motion Button
                if authVM.currentUser?.role != .admin {
                    Button(action: { showingSubmitSheet = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.bubble.fill")
                            Text("Suggest Custom Motion")
                                .font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentWalnut)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding([.horizontal, .top])

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
                                Text(motion.category.uppercased())
                                    .font(.system(size: 10, weight: .black))
                            }
                            .foregroundStyle(Color.accentWalnut)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
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
                                            ? "Saved to Notes" : "Save to Notes"
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
        }
        .onAppear {
            if let userId = authVM.currentUser?.id {
                viewModel.fetchMyNotes(userId: userId)
            }
        }
        .sheet(isPresented: $showingSubmitSheet) {
            SubmitMotionFormView(viewModel: viewModel)
        }
        .modernToast(
            message: $viewModel.statusMessage,
            isError: viewModel.statusMessage?.contains("Failed") == true
        )
    }
}

// MARK: - Preview

#Preview {
    ExploreMotionListView(
        viewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
    .environmentObject(AuthViewModel())
    .background(Color.bgCream)
}
