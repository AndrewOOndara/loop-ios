//
//  AuthManager.swift
//  loop
//
//  Created by Andrew Ondara on 8/26/25.
//

import Foundation
import Supabase
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = true
    
    private init() {
        Task {
            await checkAuthenticationState()
        }
    }
    
    /// Check the current authentication state
    func checkAuthenticationState() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.session
            let user = session.user
            self.currentUser = user
            self.isAuthenticated = true
            print("✅ User authenticated: \(user.phone ?? "Unknown")")
        } catch {
            print("🚨 Error checking authentication state: \(error)")
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    /// Sign out the current user
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                print("✅ User signed out successfully - isAuthenticated set to FALSE")
                print("🔍 This should trigger MainContentView to show AuthFlowView")
            }
        } catch {
            print("🚨 Error signing out: \(error)")
        }
    }
    
    /// Listen to authentication state changes
    func startAuthStateListener() {
        Task {
            for await (event, session) in supabase.auth.authStateChanges {
                await handleAuthStateChange(event, session: session)
            }
        }
    }
    
    private func handleAuthStateChange(_ event: AuthChangeEvent, session: Session?) async {
        switch event {
        case .initialSession, .signedIn:
            if let session = session {
                let user = session.user
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                    print("🔄 MainActor: AuthManager.isAuthenticated set to TRUE")
                    print("🔄 MainActor: This should trigger MainContentView UI update")
                }
                print("✅ Auth state changed - User signed in: \(user.phone ?? "Unknown")")
                print("🔍 AuthManager.isAuthenticated set to: true")
            } else {
                await MainActor.run {
                    self.currentUser = nil
                    self.isAuthenticated = false
                    print("🔄 MainActor: AuthManager.isAuthenticated set to FALSE")
                }
                print("❌ Auth state changed - No session")
                print("🔍 AuthManager.isAuthenticated set to: false")
            }
        case .signedOut:
            self.currentUser = nil
            self.isAuthenticated = false
            print("🔒 Auth state changed - User signed out")
        case .tokenRefreshed:
            if let session = session {
                let user = session.user
                self.currentUser = user
                self.isAuthenticated = true
                print("🔄 Auth state changed - Token refreshed for: \(user.phone ?? "Unknown")")
            } else {
                print("⚠️ Token refresh but no session provided")
            }
        case .passwordRecovery:
            print("🔑 Password recovery event")
            break
        case .userUpdated:
            if let session = session {
                let user = session.user
                self.currentUser = user
                print("👤 User updated: \(user.phone ?? "Unknown")")
            } else {
                print("⚠️ User update but no session provided")
            }
        @unknown default:
            print("⚠️ Unknown auth state change: \(event)")
        }
    }
    
    /// Get the current user's profile
    func getCurrentUserProfile() async -> Profile? {
        guard let currentUser = currentUser else { return nil }
        
        do {
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            return profile
        } catch {
            print("🚨 Error fetching user profile: \(error)")
            return nil
        }
    }
}
