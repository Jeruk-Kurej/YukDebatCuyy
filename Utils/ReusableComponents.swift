//
//  ReusableComponents.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import SwiftUI

/// Reusable button component following the YukDebat interactive standards.
/// Encapsulates styling to adhere to the DRY (Don't Repeat Yourself) principle.
struct AppButton: View {
    let title: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.headline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

/// Standardized section header for UI typography hierarchy.
struct DesignHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}

/// Dynamic banner for displaying error or success states adhering to NFR Robustness.
struct StatusBanner: View {
    let message: String
    let isError: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.icloud.fill")
                .foregroundStyle(isError ? Color.btnNegative : Color.accentWalnut)
            Text(message)
                .font(.caption.bold())
                .foregroundStyle(isError ? Color.btnNegative : Color.accentWalnut)
            Spacer()
        }
        .padding()
        .background(isError ? Color.btnNegative.opacity(0.1) : Color.accentWalnut.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isError ? Color.btnNegative.opacity(0.3) : Color.accentWalnut.opacity(0.3), lineWidth: 1)
        )
    }
}

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
                .padding(.top, 16)
                // Animasi muncul dari atas
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1) // Memastikan selalu berada di atas konten lain
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
