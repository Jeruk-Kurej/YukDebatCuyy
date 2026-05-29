import SwiftUI

struct MyNotesListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel

    // State khusus untuk menahan data saat mau Edit via Context Menu
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
                        NavigationLink(
                            destination: NoteDetailView(
                                viewModel: viewModel,
                                note: note
                            )
                        ) {
                            NoteCard(note: note)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // PERBAIKAN: Menambahkan Context Menu berstandar HIG
                        .contextMenu {
                            Button(action: {
                                noteToEdit = note
                            }) {
                                Label("Edit Catatan", systemImage: "pencil")
                            }

                            // Gunakan role .destructive agar teks otomatis berwarna merah
                            Button(
                                role: .destructive,
                                action: {
                                    viewModel.deleteNoteFromFirestore(
                                        noteId: note.id
                                    )
                                }
                            ) {
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(24)
            .padding(.bottom, 120)
        }
        .onAppear {
            if let userId = authVM.currentUser?.id {
                viewModel.fetchMyNotes(userId: userId)
            }
        }
        // Memunculkan Form Editor jika Edit ditekan dari Context Menu
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

// Subkomponen UI Kartu (Tetap sama)
struct NoteCard: View {
    let note: CaseBuildingNoteModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    Image(
                        systemName: note.visibility == .publicAccess
                            ? "globe" : "lock.fill"
                    )
                    Text(note.visibility == .publicAccess ? "PUBLIK" : "PRIVAT")
                }
                .font(.caption.bold())
                .foregroundStyle(
                    note.visibility == .publicAccess
                        ? Color.btnPositive : Color.btnNegative
                )
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(
                    note.visibility == .publicAccess
                        ? Color.btnPositive.opacity(0.1)
                        : Color.btnNegative.opacity(0.1)
                )
                .clipShape(Capsule())

                Spacer()

                Text(note.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(note.motionTitle)
                .font(.headline)
                .foregroundStyle(Color.textCharcoal)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 4)
    }
}
