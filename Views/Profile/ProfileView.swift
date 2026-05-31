import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var adjReqVM = AdjudicatorRequestViewModel()  // Inisialisasi ViewModel Juri

    @State private var showLogoutAlert = false
    @State private var showAdjudicatorForm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: - HEADER PROFIL
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable().frame(width: 100, height: 100)
                                .foregroundStyle(
                                    Color.accentWalnut.opacity(0.8)
                                )
                                .background(
                                    Circle().fill(Color.white).shadow(radius: 5)
                                )

                            VStack(spacing: 4) {
                                Text(authVM.currentUser?.name ?? "Memuat...")
                                    .font(.title2.bold()).foregroundStyle(
                                        Color.textCharcoal
                                    )
                                Text(authVM.currentUser?.email ?? "Memuat...")
                                    .font(.subheadline).foregroundStyle(
                                        .secondary
                                    )
                            }

                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text(
                                    (authVM.currentUser?.role.rawValue
                                        ?? "DEBATER").uppercased()
                                )
                            }
                            .font(.caption.bold()).foregroundStyle(
                                Color.btnPositive
                            )
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.btnPositive.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 8)

                        // MARK: - MENU PENGATURAN
                        VStack(spacing: 0) {
                            ProfileMenuRow(
                                icon: "person.text.rectangle",
                                title: "Edit Informasi Akun"
                            )

                            // TAMPILKAN MENU DAFTAR JURI JIKA ROLE = DEBATER
                            if authVM.currentUser?.role == .debater {
                                Divider().padding(.leading, 40)
                                Button(action: { showAdjudicatorForm = true }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "briefcase.fill")
                                            .font(.title3).foregroundStyle(
                                                Color.accentWalnut
                                            ).frame(width: 24)
                                        Text(
                                            adjReqVM.hasPendingRequest
                                                ? "Pengajuan Juri (Pending)"
                                                : "Daftar Menjadi Juri"
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
                                            Text("Menunggu").font(
                                                .caption.bold()
                                            ).foregroundStyle(.orange)
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
                                .disabled(adjReqVM.hasPendingRequest)  // Matikan klik jika sedang pending
                            }

                            Divider().padding(.leading, 40)
                            ProfileMenuRow(
                                icon: "bell.badge.fill",
                                title: "Notifikasi Sistem"
                            )
                            Divider().padding(.leading, 40)
                            ProfileMenuRow(
                                icon: "doc.text.fill",
                                title: "Syarat & Ketentuan (TOS)"
                            )
                        }
                        .background(Color.white).clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16).stroke(
                                Color.black.opacity(0.04),
                                lineWidth: 1
                            )
                        )

                        // MARK: - LOGOUT BUTTON
                        Button(action: { showLogoutAlert = true }) {
                            Text("Keluar (Log Out)").font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding()
                                .background(Color.btnNegative).clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                        }
                        .alert("Keluar", isPresented: $showLogoutAlert) {
                            Button("Batal", role: .cancel) {}
                            Button("Keluar", role: .destructive) {
                                authVM.logout()
                            }
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Profil Saya")
            .onAppear { adjReqVM.checkExistingRequest() }
            .sheet(isPresented: $showAdjudicatorForm) {
                ApplyAdjudicatorFormView(viewModel: adjReqVM)
            }
            .modernToast(
                message: $adjReqVM.statusMsg,
                isError: adjReqVM.statusMsg?.contains("Gagal") == true
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
