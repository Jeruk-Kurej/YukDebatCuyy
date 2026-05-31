//
//  ProfileView.swift
//  YukDebatCuyy
//

import SwiftUI

/// Displays the user's account details and settings options.
struct ProfileView: View {

    // MARK: - Properties

    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var adjReqVM = AdjudicatorRequestViewModel()

    @State private var showLogoutAlert = false
    @State private var showAdjudicatorForm = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(
                                    Color.accentWalnut.opacity(0.8)
                                )
                                .background(
                                    Circle().fill(Color.white).shadow(radius: 5)
                                )

                            VStack(spacing: 4) {
                                // Mengganti fallback "Loading..." agar lebih rapi saat data belum masuk atau di Preview
                                Text(
                                    authVM.currentUser?.name ?? "YukDebat User"
                                )
                                .font(.title2.bold())
                                .foregroundStyle(Color.textCharcoal)

                                Text(
                                    authVM.currentUser?.email
                                        ?? "Fetching email..."
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                            // Badge Role (DEBATER) telah dihapus sesuai permintaan
                        }

                        // Settings Menu
                        VStack(spacing: 0) {
                            ProfileMenuRow(
                                icon: "person.text.rectangle",
                                title: "Edit Account Information"
                            )

                            Divider().padding(.leading, 40)
                            NavigationLink(
                                destination: MySparringFeedbacksView()
                                    .environmentObject(authVM)
                            ) {
                                ProfileMenuRow(
                                    icon: "star.bubble.fill",
                                    title: "My Sparring Feedbacks"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())

                            if authVM.currentUser?.role == .debater {
                                Divider().padding(.leading, 40)
                                Button(action: { showAdjudicatorForm = true }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "briefcase.fill")
                                            .font(.title3)
                                            .foregroundStyle(Color.accentWalnut)
                                            .frame(width: 24)

                                        Text(
                                            adjReqVM.hasPendingRequest
                                                ? "Adjudicator Request (Pending)"
                                                : "Apply as Adjudicator"
                                        )
                                        .font(
                                            .system(
                                                .body,
                                                design: .default,
                                                weight: .medium
                                            )
                                        )
                                        .foregroundStyle(Color.textCharcoal)

                                        Spacer()

                                        if adjReqVM.hasPendingRequest {
                                            Text("Pending")
                                                .font(.caption.bold())
                                                .foregroundStyle(.orange)
                                        } else {
                                            Image(systemName: "chevron.right")
                                                .font(.caption.bold())
                                                .foregroundStyle(
                                                    Color.gray.opacity(0.5)
                                                )
                                        }
                                    }
                                    .padding()
                                }
                                .disabled(adjReqVM.hasPendingRequest)
                            }

                            Divider().padding(.leading, 40)
                            ProfileMenuRow(
                                icon: "bell.badge.fill",
                                title: "System Notifications"
                            )

                            Divider().padding(.leading, 40)
                            ProfileMenuRow(
                                icon: "doc.text.fill",
                                title: "Terms of Service (TOS)"
                            )
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.04), lineWidth: 1)
                        )

                        // Logout Button
                        Button(action: { showLogoutAlert = true }) {
                            Text("Log Out")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.btnNegative)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .alert("Log Out", isPresented: $showLogoutAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Log Out", role: .destructive) {
                                authVM.logout()
                            }
                        } message: {
                            Text(
                                "Are you sure you want to log out from YukDebat?"
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("My Profile")
            .onAppear {
                adjReqVM.checkExistingRequest()
            }
            .sheet(isPresented: $showAdjudicatorForm) {
                ApplyAdjudicatorFormView(viewModel: adjReqVM)
            }
            .modernToast(
                message: $adjReqVM.statusMsg,
                isError: adjReqVM.statusMsg?.contains("Failed") == true
            )
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
