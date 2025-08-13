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
        phone.filter(\.isNumber).count >= 10
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer(minLength: 60)

                // Wordmark
                Text("sign up")
                    .font(.custom("Clicker Script", size: 64))
                    .foregroundColor(.black)
                    .padding(.bottom, 4)

                // First name
                TextField("First Name", text: $firstName,
                          prompt: Text("First Name").foregroundColor(Color(hex: 0x8C8C8C)))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .first)
                    .authBubble()

                // Last name
                TextField("Last Name", text: $lastName,
                          prompt: Text("Last Name").foregroundColor(Color(hex: 0x8C8C8C)))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .last)
                    .authBubble()

                // Phone
                TextField("Phone Number", text: $phone,
                          prompt: Text("Phone Number").foregroundColor(Color(hex: 0x8C8C8C)))
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .focused($focusedField, equals: .phone)
                    .authBubble()

                // Button — same height, radius, and width as bubbles
                Button {
                    hideKeyboard()
                    isLoading = true
                    let fullName = "\(firstName.trimmingCharacters(in: .whitespaces)) \(lastName.trimmingCharacters(in: .whitespaces))"
                    onSubmit?(fullName, phone)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isLoading = false }
                } label: {
                    ZStack {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text("SIGN UP").font(.system(size: 16, weight: .semibold)) }
                    }
                    .frame(maxWidth: .infinity, minHeight: AuthUI.bubbleHeight)
                }
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(AuthUI.bubbleRadius)
                .disabled(!isValid || isLoading)
                .opacity((isValid && !isLoading) ? 1 : 0.5)
                .animation(.easeInOut(duration: 0.12), value: isLoading)
                .animation(.easeInOut(duration: 0.12), value: isValid)

                // Sign-in link
                HStack(spacing: 4) {
                    Text("Already a user? Sign in")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    Button(action: { onTapSignIn?() }) {
                        Text("here.")
                            .underline()
                            .foregroundColor(.black)
                            .font(.system(size: 16))
                    }.buttonStyle(.plain)
                }
                .padding(.top, 4)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 40)
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

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}

#Preview {
    RegistrationView(
        onSubmit: { name, phone in print("Register:", name, phone) },
        onTapSignIn: { print("Go to login") }
    )
}
