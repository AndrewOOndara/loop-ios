//
//  AuthStyles.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Centralized UI styling for authentication views
//

import SwiftUI

// MARK: - UI Constants
enum AuthUI {
    static let bubbleHeight: CGFloat = 52
    static let bubbleRadius: CGFloat = 26
}

// MARK: - Bubble Style
struct AuthBubbleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: AuthUI.bubbleHeight)
            .background(
                RoundedRectangle(cornerRadius: AuthUI.bubbleRadius)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
}

// MARK: - Convenience Extension
extension View {
    func authBubble() -> some View {
        modifier(AuthBubbleStyle())
    }
}
