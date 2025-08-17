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
    case verify(phone: String)
    case groupCode
    case profileSetup
}

struct AuthFlowView: View {
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            AuthView(
                onSubmit: { phone in
                    print("Code sent to: \(phone)")
                    path.append(.verify(phone: phone))
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
                            path.append(.verify(phone: phone))
                        },
                        onTapSignIn: {
                            print("Navigating back to sign in") // Debug print
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .verify(let phone):
                    VerificationView(
                        phone: phone,
                        onNext: {
                            path.append(.profileSetup)
                        },
                        onBack: {
                            if !path.isEmpty { path.removeLast() }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .groupCode:
                    GroupRegistrationView(
                        onNext: {
                            path.append(.profileSetup)
                        },
                        onBack: {
                            if !path.isEmpty { path.removeLast() }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .profileSetup:
                    ProfileSetupView()
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

//onNext: {
//    Task {
//        do {
//            guard let userId = supabase.auth.currentUser?.id else {
//                print("No authenticated user found.")
//                return
//            }
//            // Check the current user's profile
//            let profile: [Profile] = try await supabase.from("profiles")
//                .select()
//                .eq("id", value: userId) // Filter by the user's ID
//                .limit(1) // Limit to one result as we expect at most one profile per user
//                .execute()
//                .value
//            
//            if !profile.isEmpty {
//                print("Go to Home")
//            } else {
//                print("Go to Registration")
//                path.append(.register)
//            }
//        } catch {
//            print("Error checking username:", error.localizedDescription)
//            // Fallback → go to RegistrationView
//            path.append(.register)
//        }
//    }
//},
//onBack: {
//    if !path.isEmpty { path.removeLast() }
//}
//)
//.navigationBarBackButtonHidden(true)
