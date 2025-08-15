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
        ValidationHelper.isValidPhone(phone)
    }

    var body: some View {
        ZStack {
            BrandColor.cream.ignoresSafeArea()

            VStack(spacing: BrandSpacing.lg) {
                Spacer(minLength: BrandSpacing.huge)

                // Wordmark
                LoopWordmark(fontSize: 64, color: BrandColor.orange)
                    .padding(.bottom, BrandSpacing.xs)

                // Phone field
                TextField(
                    "Phone Number",
                    text: $phone,
                    prompt: Text("Phone Number").foregroundColor(BrandColor.lightBrown)
                )
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .focused($isPhoneFocused)
                .foregroundColor(BrandColor.black)
                .onChange(of: phone) { oldValue, newValue in
                    // Only allow digits
                    let cleaned = ValidationHelper.cleanPhoneInput(newValue)
                    if cleaned != newValue {
                        phone = cleaned
                    }
                    // Limit to 10 digits
                    if cleaned.count > 10 {
                        phone = String(cleaned.prefix(10))
                    }
                    // Clear error when user starts typing
                    if errorMessage != nil {
                        errorMessage = nil
                    }
                }
                .authInput(isValid: phone.isEmpty || isValidPhone, isFocused: isPhoneFocused)

                // Submit button
                Button {
                    isPhoneFocused = false
                    Task { await sendCode() }
                } label: {
                    ZStack {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text("SUBMIT").font(BrandFont.headline) }
                    }
                }
                .primaryButton(isEnabled: isValidPhone && !isLoading)
                .disabled(!isValidPhone || isLoading)

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .errorMessage()
                }

                // Sign-up line
                HStack(spacing: BrandSpacing.xs) {
                    Text("No account? Sign up")
                        .foregroundColor(BrandColor.black)
                        .font(BrandFont.body)
                    Button {
                        print("Sign up here tapped")
                        onTapSignUp?()
                    } label: {
                        Text("here.")
                            .underline()
                            .foregroundColor(BrandColor.orange)
                            .font(BrandFont.body)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, BrandSpacing.xs)

                Spacer(minLength: BrandSpacing.xxxl)
            }
            .padding(.horizontal, BrandSpacing.xxxl)
        }
        .onAppear { isPhoneFocused = true }
        .onTapGesture {
            if isPhoneFocused {
                isPhoneFocused = false
            }
        }
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
            onSubmit?(phone)
        } catch {
            errorMessage = "Couldn't send code. Please try again."
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

// Color hex helper centralized in AuthStyles
