//
//  ToastModifier.swift
//  YukDebatCuyy
//

import SwiftUI

/// A custom view modifier that presents a modern, floating toast notification.
/// Includes an automatic dismissal timer that resets upon content changes.
struct ToastModifier: ViewModifier {

    // MARK: - Properties

    @Binding var message: String?
    var isError: Bool

    @State private var hideTask: DispatchWorkItem?

    // MARK: - Body

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
                        .background(
                            isError ? Color.btnNegative : Color.btnPositive
                        )
                        .clipShape(Capsule())
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 10,
                            y: 5
                        )
                        .padding(.bottom, 110)
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                }
                .zIndex(100)
                .onAppear {
                    scheduleHideTimer()
                }
                .onChange(of: message) { _ in
                    scheduleHideTimer()
                }
            }
        }
    }

    // MARK: - Methods

    /// Cancels any existing hide timer and schedules a new one for 3 seconds.
    private func scheduleHideTimer() {
        hideTask?.cancel()

        let task = DispatchWorkItem {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.message = nil
            }
        }

        hideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: task)
    }
}

// MARK: - View Extension

extension View {
    /// Attaches a modern toast notification to the view hierarchy.
    func modernToast(message: Binding<String?>, isError: Bool = false)
        -> some View
    {
        self.modifier(ToastModifier(message: message, isError: isError))
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("Background Content")
            .font(.largeTitle)
            .foregroundStyle(.gray)
    }
    .modernToast(
        message: .constant("Successfully joined the sparring room!"),
        isError: false
    )
}
