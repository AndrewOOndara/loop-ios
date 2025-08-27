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
            self.currentUser = nil
            self.isAuthenticated = false
            print("✅ User signed out successfully")
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
                self.currentUser = user
                self.isAuthenticated = true
                print("✅ Auth state changed - User signed in: \(user.phone ?? "Unknown")")
            } else {
                self.currentUser = nil
                self.isAuthenticated = false
                print("❌ Auth state changed - No session")
            }
        case .signedOut, .tokenRefreshed:
            self.currentUser = nil
            self.isAuthenticated = false
            print("🔒 Auth state changed - User signed out")
        case .passwordRecovery:
            // Handle other auth events if needed
            break
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
