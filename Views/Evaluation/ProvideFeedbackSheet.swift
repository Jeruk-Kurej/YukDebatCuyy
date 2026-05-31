//
//  ProvideFeedbackSheet.swift
//  YukDebatCuyy
//

import SwiftUI

/// A bottom sheet form for Adjudicators to write and submit feedback.
struct ProvideFeedbackSheet: View {

    // MARK: - Properties

    let note: CaseBuildingNoteModel
    @ObservedObject var evalVM: EvaluationViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var feedbackText = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                Form {
                    Section(
                        header: Text("Debater Note Details").font(
                            .caption.bold()
                        )
                    ) {
                        Text(note.motionTitle).font(.headline).foregroundStyle(
                            Color.textCharcoal
                        )
                        Text(note.argumentsRichText).font(.body)
                            .foregroundStyle(.secondary).padding(.vertical, 4)
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Provide Feedback (Required)").font(
                            .caption.bold()
                        )
                    ) {
                        TextEditor(text: $feedbackText)
                            .frame(minHeight: 150)
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
                .padding(.top, -20)
            }
            .navigationTitle("Evaluate Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(
                        Color.btnNegative
                    )
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        let juriName =
                            authVM.currentUser?.name ?? "Anonymous Adjudicator"
                        evalVM.submitFeedback(
                            noteId: note.id,
                            feedbackText: feedbackText,
                            providerName: juriName
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(
                        feedbackText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ? Color.gray : Color.purple
                    )
                    .disabled(
                        feedbackText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProvideFeedbackSheet(
        note: CaseBuildingNoteModel(
            id: "1",
            ownerId: "u1",
            motionTitle: "Motion Sample",
            argumentsRichText: "Arguments here...",
            visibility: .publicAccess,
            isFeedbackRequested: true,
            updatedAt: Date()
        ),
        evalVM: EvaluationViewModel()
    )
    .environmentObject(AuthViewModel())
}
