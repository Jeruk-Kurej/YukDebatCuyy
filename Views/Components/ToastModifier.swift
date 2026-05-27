//
//  ToastModifier.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

// MARK: - Modern iOS Toast / HUD (HIG Compliant)
struct ToastModifier: ViewModifier {
    @Binding var message: String?
    let isError: Bool
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if let text = message {
                HStack(spacing: 12) {
                    Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .foregroundStyle(isError ? Color.btnNegative : Color.btnPositive)
                    
                    Text(text)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.textCharcoal)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial) // Efek blur khas iOS
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
                
                // REVISI: Padding top ditambah agar Toast tidak tertutup NavigationTitle atau Island
                // Angka 60 biasanya cukup aman untuk hampir semua model iPhone
                .padding(.top, 60)
                
                // Animasi muncul dari atas
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100) // ZIndex tinggi agar selalu di paling atas konten
                .onAppear {
                    // Hilang otomatis setelah 3 detik
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(.spring()) {
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
    func modernToast(message: Binding<String?>, isError: Bool = false) -> some View {
        self.modifier(ToastModifier(message: message, isError: isError))
    }
}
