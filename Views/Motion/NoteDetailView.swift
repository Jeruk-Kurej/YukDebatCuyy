//
//  NoteDetailView.swift
//  YukDebatCuyy
//

import SwiftUI

/// Provides a read-only view of a specific case building note.
/// Allows the user to request feedback from adjudicators or read provided feedback.
struct NoteDetailView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MotionArchiveViewModel
    let note: CaseBuildingNoteModel

    @State private var showingEditSheet = false

    // MARK: - Computed Properties

    var latestNote: CaseBuildingNoteModel {
        viewModel.myNotes.first { $0.id == note.id } ?? note
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(
                                systemName: latestNote.visibility
                                    == .publicAccess ? "globe" : "lock.fill"
                            )
                            Text(
                                latestNote.visibility == .publicAccess
                                    ? "Public Access" : "Private Access"
                            )
                        }
                        .font(.caption.bold())
                        .foregroundStyle(
                            latestNote.visibility == .publicAccess
                                ? Color.btnPositive : Color.btnNegative
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            latestNote.visibility == .publicAccess
                                ? Color.btnPositive.opacity(0.1)
                                : Color.btnNegative.opacity(0.1)
                        )
                        .clipShape(Capsule())

                        Text(latestNote.motionTitle)
                            .font(.title2.bold())
                            .foregroundStyle(Color.textCharcoal)
                            .padding(.top, 4)

                        Text(
                            "Last modified: \(latestNote.updatedAt.formatted(date: .abbreviated, time: .shortened))"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Divider()

                    // Content Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Case Building Note")
                            .font(.headline)
                            .foregroundStyle(Color.accentWalnut)

                        if latestNote.argumentsRichText.isEmpty {
                            Text("No arguments or notes written yet.")
                                .font(.body)
                                .foregroundStyle(.gray.opacity(0.8))
                                .italic()
                                .padding(.top, 8)
                        } else {
                            Text(latestNote.argumentsRichText)
                                .font(.body)
                                .foregroundStyle(Color.textCharcoal)
                                .lineSpacing(4)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // Feedback Section
                    if let feedback = latestNote.feedbackText, !feedback.isEmpty
                    {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "star.bubble.fill")
                                Text(
                                    "Feedback from Adjudicator: \(latestNote.feedbackProviderName ?? "Adjudicator")"
                                )
                            }
                            .font(.headline)
                            .foregroundStyle(.purple)

                            Text(feedback)
                                .font(.body)
                                .foregroundStyle(Color.textCharcoal)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.purple.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(
                                        Color.purple.opacity(0.3),
                                        lineWidth: 1
                                    )
                                )
                        }
                    } else if latestNote.visibility == .publicAccess {
                        Button(action: {
                            withAnimation {
                                viewModel.requestFeedback(for: latestNote.id)
                            }
                        }) {
                            HStack {
                                Image(
                                    systemName: latestNote.isFeedbackRequested
                                        ? "hourglass" : "paperplane.fill"
                                )
                                Text(
                                    latestNote.isFeedbackRequested
                                        ? "Waiting for Adjudicator Feedback..."
                                        : "Request Adjudicator Feedback"
                                )
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                latestNote.isFeedbackRequested
                                    ? Color.gray : Color.purple
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(latestNote.isFeedbackRequested)
                    }

                    Spacer()
                }
                .padding(24)
            }
        }
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Text("Edit")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.btnPositive)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                NoteEditorView(
                    viewModel: viewModel,
                    draftNote: latestNote,
                    isNewNote: false
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NoteDetailView(
            viewModel: MotionArchiveViewModel(
                apiProxy: MockCloudFunctions(),
                localCache: LocalCoreDataStorage()
            ),
            note: CaseBuildingNoteModel(
                id: "1",
                ownerId: "user_1",
                motionTitle: "This house would ban artificial intelligence",
                argumentsRichText: "Content...",
                visibility: .publicAccess,
                isFeedbackRequested: false,
                updatedAt: Date()
            )
        )
    }
}
