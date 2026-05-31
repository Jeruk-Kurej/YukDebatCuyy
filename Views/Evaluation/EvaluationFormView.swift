//
//  EvaluationFormView.swift
//  YukDebatCuyy
//

import SwiftUI

/// A purely visual form for Adjudicators to submit evaluations.
struct EvaluationFormView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: EvaluationViewModel
    let room: SparringRoomModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var narrativeFeedback: String = ""
    @State private var speakerScores: [String: Int] = [:]

    // MARK: - Computed Properties (Logic)

    private var isFeedbackEmpty: Bool {
        narrativeFeedback.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    private var submitButtonColor: Color {
        isFeedbackEmpty ? Color.gray : Color.btnPositive
    }

    private var activeParticipants: [ParticipantModel] {
        room.participants
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                Form {
                    scoreSection
                    feedbackSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Score Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
                ToolbarItem(placement: .confirmationAction) {
                    submitButton
                }
            }
        }
    }

    // MARK: - UI Sub-Components (View Extraction)

    private var scoreSection: some View {
        Section(header: Text("Debater Scores (50-100)").font(.caption.bold())) {
            ForEach(activeParticipants, id: \.userId) { participant in
                scoreRow(for: participant)
            }
        }
        .listRowBackground(Color.white)
    }

    private var feedbackSection: some View {
        Section(header: Text("Narrative Feedback").font(.caption.bold())) {
            TextEditor(text: $narrativeFeedback)
                .frame(minHeight: 150)
        }
        .listRowBackground(Color.white)
    }

    private func scoreRow(for participant: ParticipantModel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(participant.userId)
                    .font(.body.bold())
                    .foregroundStyle(Color.textCharcoal)
                Text(participant.roleSlot.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            TextField(
                "Score",
                value: scoreBinding(for: participant.userId),
                format: .number
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 60)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .foregroundStyle(Color.btnNegative)
    }

    private var submitButton: some View {
        Button("Submit") {
            processSubmission()
        }
        .fontWeight(.bold)
        .foregroundStyle(submitButtonColor)
        .disabled(isFeedbackEmpty)
    }

    // MARK: - Methods

    private func processSubmission() {
        let adjudicatorId = authVM.currentUser?.name ?? "Anonymous Adjudicator"

        viewModel.submitSparringEvaluation(
            room: room,
            adjudicatorId: adjudicatorId,
            feedback: narrativeFeedback,
            rawScores: speakerScores
        )
        dismiss()
    }

    private func scoreBinding(for key: String) -> Binding<Int> {
        return Binding(
            get: { speakerScores[key] ?? 75 },
            set: { speakerScores[key] = $0 }
        )
    }
}

// MARK: - Preview

#Preview {
    EvaluationFormView(
        viewModel: EvaluationViewModel(),
        room: SparringRoomModel(
            id: "1",
            hostId: "u1",
            scheduledTime: Date(),
            motionCategory: "Test",
            specialNotes: "",
            meetingLink: "",
            accessType: .publicAccess,
            state: .ongoing,
            participants: [
                ParticipantModel(
                    userId: "User 1",
                    roleSlot: .openingGovt,
                    regMode: .solo
                ),
                ParticipantModel(
                    userId: "User 2",
                    roleSlot: .openingOpp,
                    regMode: .solo
                ),
            ],
            isAdjudicatorNeeded: true
        )
    )
    .environmentObject(AuthViewModel())
}
