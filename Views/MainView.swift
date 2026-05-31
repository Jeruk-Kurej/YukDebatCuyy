//
//  MainView.swift
//  YukDebatCuyy
//

import SwiftUI

/// The root view that determines whether to show the Authentication flow or the Main Tab Bar.
struct MainView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var motionVM = MotionArchiveViewModel(apiProxy: MockCloudFunctions(), localCache: LocalCoreDataStorage())
    
    // MARK: - Body
    
    var body: some View {
        if authVM.userSession != nil {
            // Pengguna sudah login, masuk ke fitur utama
            TabView {
                CompetitionView()
                    .tabItem { Label("Competitions", systemImage: "trophy.fill") }
                
                SparringView(viewModel: SparringViewModel(dbService: MockFirestoreService()))
                    .tabItem { Label("Sparring", systemImage: "figure.fencing") }
                
                MotionArchiveView(viewModel: motionVM)
                    .tabItem { Label("Motions", systemImage: "books.vertical.fill") }
                
                // Jika user adalah Admin, tampilkan Dashboard Admin, jika bukan tampilkan Profil
                if authVM.currentUser?.role == .admin {
                    ModerationDashboardView(viewModel: ModerationDashboardViewModel())
                        .tabItem { Label("Admin", systemImage: "shield.checkerboard") }
                } else {
                    ProfileView()
                        .tabItem { Label("Profile", systemImage: "person.fill") }
                }
            }
            .tint(Color.btnPositive)
        } else {
            // Pengguna belum login, arahkan ke unified AuthView
            AuthView()
        }
    }
}

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
