//
//  EvaluationFormView.swift
//  YukDebatCuyy
//

import SwiftUI

/// A form for Adjudicators to submit narrative feedback for a sparring session.
struct EvaluationFormView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: EvaluationViewModel
    let room: SparringRoomModel
    @Environment(\.dismiss) var dismiss
    
    @State private var narrativeFeedback: String = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Narrative Feedback").font(.caption.bold())) {
                        TextEditor(text: $narrativeFeedback)
                            .frame(minHeight: 200)
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
                .padding(.top, -20)
            }
            .navigationTitle("Feedback Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.btnNegative)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        // TODO: Implement submission logic in ViewModel for sparring room feedback
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(narrativeFeedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.btnPositive)
                    .disabled(narrativeFeedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            id: "1", hostId: "u1", scheduledTime: Date(), motionCategory: "Test",
            specialNotes: "", meetingLink: "", accessType: .publicAccess, state: .ongoing,
            participants: [],
            isAdjudicatorNeeded: true
        )
    )
}
