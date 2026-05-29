import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Buat Akun Baru")
                        .font(.system(.title, design: .serif, weight: .bold))
                    Text("Bergabung dengan komunitas debat sekarang.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)
                
                VStack(spacing: 16) {
                    TextField("Nama Lengkap", text: $fullName)
                        .padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    TextField("Alamat Email", text: $email)
                        .keyboardType(.emailAddress).textInputAutocapitalization(.never)
                        .padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    SecureField("Kata Sandi (Min. 6 Karakter)", text: $password)
                        .padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if let errorMessage = authVM.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.btnNegative)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    authVM.register(email: email, password: password, fullName: fullName)
                }) {
                    HStack {
                        if authVM.isLoading { ProgressView().tint(.white) } else { Text("Daftar Akun") }
                    }
                    .font(.headline.bold()).foregroundStyle(.white).frame(maxWidth: .infinity).padding()
                    .background(email.isEmpty || password.count < 6 || fullName.isEmpty ? Color.gray : Color.btnPositive)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(email.isEmpty || password.count < 6 || fullName.isEmpty || authVM.isLoading)
                
                Spacer()
            }
            .padding(32)
        }
        // PERBAIKAN: Bersihkan error saat halaman ini dibuka
        .onAppear {
            authVM.errorMessage = nil
        }
    }
}
