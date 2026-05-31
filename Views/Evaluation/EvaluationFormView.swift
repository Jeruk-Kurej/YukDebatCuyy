//
//  EvaluationFormView.swift
//  YukDebatCuyy
//

import SwiftUI

/// A purely visual form for Adjudicators to submit evaluations.
/// Delegates all business logic to EvaluationViewModel.
struct EvaluationFormView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: EvaluationViewModel
    let room: SparringRoomModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var narrativeFeedback: String = ""
    @State private var speakerScores: [String: Int] = [:]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                Form {
                    Section(
                        header: Text("Debater Scores (50-100)").font(
                            .caption.bold()
                        )
                    ) {
                        ForEach(room.participants, id: \.userId) {
                            participant in
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
                                    value: Binding(
                                        get: {
                                            speakerScores[participant.userId]
                                                ?? 75
                                        },
                                        set: {
                                            speakerScores[participant.userId] =
                                                $0
                                        }
                                    ),
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
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Narrative Feedback").font(.caption.bold())
                    ) {
                        TextEditor(text: $narrativeFeedback)
                            .frame(minHeight: 150)
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
                .padding(.top, -20)
            }
            .navigationTitle("Score Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.btnNegative)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        viewModel.submitSparringEvaluation(
                            room: room,
                            adjudicatorId: authVM.currentUser?.name
                                ?? "Anonymous Adjudicator",
                            feedback: narrativeFeedback,
                            rawScores: speakerScores
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(
                        narrativeFeedback.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ? Color.gray : Color.btnPositive
                    )
                    .disabled(
                        narrativeFeedback.trimmingCharacters(
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
