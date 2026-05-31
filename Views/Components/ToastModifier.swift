import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var message: String?
    var isError: Bool
    
    // State untuk menyimpan tugas timer agar bisa di-reset
    @State private var hideTask: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let msg = message {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(isError ? Color.btnNegative : Color.btnPositive)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.15), radius: 10, y: 5)
                        .padding(.bottom, 110)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(100)
                .onAppear {
                    // Mulai timer saat toast pertama kali muncul
                    scheduleHideTimer()
                }
                .onChange(of: message) { _ in
                    // Reset timer jika teksnya berubah (misal: dari "Uploading..." ke "Sukses!")
                    scheduleHideTimer()
                }
            }
        }
    }
    
    private func scheduleHideTimer() {
        // 1. Batalkan timer lama jika ada, untuk mencegah toast tertutup terlalu cepat
        hideTask?.cancel()
        
        // 2. Buat tugas baru untuk menghilangkan toast
        let task = DispatchWorkItem {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.message = nil
            }
        }
        
        // 3. Simpan tugas ke dalam State, lalu jalankan 3 detik dari sekarang
        hideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: task)
    }
}

extension View {
    func modernToast(message: Binding<String?>, isError: Bool = false) -> some View {
        self.modifier(ToastModifier(message: message, isError: isError))
    }
}
