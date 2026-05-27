import SwiftUI


import SwiftUI

// 1. Entry Point dari MainView
struct MotionArchiveTabView: View {
    @StateObject private var viewModel = MotionArchiveViewModel(
        apiProxy: MockCloudFunctions(),
        localCache: MockCoreDataStorage()
    )
    
    var body: some View {
        MotionArchiveView(viewModel: viewModel)
    }
}

// 2. View Navigasi Utama
struct MotionArchiveView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State private var selectedTab = 0 // 0: Explore, 1: My Notes
    @State private var showingNewNoteSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Picker("Menu", selection: $selectedTab) {
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
                
                // Floating Action Button khusus untuk menambah Note manual
                if selectedTab == 1 {
                    Button(action: { showingNewNoteSheet = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2.bold()).foregroundStyle(.white)
                            .frame(width: 60, height: 60).background(Color.btnPositive)
                            .clipShape(Circle()).shadow(radius: 5)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Motion Archive")
            .searchable(text: $viewModel.searchText, prompt: "Cari mosi atau catatan...")
            .sheet(isPresented: $showingNewNoteSheet) {
                // Buka form catatan kosong
                NavigationStack {
                    NoteEditorView(
                        viewModel: viewModel,
                        draftNote: CaseBuildingNoteModel(id: UUID().uuidString, motionTitle: "", argumentsRichText: "", visibility: .privateAccess, isFeedbackRequested: false, updatedAt: Date())
                    )
                }
            }
        }
    }
}
