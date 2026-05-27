//
//  MainView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import SwiftUI

// MARK: - Main Navigation (Router)
struct MainView: View {
    var body: some View {
        TabView {
            // TAB 1: HOME
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // TAB 2: COMPETITION (UC05)
            CompetitionView()
                .tabItem {
                    Label("Competition", systemImage: "trophy.fill")
                }
            
            // TAB 3: SPARRING (UC02)
            SparringView(viewModel: SparringViewModel(dbService: MockFirestoreService()))
                .tabItem {
                    Label("Sparring", systemImage: "person.2.fill")
                }
            
            // TAB 4: MOTION ARCHIVE (Gabungan UC01, UC03, UC04)
            // Di sinilah nanti user mencari mosi, generate, dan menulis argumen (Case Building)
            MotionArchiveTabView()
                .tabItem {
                    Label("Motions", systemImage: "books.vertical.fill")
                }
            
            // TAB 5: PROFILE / SETTINGS
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(Color.btnPositive) // Menggunakan warna hijau YukDebat
    }
}

/// Placeholder untuk Tab 5 (Profile)
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.accentWalnut)
                    Text("Settings & Profile")
                        .font(.headline)
                    Text("Manajemen akun, ganti role sementara, dan tombol Log Out.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainView()
}
