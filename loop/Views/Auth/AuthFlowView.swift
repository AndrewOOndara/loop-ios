//
//  AuthFlowView.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Handles navigation between AuthView & RegistrationView.
//

import SwiftUI

enum AuthRoute: Hashable {
    case register
}

struct AuthFlowView: View {
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            AuthView(
                onSubmit: { phone in
                    print("Code sent to: \(phone)")
                    // TODO: Navigate to verify code view
                },
                onTapSignUp: {
                    print("Navigating to registration") // Debug print
                    path.append(.register)
                }
            )
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegistrationView(
                        onSubmit: { name, phone in
                            print("Register: \(name), \(phone)")
                            // TODO: Handle registration
                        },
                        onTapSignIn: {
                            print("Navigating back to sign in") // Debug print
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}
