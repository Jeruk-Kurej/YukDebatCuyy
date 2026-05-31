//
//  CommunityNotesView.swift
//  YukDebatCuyy
//

import SwiftUI

/// Displays public case building notes shared by other debaters in the community.
/// Fulfills FR-1.3 allowing debaters to learn from public references.
struct CommunityNotesView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MotionArchiveViewModel

    // MARK: - Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.communityNotes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray.opacity(0.5))

                        Text("No community notes yet.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(viewModel.communityNotes) { note in
                        NavigationLink(
                            destination: NoteDetailView(
                                viewModel: viewModel,
                                note: note
                            )
                        ) {
                            NoteCard(note: note)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .onAppear {
            viewModel.fetchCommunityNotes()
        }
    }
}

// MARK: - Preview

#Preview {
    CommunityNotesView(
        viewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
    .background(Color.bgCream)
}
