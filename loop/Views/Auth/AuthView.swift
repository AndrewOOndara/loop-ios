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

    // Hook for handling successful phone submission
    var onSubmit: ((String) -> Void)?
    

    private var isValidPhone: Bool {
        formattedPhone != nil
    }

    var body: some View {
        ZStack {
            BrandColor.cream.ignoresSafeArea()

            VStack(spacing: BrandSpacing.lg) {
                Spacer(minLength: BrandSpacing.huge)

                // Wordmark
                LoopWordmark(fontSize: 90, color: BrandColor.orange)
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
    private var formattedPhone: String? {
        let digits = phone.filter(\.isNumber)
        // ✅ US-only case: enforce 10 digits
        if digits.count == 10 {
            return "+1" + digits
        }
        // If the user already included +countrycode
        if phone.hasPrefix("+") {
            return phone
        }
        return nil
    }

    private func sendCode() async {
        guard let formattedPhone, !isLoading else {
            errorMessage = "Please enter a valid phone number."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await supabase.auth.signInWithOTP(phone: formattedPhone)
            onSubmit?(formattedPhone)
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
        onSubmit: { print("Code sent to:", $0) }
    )
}

// Color hex helper centralized in AuthStyles
