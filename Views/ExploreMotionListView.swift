//
//  ExploreMotionListView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct ExploreMotionListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            // TOMBOL GENERATE (Anti-Spam & Interaktif)
            Button(action: { viewModel.triggerFetchMotion() }) {
                HStack(spacing: 8) {
                    if viewModel.isGenerating {
                        ProgressView().tint(.white)
                        Text("Mencari Mosi...").font(.subheadline.bold())
                    } else {
                        Image(systemName: "sparkles")
                        Text("Generate Random Motion").font(.subheadline.bold())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isGenerating ? Color.btnPositive.opacity(0.6) : Color.btnPositive)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(viewModel.isGenerating ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isGenerating)
            }
            .padding([.horizontal, .top])
            .disabled(viewModel.isGenerating) // Tombol mati saat loading
            
            // LIST MOSI (Anti-Glitch)
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredMotions) { motion in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack {
                                Image(systemName: "tag.fill").font(.caption)
                                Text(motion.category.uppercased()).font(.system(size: 10, weight: .black))
                            }
                            .foregroundStyle(Color.accentWalnut)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.accentWalnut.opacity(0.08)).clipShape(Capsule())
                            
                            Spacer()
                        }
                        
                        Text(motion.title)
                            .font(.system(.body, design: .serif, weight: .bold))
                            .foregroundStyle(Color.textCharcoal)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider().padding(.vertical, 4)
                        
                        // TOMBOL SIMPAN (Reaktif: Berubah seketika saat di-klik)
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                viewModel.createNoteFromMotion(motion)
                            }
                        }) {
                            HStack {
                                Image(systemName: motion.isWishlisted ? "checkmark.circle.fill" : "plus.circle.fill")
                                Text(motion.isWishlisted ? "Tersimpan di Catatan" : "Simpan ke Catatan")
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(motion.isWishlisted ? Color.btnPositive : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(motion.isWishlisted ? Color.btnPositive.opacity(0.15) : Color.btnNeutral)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(motion.isWishlisted) // Matikan tombol jika sudah disimpan
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.04), lineWidth: 1))
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.filteredMotions) // Animasi list aman
        }
    }
}

struct MyNotesListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.filteredNotes) { note in
                // MENGGUNAKAN NAVIGATION LINK: Langsung masuk ke NoteDetailView
                NavigationLink(destination: NoteDetailView(viewModel: viewModel, noteId: note.id)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.motionTitle)
                            .font(.system(.headline, design: .serif, weight: .bold))
                            .foregroundStyle(Color.textCharcoal)
                            .lineLimit(2)
                        
                        HStack(spacing: 4) {
                            Image(systemName: note.visibility == .privateAccess ? "lock.fill" : "globe")
                            Text(note.visibility == .privateAccess ? "PRIVAT" : "PUBLIK")
                        }
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(note.visibility == .privateAccess ? Color.btnNegative : Color.btnPositive)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(note.visibility == .privateAccess ? Color.btnNegative.opacity(0.08) : Color.btnPositive.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.white)
            }
            .onDelete(perform: viewModel.deleteNote)
        }
        .listStyle(.plain)
    }
}
