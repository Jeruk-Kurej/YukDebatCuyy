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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Detail Mosi Lomba")) {
                TextField("Judul Mosi", text: $draftNote.motionTitle, axis: .vertical)
                    .font(.system(.body, design: .serif, weight: .medium))
                
                Picker("Visibilitas Catatan", selection: $draftNote.visibility) {
                    Text("Privat (Hanya Saya)").tag(VisibilityType.privateAccess)
                    Text("Publik (Bisa Dinilai Juri)").tag(VisibilityType.publicAccess)
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
            
            // TOMBOL FEEDBACK DIHAPUS DARI SINI (Pindah ke Detail View)
        }
        .scrollContentBackground(.hidden)
        .background(Color.bgCream)
        .navigationTitle("Edit Catatan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Batal") { dismiss() }
                    .foregroundStyle(Color.btnNegative)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Simpan") {
                    draftNote.updatedAt = Date()
                    viewModel.saveNote(draftNote)
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundStyle(draftNote.motionTitle.isEmpty ? Color.gray : Color.btnPositive)
                .disabled(draftNote.motionTitle.isEmpty)
            }
        }
    }
}
