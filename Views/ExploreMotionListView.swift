//
//  ExploreMotionListView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct ExploreMotionListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State private var selectedMotionForNote: MotionModel?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            Button(action: { viewModel.triggerFetchMotion() }) {
                Label("Generate Random Motion", systemImage: "sparkles")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.btnPositive)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding([.horizontal, .top])
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredMotions) { motion in
                    Button(action: { selectedMotionForNote = motion }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .font(.caption)
                                Text(motion.category.uppercased())
                                    .font(.system(size: 10, weight: .black))
                            }
                            .foregroundStyle(Color.accentWalnut)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentWalnut.opacity(0.08))
                            .clipShape(Capsule())
                            
                            Text(motion.title)
                                .font(.system(.body, design: .serif, weight: .bold))
                                .foregroundStyle(Color.textCharcoal)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.04), lineWidth: 1))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)
        }
        .sheet(item: $selectedMotionForNote) { motion in
            NavigationStack {
                // Perbaikan: Menyertakan ownerId agar sesuai dengan struktur model
                NoteEditorView(
                    viewModel: viewModel,
                    draftNote: CaseBuildingNoteModel(
                        id: UUID().uuidString,
                        ownerId: "user_me",
                        motionTitle: motion.title,
                        argumentsRichText: "",
                        visibility: .privateAccess,
                        isFeedbackRequested: false,
                        updatedAt: Date()
                    )
                )
            }
        }
    }
}

struct MyNotesListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State private var noteToEdit: CaseBuildingNoteModel?
    
    var body: some View {
        List {
            ForEach(viewModel.filteredNotes) { note in
                Button(action: { noteToEdit = note }) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.motionTitle)
                            .font(.system(.headline, design: .serif, weight: .bold))
                            .foregroundStyle(Color.textCharcoal)
                        
                        HStack(spacing: 4) {
                            Image(systemName: note.visibility == .privateAccess ? "lock.fill" : "globe")
                            Text(note.visibility == .privateAccess ? "PRIVAT" : "PUBLIK")
                        }
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(note.visibility == .privateAccess ? Color.btnNegative : Color.btnPositive)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
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
        .sheet(item: $noteToEdit) { note in
            NavigationStack {
                NoteEditorView(viewModel: viewModel, draftNote: note)
            }
        }
    }
}
