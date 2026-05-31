//
//  ProvideFeedbackSheet.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct ProvideFeedbackSheet: View {
    let note: CaseBuildingNoteModel
    @ObservedObject var evalVM: EvaluationViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var feedbackText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Detail Catatan Debater")) {
                    Text(note.motionTitle).font(.headline).foregroundStyle(
                        Color.textCharcoal
                    )
                    Text(note.argumentsRichText).font(.body).foregroundStyle(
                        .secondary
                    ).padding(.vertical, 4)
                }

                Section(header: Text("Beri Masukan / Feedback (Wajib)")) {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("Evaluasi Catatan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kirim") {
                        let juriName = authVM.currentUser?.name ?? "Juri Anonim"
                        evalVM.submitFeedback(
                            noteId: note.id,
                            feedbackText: feedbackText,
                            providerName: juriName
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.purple)
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
