import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var message: String?
    var isError: Bool

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
                        // Menggunakan warna standar desainmu
                        .background(
                            isError ? Color.btnNegative : Color.btnPositive
                        )
                        .clipShape(Capsule())
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 10,
                            y: 5
                        )
                        // Posisi aman di atas Tab Bar
                        .padding(.bottom, 110)
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                }
                .zIndex(100)
                // PERBAIKAN BUG: Kembalikan fungsi timer otomatis di sini!
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(
                            .spring(response: 0.4, dampingFraction: 0.8)
                        ) {
                            message = nil
                        }
                    }
                }
            }
        }
    }
}

// Ekstensi agar gampang dipanggil di View mana saja
extension View {
    func modernToast(message: Binding<String?>, isError: Bool = false)
        -> some View
    {
        self.modifier(ToastModifier(message: message, isError: isError))
    }
}
