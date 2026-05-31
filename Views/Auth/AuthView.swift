//
//  AuthView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 01/06/26.
//

import SwiftUI

/// A unified authentication view handling both Login and Registration.
/// Uses state toggling for seamless, back-button-free transitions.
struct AuthView: View {

    // MARK: - Properties

    @EnvironmentObject var authVM: AuthViewModel

    @State private var isLoginMode: Bool = true
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 8) {
                            Image(systemName: "quote.bubble.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.accentWalnut)

                            Text("YukDebat")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color.textCharcoal)

                            Text(
                                isLoginMode
                                    ? "Welcome back, Debater!"
                                    : "Join the Arena!"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 20)

                        // Form Fields Section
                        VStack(spacing: 16) {
                            if !isLoginMode {
                                TextField("Full Name", text: $fullName)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color.black.opacity(0.05),
                                                lineWidth: 1
                                            )
                                    )
                                    // Animasi masuk yang mulus dari atas
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .top)
                                                .combined(with: .opacity),
                                            removal: .opacity
                                        )
                                    )
                            }

                            TextField("Email Address", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(
                                        Color.black.opacity(0.05),
                                        lineWidth: 1
                                    )
                                )

                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(
                                        Color.black.opacity(0.05),
                                        lineWidth: 1
                                    )
                                )
                        }
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.8),
                            value: isLoginMode
                        )

                        // Action Button
                        Button(action: handleAction) {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(isLoginMode ? "Log In" : "Register")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                isValidForm ? Color.btnPositive : Color.gray
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(authVM.isLoading || !isValidForm)
                        .padding(.top, 8)

                        // Toggle Mode Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isLoginMode.toggle()
                            }
                        }) {
                            Text(
                                isLoginMode
                                    ? "Don't have an account? Sign Up"
                                    : "Already have an account? Log In"
                            )
                            .font(.subheadline)
                            .foregroundStyle(Color.accentWalnut)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .modernToast(message: $authVM.errorMessage, isError: true)
        }
    }

    // MARK: - Methods

    private var isValidForm: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty && !fullName.isEmpty
        }
    }

    private func handleAction() {
        if isLoginMode {
            authVM.login(email: email, password: password)
        } else {
            authVM.register(
                email: email,
                password: password,
                fullName: fullName
            )
        }
    }
}

// MARK: - Preview

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
