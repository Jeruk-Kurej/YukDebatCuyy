import SwiftUI

struct NoteEditorView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State var draftNote: CaseBuildingNoteModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Detail Mosi")) {
                TextField("Judul Mosi", text: $draftNote.motionTitle)
                
                // Toggle Public/Private (FR-1.2)
                Picker("Visibilitas", selection: $draftNote.visibility) {
                    Text("Privat (Hanya Saya)").tag(VisibilityType.privateAccess)
                    Text("Publik (Bisa Dilihat Juri)").tag(VisibilityType.publicAccess)
                }
            }
            
            Section(header: Text("Catatan Argumen (Case Building)")) {
                TextEditor(text: $draftNote.argumentsRichText)
                    .frame(minHeight: 250)
            }
            
            // LOGIKA KONDISIONAL END-TO-END (UC04)
            // Jika Privat, form ini tidak muncul sama sekali.
            // Jika Publik, user diizinkan meminta feedback.
            if draftNote.visibility == .publicAccess {
                Section(header: Text("Evaluasi & Feedback"), footer: Text("Meminta feedback akan mengirimkan argumen ini ke antrean para Adjudicator.")) {
                    Button(action: {
                        draftNote.isFeedbackRequested = true
                        viewModel.requestFeedback(for: draftNote.id)
                    }) {
                        HStack {
                            Text(draftNote.isFeedbackRequested ? "Feedback Sedang Diproses..." : "Minta Feedback Juri")
                            Spacer()
                            if draftNote.isFeedbackRequested { Image(systemName: "checkmark.circle.fill") }
                        }
                    }
                    .foregroundStyle(draftNote.isFeedbackRequested ? Color.gray : Color.btnPositive)
                    .disabled(draftNote.isFeedbackRequested)
                }
            }
        }
        .navigationTitle("Catatan Debat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Batal") { dismiss() }.foregroundStyle(Color.btnNegative)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Simpan") {
                    // Update timestamp & save (Update/Create logic)
                    draftNote.updatedAt = Date()
                    viewModel.saveNote(draftNote)
                    dismiss()
                }
                .fontWeight(.bold)
                .disabled(draftNote.motionTitle.isEmpty)
            }
        }
    }
}
