import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    let note: CaseBuildingNoteModel

    @State private var showingEditSheet = false

    var latestNote: CaseBuildingNoteModel {
        viewModel.myNotes.first { $0.id == note.id } ?? note
    }

    var body: some View {
        // PERBAIKAN: Bungkus dengan ZStack agar background Cream khas YukDebat teraplikasikan
        ZStack {
            Color.bgCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(
                                systemName: latestNote.visibility
                                    == .publicAccess ? "globe" : "lock.fill"
                            )
                            Text(
                                latestNote.visibility == .publicAccess
                                    ? "Akses Publik" : "Akses Privat"
                            )
                        }
                        .font(.caption.bold())
                        .foregroundStyle(
                            latestNote.visibility == .publicAccess
                                ? Color.btnPositive : Color.btnNegative
                        )
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(
                            latestNote.visibility == .publicAccess
                                ? Color.btnPositive.opacity(0.1)
                                : Color.btnNegative.opacity(0.1)
                        )
                        .clipShape(Capsule())

                        Text(latestNote.motionTitle).font(.title2.bold())
                            .foregroundStyle(Color.textCharcoal).padding(
                                .top,
                                4
                            )
                        Text(
                            "Terakhir diubah: \(latestNote.updatedAt.formatted(date: .abbreviated, time: .shortened))"
                        )
                        .font(.caption).foregroundStyle(.secondary)
                    }

                    Divider()

                    // Konten Catatan
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Catatan Case Building").font(.headline)
                            .foregroundStyle(Color.accentWalnut)
                        if latestNote.argumentsRichText.isEmpty {
                            Text("Belum ada argumen atau catatan yang ditulis.")
                                .font(.body).foregroundStyle(.gray.opacity(0.8))
                                .italic().padding(.top, 8)
                        } else {
                            Text(latestNote.argumentsRichText).font(.body)
                                .foregroundStyle(Color.textCharcoal)
                                .lineSpacing(4)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // AREA FEEDBACK & TOMBOL REQUEST
                    if let feedback = latestNote.feedbackText, !feedback.isEmpty
                    {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "star.bubble.fill")
                                Text(
                                    "Feedback dari Juri: \(latestNote.feedbackProviderName ?? "Juri")"
                                )
                            }
                            .font(.headline).foregroundStyle(.purple)

                            Text(feedback)
                                .font(.body).foregroundStyle(Color.textCharcoal)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.purple.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(
                                        Color.purple.opacity(0.3),
                                        lineWidth: 1
                                    )
                                )
                        }
                    } else if latestNote.visibility == .publicAccess {
                        Button(action: {
                            withAnimation {
                                viewModel.requestFeedback(for: latestNote.id)
                            }
                        }) {
                            HStack {
                                Image(
                                    systemName: latestNote.isFeedbackRequested
                                        ? "hourglass" : "paperplane.fill"
                                )
                                Text(
                                    latestNote.isFeedbackRequested
                                        ? "Menunggu Feedback Juri..."
                                        : "Minta Feedback Juri"
                                )
                            }
                            .font(.headline).foregroundStyle(.white).frame(
                                maxWidth: .infinity
                            ).padding()
                            .background(
                                latestNote.isFeedbackRequested
                                    ? Color.gray : Color.purple
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(latestNote.isFeedbackRequested)
                    }

                    Spacer()
                }
                .padding(24)
            }
        }
        .navigationTitle("Detail Catatan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    // PERBAIKAN HIG: Hapus icon pencil, sisakan teks saja agar lebih native iOS
                    Text("Edit")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.btnPositive)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                NoteEditorView(
                    viewModel: viewModel,
                    draftNote: latestNote,
                    isNewNote: false
                )
            }
        }
    }
}
