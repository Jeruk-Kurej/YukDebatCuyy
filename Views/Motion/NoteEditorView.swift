//
//  NoteEditorView.swift
//  YukDebatCuyy
//

import SwiftUI

/// A form for creating or editing case building notes.
struct NoteEditorView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MotionArchiveViewModel
    @State var draftNote: CaseBuildingNoteModel

    var isNewNote: Bool = false
    @Environment(\.dismiss) var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()

            Form {
                Section(header: Text("Motion Details").font(.caption.bold())) {
                    TextField(
                        "Motion Title *",
                        text: $draftNote.motionTitle,
                        axis: .vertical
                    )
                    .font(.system(.body, design: .serif, weight: .medium))

                    Picker("Note Visibility", selection: $draftNote.visibility)
                    {
                        Text("Private").tag(VisibilityType.privateAccess)
                        Text("Public").tag(VisibilityType.publicAccess)
                    }
                    .tint(Color.accentWalnut)
                }
                .listRowBackground(Color.white)

                Section(
                    header: Text("Case Building Structure").font(
                        .caption.bold()
                    )
                ) {
                    TextEditor(text: $draftNote.argumentsRichText)
                        .frame(minHeight: 280)
                        .font(.system(.body, design: .default))
                }
                .listRowBackground(Color.white)
            }
            .scrollContentBackground(.hidden)
            .padding(.top, -20)
        }
        .navigationTitle(isNewNote ? "Add Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(Color.btnNegative)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
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

// MARK: - Preview

#Preview {
    NavigationStack {
        NoteEditorView(
            viewModel: MotionArchiveViewModel(
                apiProxy: MockCloudFunctions(),
                localCache: LocalCoreDataStorage()
            ),
            draftNote: CaseBuildingNoteModel(
                id: "1",
                ownerId: "user_1",
                motionTitle: "",
                argumentsRichText: "",
                visibility: .publicAccess,
                isFeedbackRequested: false,
                updatedAt: Date()
            ),
            isNewNote: true
        )
    }
}
