import SwiftUI

struct MotionArchiveView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var selectedTab = 0 // 0: Explore, 1: My Notes
    @State private var showingNewNoteSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()
                
                if authVM.currentUser?.role == .admin {
                    ExploreMotionListView(viewModel: viewModel)
                } else {
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
                    
                    // FAB khusus untuk user biasa (bukan Admin)
                    if selectedTab == 1 {
                        Button(action: { showingNewNoteSheet = true }) {
                            Image(systemName: "square.and.pencil")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.btnPositive)
                                .clipShape(Circle())
                                // PERBAIKAN STYLE: Shadow konsisten dan elegan
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        // PERBAIKAN PLACEMENT: Konsisten di semua page
                        .padding(.trailing, 24)
                        .padding(.bottom, 110)
                    }
                }
            }
            .navigationTitle(authVM.currentUser?.role == .admin ? "Daftar Mosi" : "Motion Archive")
            .searchable(text: $viewModel.searchText, prompt: "Cari mosi...")
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
