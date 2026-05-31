import SwiftUI

struct ProvideFeedbackSheet: View {
    let note: CaseBuildingNoteModel
    @ObservedObject var evalVM: EvaluationViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var feedbackText = ""

    var body: some View {
        NavigationStack {
            // PERBAIKAN STYLE: Background Cream
            ZStack {
                Color.bgCream.ignoresSafeArea()

                Form {
                    Section(
                        header: Text("Detail Catatan Debater").font(
                            .caption.bold()
                        )
                    ) {
                        Text(note.motionTitle).font(.headline).foregroundStyle(
                            Color.textCharcoal
                        )
                        Text(note.argumentsRichText).font(.body)
                            .foregroundStyle(.secondary).padding(.vertical, 4)
                    }
                    .listRowBackground(Color.white)  // PERBAIKAN STYLE

                    Section(
                        header: Text("Beri Masukan / Feedback (Wajib)").font(
                            .caption.bold()
                        )
                    ) {
                        TextEditor(text: $feedbackText)
                            .frame(minHeight: 150)
                    }
                    .listRowBackground(Color.white)  // PERBAIKAN STYLE
                }
                .scrollContentBackground(.hidden)
                .padding(.top, -20)  // PERBAIKAN UX: Mengurangi jarak kosong
            }
            .navigationTitle("Evaluasi Catatan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }.foregroundStyle(
                        Color.btnNegative
                    )
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
