//
//  MotionArchiveView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct MotionArchiveView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State private var selectedTab = 0 // 0: Explore, 1: My Notes
    @State private var showingNewNoteSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Picker("Menu Navigasi", selection: $selectedTab) {
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
                
                // Floating Action Button khusus untuk menulis Note manual bebas (UC01)
                if selectedTab == 1 {
                    Button(action: { showingNewNoteSheet = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.btnPositive)
                            .clipShape(Circle())
                            .shadow(color: Color.btnPositive.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Motion Archive")
            .searchable(text: $viewModel.searchText, prompt: "Cari mosi atau catatan...")
            .sheet(isPresented: $showingNewNoteSheet) {
                NavigationStack {
                    // Perbaikan: Menyertakan ownerId agar sinkron dengan model
                    NoteEditorView(
                        viewModel: viewModel,
                        draftNote: CaseBuildingNoteModel(
                            id: UUID().uuidString,
                            ownerId: "user_me",
                            motionTitle: "",
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
}

// 1. Entry Point dari MainView
struct MotionArchiveTabView: View {
    @StateObject private var viewModel = MotionArchiveViewModel(
        apiProxy: MockCloudFunctions(),
        // PERBAIKAN: Gunakan LocalCoreDataStorage sesuai dengan nama class di repo kamu
        localCache: LocalCoreDataStorage()
    )
    
    var body: some View {
        MotionArchiveView(viewModel: viewModel)
    }
}
