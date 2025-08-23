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
    case home
    case groupDetail(group: GroupModel)
    case notifications
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
                            // New user - proceed to profile setup
                            path.append(.profileSetup)
                        },
                        onExistingUser: {
                            // Existing user - skip profile setup and go to home
                            path.append(.home)
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
                            path.append(.home)
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .home:
                    HomeView(navigationPath: $path)
                        .navigationBarBackButtonHidden(true)
                case .groupDetail(let group):
                    GroupDetailView(group: group)
                        .navigationBarBackButtonHidden(true)
                case .notifications:
                    NotificationView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}
