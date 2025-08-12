//
//  AuthView.swift
//  loop
//
//  Created by Andrew Ondara on 7/20/25.
//
// Sign in page.
//

import SwiftUI
import Supabase

struct AuthView: View {
    // UI state
    @State private var phone: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @FocusState private var isPhoneFocused: Bool

    // Hooks to wire later (navigation, analytics, etc.)
    var onSubmit: ((String) -> Void)?
    var onTapSignUp: (() -> Void)?

    private var isValidPhone: Bool {
        phone.filter(\.isNumber).count >= 10
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer(minLength: 60)

                // Wordmark
                Text("loop")
                    .font(.custom("Clicker Script", size: 64))
                    .foregroundColor(.black)
                    .padding(.bottom, 4)

                // Phone field — same bubble as Registration
                TextField(
                    "Phone Number",
                    text: $phone,
                    prompt: Text("Phone Number").foregroundColor(Color(hex: 0x8C8C8C))
                )
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .focused($isPhoneFocused)
                .authBubble()

                // Submit — same height/radius/width as bubbles
                Button {
                    isPhoneFocused = false
                    Task { await sendCode() }
                } label: {
                    ZStack {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text("SUBMIT").font(.system(size: 16, weight: .semibold)) }
                    }
                    .frame(maxWidth: .infinity, minHeight: AuthUI.bubbleHeight)
                }
                .background(Color.black)
                .foregroundStyle(.white)
                .cornerRadius(AuthUI.bubbleRadius)
                .disabled(!isValidPhone || isLoading)
                .opacity((isValidPhone && !isLoading) ? 1 : 0.5)
                .animation(.easeInOut(duration: 0.12), value: isLoading)
                .animation(.easeInOut(duration: 0.12), value: isValidPhone)

                // Error (if any)
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("Error: \(errorMessage)")
                }

                // Sign-up line
                HStack(spacing: 4) {
                    Text("No account? Sign up")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    Button { onTapSignUp?() } label: {
                        Text("here.")
                            .underline()
                            .foregroundColor(.black)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)

                Spacer(minLength: 40)
            }
            // one shared padding so field + button have identical width
            .padding(.horizontal, 40)
        }
        .onAppear { isPhoneFocused = true }
        .onTapGesture { isPhoneFocused = false }
    }

    // MARK: - Actions
    @MainActor
    private func sendCode() async {
        guard isValidPhone, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await supabase.auth.signInWithOTP(phone: phone)
            onSubmit?(phone) // navigate to VerifyCode flow
        } catch {
            errorMessage = "Couldn’t send code. Please try again."
            #if DEBUG
            print("Supabase OTP error:", error.localizedDescription)
            #endif
        }
    }
}

// MARK: - Preview
#Preview {
    AuthView(
        onSubmit: { print("Code sent to:", $0) },
        onTapSignUp: { print("Sign up tapped") }
    )
}

// MARK: - Tiny color helper 
private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}
