//
//  AuthFlowView.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Handles navigation between AuthView & RegistrationView.
//

import SwiftUI

struct AuthFlowView: View {
    enum Screen { case signIn, signUp }
    @State private var screen: Screen = .signIn

    var body: some View {
        ZStack {
            switch screen {
            case .signIn:
                AuthView(
                    onSubmit: { phone in /* go to verify */ },
                    onTapSignUp: { withAnimation(.easeInOut) { screen = .signUp } }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .signUp:
                RegistrationView(
                    onSubmit: { fullName, phone in /* handle register */ },
                    onTapSignIn: { withAnimation(.easeInOut) { screen = .signIn } }
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
}

