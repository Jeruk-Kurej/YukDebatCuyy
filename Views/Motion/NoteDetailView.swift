import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    let note: CaseBuildingNoteModel
    
    @State private var showingEditSheet = false
    
    // PERBAIKAN: Selalu tarik data paling segar dari Firestore (myNotes)
    var latestNote: CaseBuildingNoteModel {
        viewModel.myNotes.first { $0.id == note.id } ?? note
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header: Status & Judul Mosi
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: latestNote.visibility == .publicAccess ? "globe" : "lock.fill")
                        Text(latestNote.visibility == .publicAccess ? "Akses Publik" : "Akses Privat")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(latestNote.visibility == .publicAccess ? Color.btnPositive : Color.btnNegative)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(latestNote.visibility == .publicAccess ? Color.btnPositive.opacity(0.1) : Color.btnNegative.opacity(0.1))
                    .clipShape(Capsule())
                    
                    Text(latestNote.motionTitle)
                        .font(.title2.bold())
                        .foregroundStyle(Color.textCharcoal)
                        .padding(.top, 4)
                        
                    Text("Terakhir diubah: \(latestNote.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Konten Catatan
                VStack(alignment: .leading, spacing: 12) {
                    Text("Catatan Case Building")
                        .font(.headline)
                        .foregroundStyle(Color.accentWalnut)
                    
                    if latestNote.argumentsRichText.isEmpty {
                        Text("Belum ada argumen atau catatan yang ditulis.")
                            .font(.body)
                            .foregroundStyle(.gray.opacity(0.8))
                            .italic()
                            .padding(.top, 8)
                    } else {
                        Text(latestNote.argumentsRichText)
                            .font(.body)
                            .foregroundStyle(Color.textCharcoal)
                            .lineSpacing(4)
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Detail Catatan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Tombol Edit di Kanan Atas
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(Color.btnPositive)
                }
            }
        }
        // Memunculkan Form Editor Saat Tombol Edit Ditekan
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                NoteEditorView(
                    viewModel: viewModel,
                    draftNote: latestNote, // Lempar data yang terbaru ke form
                    isNewNote: false
                )
            }
        }
    }
}
