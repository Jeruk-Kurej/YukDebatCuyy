import SwiftUI

struct MainView: View {
    @EnvironmentObject var authVM: AuthViewModel

    // Inisialisasi semua ViewModel yang dibutuhkan oleh tiap tab
    @StateObject private var motionViewModel = MotionArchiveViewModel(
        apiProxy: MockCloudFunctions(),
        localCache: LocalCoreDataStorage()
    )

    @StateObject private var compViewModel = CompetitionViewModel()

    // PERBAIKAN: Menambahkan inisialisasi ModerationDashboardViewModel
    @StateObject private var modViewModel = ModerationDashboardViewModel(
        dbService: MockFirestoreService(),
        storageService: MockCloudStorage()
    )

    var body: some View {
        TabView {
            
            // 1. COMPETITION
            CompetitionView()
                .tabItem { Label("Competition", systemImage: "trophy.fill") }
            
            // 2. SPARRING
            SparringView(
                viewModel: SparringViewModel(dbService: MockFirestoreService())
            )
            .tabItem { Label("Sparring", systemImage: "figure.boxing") }

            // 3. MOTIONS
            MotionArchiveView(viewModel: motionViewModel)
                .tabItem {
                    Label("Motions", systemImage: "books.vertical.fill")
                }

            // AKSES KHUSUS ADMIN (UC06 - Manage System Content & Users)
            if authVM.currentUser?.role == .admin {
                ModerationDashboardView(viewModel: modViewModel)
                    .tabItem {
                        Label("Admin", systemImage: "shield.checkerboard")
                    }
            }

            // AKSES KHUSUS JURI (UC04 - Manage Evaluation)
            if authVM.currentUser?.role == .adjudicator {
                AdjudicatorDashboardView(motionViewModel: motionViewModel)
                    .tabItem { Label("Juri", systemImage: "briefcase.fill") }
            }

            // 4. PROFILE
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.btnPositive)
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
