//
//  ExploreMotionListView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

// MARK: - Daftar Explore Mosi
struct ExploreMotionListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State private var selectedMotionForNote: MotionModel?
    
    var body: some View {
        ScrollView {
            Button(action: { viewModel.triggerFetchMotion() }) {
                Label("Generate Random Motion", systemImage: "sparkles")
                    .font(.subheadline.bold()).frame(maxWidth: .infinity).padding()
                    .background(Color.btnPositive).foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredMotions) { motion in
                    Button(action: { selectedMotionForNote = motion }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(motion.category).font(.caption.bold()).foregroundStyle(Color.accentWalnut)
                            Text(motion.title).font(.body.bold()).foregroundStyle(Color.textCharcoal).multilineTextAlignment(.leading)
                        }
                        .padding().frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(item: $selectedMotionForNote) { motion in
            NavigationStack {
                // Buka catatan baru yang judulnya sudah terisi mosi ini otomatis
                NoteEditorView(
                    viewModel: viewModel,
                    draftNote: CaseBuildingNoteModel(id: UUID().uuidString, motionTitle: motion.title, argumentsRichText: "", visibility: .privateAccess, isFeedbackRequested: false, updatedAt: Date())
                )
            }
        }
    }
}

// MARK: - Daftar My Notes
struct MyNotesListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State private var noteToEdit: CaseBuildingNoteModel?
    
    var body: some View {
        List {
            ForEach(viewModel.filteredNotes) { note in
                Button(action: { noteToEdit = note }) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.motionTitle).font(.headline).foregroundStyle(Color.textCharcoal)
                        HStack {
                            Image(systemName: note.visibility == .privateAccess ? "lock.fill" : "globe")
                            Text(note.visibility.rawValue)
                        }
                        .font(.caption.bold())
                        .foregroundStyle(note.visibility == .privateAccess ? Color.btnNegative : Color.btnPositive)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: viewModel.deleteNote) // Fitur Delete
        }
        .listStyle(.plain)
        .sheet(item: $noteToEdit) { note in
            NavigationStack { NoteEditorView(viewModel: viewModel, draftNote: note) } // Buka untuk Edit
        }
    }
}
