//
//  MotionArchiveView.swift
//  YukDebatCuyy
//

import SwiftUI

/// The main entry point for the Motion feature.
/// Manages the navigation between Explore Motions and My Case Notes based on user roles.
struct MotionArchiveView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedTab = 0
    @State private var showingNewNoteSheet = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                if authVM.currentUser?.role == .admin {
                    ExploreMotionListView(viewModel: viewModel)
                } else {
                    VStack(spacing: 0) {
                        Picker("Navigation Menu", selection: $selectedTab) {
                            Text("Explore Motions").tag(0)
                            Text("My Case Notes").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        if selectedTab == 0 {
                            ExploreMotionListView(viewModel: viewModel)
                        } else {
                            MyNotesListView(viewModel: viewModel)
                        }
                    }

                    if selectedTab == 1 {
                        Button(action: { showingNewNoteSheet = true }) {
                            Image(systemName: "square.and.pencil")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.btnPositive)
                                .clipShape(Circle())
                                .shadow(
                                    color: Color.black.opacity(0.15),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 110)
                    }
                }
            }
            .navigationTitle(
                authVM.currentUser?.role == .admin
                    ? "Motions List" : "Motion Archive"
            )
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search motions..."
            )
            .sheet(isPresented: $showingNewNoteSheet) {
                NavigationStack {
                    NoteEditorView(
                        viewModel: viewModel,
                        draftNote: CaseBuildingNoteModel(
                            id: UUID().uuidString,
                            ownerId: authVM.currentUser?.id ?? "user_me",
                            motionTitle: "",
                            argumentsRichText: "",
                            visibility: .privateAccess,
                            isFeedbackRequested: false,
                            updatedAt: Date()
                        ),
                        isNewNote: true
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MotionArchiveView(
        viewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
    .environmentObject(AuthViewModel())
}
