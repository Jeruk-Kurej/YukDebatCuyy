import SwiftUI

struct MyNotesListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var noteToEdit: CaseBuildingNoteModel?

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.myNotes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray.opacity(0.5))
                        Text("Belum ada catatan.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(viewModel.myNotes) { note in
                        NavigationLink(destination: NoteDetailView(viewModel: viewModel, note: note)) {
                            NoteCard(note: note)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: { noteToEdit = note }) {
                                Label("Edit Catatan", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: { viewModel.deleteNoteFromFirestore(noteId: note.id) }) {
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            // PERBAIKAN HIG: Padatkan jarak atas, pertahankan jarak kiri-kanan & bawah
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
                NoteEditorView(viewModel: viewModel, draftNote: draft, isNewNote: false)
            }
        }
    }
}
