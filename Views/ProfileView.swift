import SwiftUI

struct ProfileView: View {
    // 1. Suntikkan AuthViewModel untuk mengambil sesi data real-time
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: - HEADER PROFIL
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(Color.accentWalnut.opacity(0.8))
                                .background(Circle().fill(Color.white).shadow(radius: 5))
                            
                            VStack(spacing: 4) {
                                // 2. Tampilkan Nama Asli dari Database
                                Text(authVM.currentUser?.name ?? "Memuat Nama...")
                                    .font(.title2.bold())
                                    .foregroundStyle(Color.textCharcoal)
                                
                                // 3. Tampilkan Email Asli
                                Text(authVM.currentUser?.email ?? "Memuat Email...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                // 4. Tampilkan Role Asli (Debater / Admin / Adjudicator)
                                Text((authVM.currentUser?.role.rawValue ?? "DEBATER").uppercased())
                            }
                            .font(.caption.bold())
                            .foregroundStyle(Color.btnPositive)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.btnPositive.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 20)
                        
                        // MARK: - MENU PENGATURAN
                        VStack(spacing: 0) {
                            ProfileMenuRow(icon: "person.text.rectangle", title: "Edit Informasi Akun")
                            Divider().padding(.leading, 40)
                            ProfileMenuRow(icon: "bell.badge.fill", title: "Notifikasi Sistem")
                            Divider().padding(.leading, 40)
                            ProfileMenuRow(icon: "doc.text.fill", title: "Syarat & Ketentuan (TOS)")
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.04), lineWidth: 1))
                        
                        // MARK: - LOGOUT BUTTON
                        Button(action: { showLogoutAlert = true }) {
                            Text("Keluar (Log Out)")
                                .font(.headline)
                                .foregroundStyle(Color.btnNegative)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.btnNegative.opacity(0.3), lineWidth: 1))
                        }
                        .alert("Keluar dari Akun", isPresented: $showLogoutAlert) {
                            Button("Batal", role: .cancel) { }
                            
                            // 5. Panggil fungsi Logout Asli dari ViewModel
                            Button("Keluar", role: .destructive) {
                                authVM.logout()
                            }
                        } message: {
                            Text("Apakah Anda yakin ingin keluar dari aplikasi YukDebat?")
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Profil Saya")
        }
    }
}

// Subkomponen Menu
struct ProfileMenuRow: View {
    let icon: String
    let title: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentWalnut)
                .frame(width: 24)
            Text(title)
                .font(.system(.body, design: .default, weight: .medium))
                .foregroundStyle(Color.textCharcoal)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(Color.gray.opacity(0.5))
        }
        .padding()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel()) // Wajib disuntik agar Canvas tidak error
}
