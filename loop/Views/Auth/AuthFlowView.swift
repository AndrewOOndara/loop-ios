//
//  AuthFlowView.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Auth flow - login and verification
//

import SwiftUI

enum AuthRoute: Hashable {
    case verify(phone: String)
    case profileSetup
}

struct AuthFlowView: View {
    @State private var path: [AuthRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            AuthView(onSubmit: { phone in
                path.append(.verify(phone: phone))
            })
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .verify(let phone):
                    VerificationView(
                        phone: phone,
                        onSuccess: {
                            path.append(.profileSetup)
                        },
                        onBack: {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .profileSetup:
                    ProfileSetupView(
                        onComplete: {
                            // Handle successful profile setup - navigate to main app
                            print("Profile setup completed! Navigate to main app")
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}
