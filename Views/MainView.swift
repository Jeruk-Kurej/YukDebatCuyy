//
//  MainView.swift
//  YukDebatCuyy
//

import SwiftUI

/// The root view that determines whether to show the Authentication flow or the Main Tab Bar.
struct MainView: View {

    // MARK: - Properties

    @EnvironmentObject var authVM: AuthViewModel

    // Using @StateObject ensures the ViewModels survive tab switching without resetting.
    @StateObject private var motionVM = MotionArchiveViewModel(
        apiProxy: MockCloudFunctions(),
        localCache: LocalCoreDataStorage()
    )
    @StateObject private var sparringVM = SparringViewModel(
        dbService: MockFirestoreService()
    )

    // MARK: - Body

    var body: some View {
        if authVM.userSession != nil {
            TabView {
                CompetitionView()
                    .tabItem {
                        Label("Competitions", systemImage: "trophy.fill")
                    }

                SparringView(viewModel: sparringVM)
                    .tabItem {
                        Label("Sparring", systemImage: "person.2.fill")
                    }

                MotionArchiveView(viewModel: motionVM)
                    .tabItem {
                        Label("Motions", systemImage: "books.vertical.fill")
                    }

                if authVM.currentUser?.role == .admin {
                    ModerationDashboardView(
                        viewModel: ModerationDashboardViewModel()
                    )
                    .tabItem {
                        Label("Admin", systemImage: "shield.checkerboard")
                    }
                } else {
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                }
            }
            .tint(Color.btnPositive)
        } else {
            AuthView()
        }
    }
}

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
