//
//  MainContentView.swift
//  loop
//
//  Created by Andrew Ondara on 8/26/25.
//

import SwiftUI

struct MainContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.isLoading {
                LoadingView()
            } else if authManager.isAuthenticated {
                HomeView(navigationPath: .constant([]))
            } else {
                AuthFlowView()
            }
        }
        .onAppear {
            authManager.startAuthStateListener()
        }
        .onOpenURL { url in
            Task {
                try await supabase.auth.session(from: url)
            }
        }
    }
}

#Preview {
    MainContentView()
} 
