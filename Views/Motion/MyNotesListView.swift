//
//  MyNotesListView.swift
//  YukDebatCuyy
//

import SwiftUI

/// Renders the user's saved case building notes.
/// Supports navigation to details and a context menu for editing or deleting notes.
struct MyNotesListView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var noteToEdit: CaseBuildingNoteModel?

    // MARK: - Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.myNotes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray.opacity(0.5))

                        Text("No notes available.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(viewModel.myNotes) { note in
                        NavigationLink(
                            destination: NoteDetailView(
                                viewModel: viewModel,
                                note: note
                            )
                        ) {
                            NoteCard(note: note)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: { noteToEdit = note }) {
                                Label("Edit Note", systemImage: "pencil")
                            }
                            Button(
                                role: .destructive,
                                action: {
                                    viewModel.deleteNoteFromFirestore(
                                        noteId: note.id
                                    )
                                }
                            ) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .onAppear {
            if let userId = authVM.currentUser?.id {
                viewModel.fetchMyNotes(userId: userId)
            }
        }
        .sheet(item: $noteToEdit) { draft in
            NavigationStack {
                NoteEditorView(
                    viewModel: viewModel,
                    draftNote: draft,
                    isNewNote: false
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MyNotesListView(
        viewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
    .environmentObject(AuthViewModel())
    .background(Color.bgCream)
}
