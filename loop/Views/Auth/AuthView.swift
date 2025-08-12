//
//  AuthView.swift
//  loop
//
//  Created by Andrew Ondara on 7/17/25.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var successMessage: String?
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @FocusState private var isEmailFocused: Bool
    
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Sarah Luan
                Color(.white)
                    .ignoresSafeArea()
                    .foregroundStyle(.white)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Top section with logo and preview
                        VStack(spacing: 32) {
                            Spacer()
                                .frame(height: max(80, geometry.safeAreaInsets.top + 60))
                            
                            VStack(spacing: 24) {
                                // Logo area with app name
                                VStack(spacing: 16) {
                                    Image("LoopLogo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                            .frame(height: 48)
                        
                        // Email section
                        VStack(spacing: 24) {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Email")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                
                                HStack(spacing: 14) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 16, weight: .medium))
                                        .frame(width: 20)
                                    
                                    TextField("your@email.com", text: $email)
                                        .keyboardType(.emailAddress)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                        .font(.system(size: 16, weight: .medium))
                                        .focused($isEmailFocused)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            if !email.isEmpty && !isLoading {
                                                signInButtonTapped()
                                            }
                                        }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .stroke(
                                            isEmailFocused ? Color.accentColor : Color(.systemGray4),
                                            lineWidth: isEmailFocused ? 2 : 1
                                        )
                                )
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                            }
                            
                            // Continue button with app styling
                            Button(action: signInButtonTapped) {
                                HStack(spacing: 10) {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(0.9)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    
                                    Text(isLoading ? "Sending magic link..." : "Continue")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            isLoading || email.isEmpty
                                            ? Color(.systemGray4)
                                            : Color.accentColor
                                        )
                                )
                                .foregroundColor(.white)
                                .shadow(
                                    color: (isLoading || email.isEmpty) ? .clear : Color.accentColor.opacity(0.3),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            }
                            .disabled(isLoading || email.isEmpty)
                            .scaleEffect(isLoading ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: isLoading)
                            
                            // Info text
                            VStack(spacing: 8) {
                                Text("✨ We'll send you a magic link")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.secondary)
                                
                                Text("New to Loop? We'll create your account automatically")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.tertiary)
                            }
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            
                            // Result message with app styling
                            if successMessage != nil || errorMessage != nil {
                                resultMessageView()
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                            .frame(height: max(60, geometry.safeAreaInsets.bottom + 40))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: successMessage)
                .animation(.easeInOut(duration: 0.3), value: errorMessage)
            }
        }
        .onTapGesture {
            isEmailFocused = false
        }
        .onOpenURL { url in
            Task {
                do {
                    try await supabase.auth.session(from: url)
                } catch {
                    withAnimation {
                        self.errorMessage = error.localizedDescription
                        self.successMessage = nil
                        showSuccess = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func resultMessageView() -> some View {
        HStack(spacing: 14) {
            if let successMessage {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGreen))
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check your email! 📧")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text(successMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
            } else if let errorMessage {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemOrange))
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Oops! Something went wrong")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    func signInButtonTapped() {
        isEmailFocused = false
        
        Task {
            isLoading = true
            successMessage = nil
            errorMessage = nil
            
            defer {
                isLoading = false
            }
            
            do {
                try await supabase.auth.signInWithOTP(
                    email: email,
                    redirectTo: URL(string: "loop://login-callback"),
                    shouldCreateUser: false
                )
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    successMessage = "Click the link in your inbox to continue to Loop"
                    errorMessage = nil
                    showSuccess = true
                }
                
            } catch {
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    errorMessage = error.localizedDescription
                    successMessage = nil
                    showSuccess = false
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
