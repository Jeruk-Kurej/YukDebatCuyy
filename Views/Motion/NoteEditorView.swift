//
//  NoteEditorView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct NoteEditorView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State var draftNote: CaseBuildingNoteModel

    // REVISI 10: Parameter untuk mengetahui apakah ini Edit atau Baru
    var isNewNote: Bool = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section(header: Text("Detail Mosi Lomba")) {
                // REVISI 11: Label bintang untuk field wajib
                TextField(
                    "Judul Mosi *",
                    text: $draftNote.motionTitle,
                    axis: .vertical
                )
                .font(.system(.body, design: .serif, weight: .medium))

                Picker("Visibilitas Catatan", selection: $draftNote.visibility)
                {
                    Text("Private").tag(VisibilityType.privateAccess)
                    Text("Public").tag(VisibilityType.publicAccess)
                }
                .tint(Color.accentWalnut)
            }
            .listRowBackground(Color.white)

            Section(header: Text("Struktur Konstruksi Kasus (Case Building)")) {
                TextEditor(text: $draftNote.argumentsRichText)
                    .frame(minHeight: 280)
                    .font(.system(.body, design: .default))
            }
            .listRowBackground(Color.white)
        }
        .scrollContentBackground(.hidden)
        .background(Color.bgCream)

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
