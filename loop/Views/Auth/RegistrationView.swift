//
//  AuthView.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
// Registration page.
//

import SwiftUI

struct RegistrationView: View {
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var phone     = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    enum Field { case first, last, phone }

    // Hooks you can wire later
    var onSubmit: ((String, String) -> Void)?     // (fullName, phone)
    var onTapSignIn: (() -> Void)?                // back to Login

    private var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        ValidationHelper.isValidPhone(phone)
    }

    var body: some View {
        ZStack {
            BrandColor.cream.ignoresSafeArea()

            VStack(spacing: BrandSpacing.lg) {
                Spacer(minLength: BrandSpacing.huge)

                // Wordmark
                Text("sign up")
                    .font(.custom(BrandFont.wordmark, size: 64))
                    .foregroundColor(BrandColor.orange)
                    .padding(.bottom, BrandSpacing.xs)

                // First name
                TextField("First Name", text: $firstName,
                          prompt: Text("First Name").foregroundColor(BrandColor.lightBrown))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .first)
                    .foregroundColor(BrandColor.black)
                    .authInput(isValid: firstName.isEmpty || !firstName.trimmingCharacters(in: .whitespaces).isEmpty, 
                              isFocused: focusedField == .first)

                // Last name
                TextField("Last Name", text: $lastName,
                          prompt: Text("Last Name").foregroundColor(BrandColor.lightBrown))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .last)
                    .foregroundColor(BrandColor.black)
                    .authInput(isValid: lastName.isEmpty || !lastName.trimmingCharacters(in: .whitespaces).isEmpty, 
                              isFocused: focusedField == .last)

                // Phone
                TextField("Phone Number", text: $phone,
                          prompt: Text("Phone Number").foregroundColor(BrandColor.lightBrown))
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .focused($focusedField, equals: .phone)
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
                    }
                    .authInput(isValid: phone.isEmpty || ValidationHelper.isValidPhone(phone), 
                              isFocused: focusedField == .phone)

                // Submit button
                Button {
                    hideKeyboard()
                    isLoading = true
                    let fullName = "\(firstName.trimmingCharacters(in: .whitespaces)) \(lastName.trimmingCharacters(in: .whitespaces))"
                    onSubmit?(fullName, phone)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isLoading = false }
                } label: {
                    ZStack {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text("SIGN UP").font(BrandFont.headline) }
                    }
                }
                .primaryButton(isEnabled: isValid && !isLoading)
                .disabled(!isValid || isLoading)

                // Sign-in link
                HStack(spacing: BrandSpacing.xs) {
                    Text("Already a user? Sign in")
                        .foregroundColor(BrandColor.black)
                        .font(BrandFont.body)
                    Button(action: { onTapSignIn?() }) {
                        Text("here.")
                            .underline()
                            .foregroundColor(BrandColor.orange)
                            .font(BrandFont.body)
                    }.buttonStyle(.plain)
                }
                .padding(.top, BrandSpacing.xs)

                Spacer(minLength: BrandSpacing.xxxl)
            }
            .padding(.horizontal, BrandSpacing.xxxl)
        }
        .onAppear { focusedField = .first }
        .onTapGesture {
            if focusedField != nil {
                hideKeyboard()
            }
        }
    }
}

extension View {
    func hideKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
#endif
    }
}

// Color hex helper centralized in AuthStyles

#Preview {
    RegistrationView(
        onSubmit: { name, phone in print("Register:", name, phone) },
        onTapSignIn: { print("Go to login") }
    )
}
