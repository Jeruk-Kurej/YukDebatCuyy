import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingRegister = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.accentWalnut)
                            .padding(.bottom, 16)
                        
                        Text("YukDebat")
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                        Text("Sistem Manajemen Debat Terpadu")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 32)
                    
                    VStack(spacing: 16) {
                        TextField("Alamat Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        SecureField("Kata Sandi", text: $password)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if let errorMessage = authVM.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Color.btnNegative)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        authVM.login(email: email, password: password)
                    }) {
                        HStack {
                            if authVM.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Masuk")
                            }
                        }
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty || password.isEmpty ? Color.gray : Color.btnPositive)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)
                    
                    Button(action: {
                        // PERBAIKAN: Bersihkan error sebelum pindah ke register (opsional tapi aman)
                        authVM.errorMessage = nil
                        isShowingRegister = true
                    }) {
                        Text("Belum punya akun? **Daftar di sini**")
                            .font(.subheadline)
                            .foregroundStyle(Color.accentWalnut)
                    }
                    .padding(.top, 16)
                }
                .padding(32)
            }
            .navigationDestination(isPresented: $isShowingRegister) {
                RegisterView()
            }
            // PERBAIKAN: Bersihkan error saat kembali ke halaman ini
            .onAppear {
                authVM.errorMessage = nil
            }
        }
    }
}
