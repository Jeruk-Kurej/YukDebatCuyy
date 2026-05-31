import SwiftUI

struct NoteEditorView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State var draftNote: CaseBuildingNoteModel
    var isNewNote: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // PERBAIKAN STYLE: Dibungkus ZStack agar lebih aman menutupi Safe Area
        ZStack {
            Color.bgCream.ignoresSafeArea()

            Form {
                Section(header: Text("Detail Mosi Lomba").font(.caption.bold()))
                {
                    TextField(
                        "Judul Mosi *",
                        text: $draftNote.motionTitle,
                        axis: .vertical
                    )
                    .font(.system(.body, design: .serif, weight: .medium))

                    Picker(
                        "Visibilitas Catatan",
                        selection: $draftNote.visibility
                    ) {
                        Text("Private").tag(VisibilityType.privateAccess)
                        Text("Public").tag(VisibilityType.publicAccess)
                    }
                    .tint(Color.accentWalnut)
                }
                .listRowBackground(Color.white)

                Section(
                    header: Text("Struktur Konstruksi Kasus (Case Building)")
                        .font(.caption.bold())
                ) {
                    TextEditor(text: $draftNote.argumentsRichText)
                        .frame(minHeight: 280)
                        .font(.system(.body, design: .default))
                }
                .listRowBackground(Color.white)
            }
            .scrollContentBackground(.hidden)
            .padding(.top, -20)  // PERBAIKAN UX: Mengurangi jarak kosong
        }
        .navigationTitle(isNewNote ? "Tambah Catatan" : "Edit Catatan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Batal") { dismiss() }.foregroundStyle(Color.btnNegative)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Simpan") {
                    draftNote.updatedAt = Date()
                    viewModel.saveNote(draftNote)
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundStyle(
                    draftNote.motionTitle.isEmpty
                        ? Color.gray : Color.btnPositive
                )
                .disabled(draftNote.motionTitle.isEmpty)
            }
        }
    }
}
