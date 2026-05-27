//
//  NoteDetailView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    let noteId: String
    
    @State private var isShowingEditSheet = false
    
    // Computed property: Mengambil data paling segar dari ViewModel
    var currentNote: CaseBuildingNoteModel? {
        viewModel.savedNotes.first { $0.id == noteId }
    }
    
    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()
            
            if let note = currentNote {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 1. HEADER KARTU
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: note.visibility == .privateAccess ? "lock.fill" : "globe")
                                    Text(note.visibility == .privateAccess ? "PRIVAT" : "PUBLIK")
                                }
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(note.visibility == .privateAccess ? Color.btnNegative : Color.btnPositive)
                                .padding(.horizontal, 8).padding(.vertical, 5)
                                .background(note.visibility == .privateAccess ? Color.btnNegative.opacity(0.1) : Color.btnPositive.opacity(0.1))
                                .clipShape(Capsule())
                                
                                Spacer()
                            }
                            
                            Text(note.motionTitle)
                                .font(.system(.title2, design: .serif, weight: .bold))
                                .foregroundStyle(Color.textCharcoal)
                            
                            Text("Terakhir diubah: \(note.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // 2. KONTEN ARGUMEN
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Catatan Strategi")
                                .font(.headline)
                                .foregroundStyle(Color.accentWalnut)
                            
                            if note.argumentsRichText.isEmpty {
                                Text("Belum ada argumen yang ditulis. Klik 'Edit' di sudut kanan atas untuk mulai membangun kasus.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .italic()
                            } else {
                                Text(note.argumentsRichText)
                                    .font(.system(.body, design: .default))
                                    .lineSpacing(4)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // 3. KARTU AKSI FEEDBACK (UX BARU - HANYA MUNCUL JIKA PUBLIK)
                        if note.visibility == .publicAccess {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Evaluasi & Penilaian Juri")
                                    .font(.headline)
                                    .foregroundStyle(Color.accentWalnut)
                                
                                Text("Kirim argumenmu ke antrean Adjudicator untuk mendapatkan penilaian berstandar format British Parliamentary.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Button(action: {
                                    // Berikan animasi agar UX terasa interaktif saat di-klik
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        viewModel.requestFeedback(for: note.id)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: note.isFeedbackRequested ? "checkmark.seal.fill" : "paperplane.fill")
                                        Text(note.isFeedbackRequested ? "Permintaan Diproses Juri" : "Minta Feedback Adjudicator")
                                        Spacer()
                                    }
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(note.isFeedbackRequested ? Color.btnPositive.opacity(0.15) : Color.btnPositive)
                                    .foregroundStyle(note.isFeedbackRequested ? Color.btnPositive : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .disabled(note.isFeedbackRequested) // Kunci tombol jika sudah diminta
                            }
                            .padding(20)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        
                    }
                    .padding(20)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") {
                            isShowingEditSheet = true
                        }
                        .fontWeight(.bold)
                        .foregroundStyle(Color.btnPositive)
                    }
                }
                .sheet(isPresented: $isShowingEditSheet) {
                    NavigationStack {
                        NoteEditorView(viewModel: viewModel, draftNote: note)
                    }
                }
            } else {
                Text("Catatan tidak ditemukan.")
            }
        }
    }
}
