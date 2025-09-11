//
//  VerificationView.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Simple OTP verification screen
//

import SwiftUI

struct VerificationView: View {
    let phone: String
    var onSuccess: (() -> Void)? = nil
    var onExistingUser: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    
    @State private var code: [String] = Array(repeating: "", count: 6)
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var countdown: Int = 15
    @State private var canResend: Bool = false
    @FocusState private var focusedField: Int?
    
    private var isValidCode: Bool {
        ValidationHelper.isValidCode(code)
    }
    
    var body: some View {
        ZStack {
            BrandColor.cream.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Wordmark at the very top
                LoopWordmark(fontSize: 64, color: BrandColor.orange)
                    .padding(.bottom, BrandSpacing.huge)
                    .padding(.bottom, BrandSpacing.md)
                
                // Main content centered
                VStack(spacing: BrandSpacing.lg) {
                
                // Instruction text
                VStack(spacing: BrandSpacing.sm) {
                    Text("Enter the code sent to:")
                        .font(BrandFont.headline)
                        .foregroundColor(BrandColor.black)
                    
                    Text(phone)
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.lightBrown)
                }
                .padding(.bottom, BrandSpacing.lg)
                
                // Code input fields
                HStack(spacing: BrandSpacing.sm) {
                    ForEach(0..<6, id: \.self) { index in
                        TextField("", text: $code[index])
                            .frame(width: 50, height: 50)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: index)
                            .foregroundColor(BrandColor.black)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandUI.cornerRadiusLarge)
                                    .stroke(focusedField == index ? BrandColor.orange : BrandColor.lightBrown, lineWidth: 2)
                            )
                            .onChange(of: code[index]) { oldValue, newValue in
                                // Only allow single digits
                                let filtered = newValue.filter(\.isNumber)
                                if filtered.count > 1 {
                                    code[index] = String(filtered.prefix(1))
                                } else {
                                    code[index] = filtered
                                }
                                
                                // Auto-advance focus
                                if !code[index].isEmpty && index < 5 {
                                    focusedField = index + 1
                                }
                                
                                // Clear error when user types
                                if errorMessage != nil {
                                    errorMessage = nil
                                }
                            }
                    }
                }
                .padding(.bottom, BrandSpacing.lg)
                
                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .errorMessage()
                }
                
                // Retry section
                HStack(spacing: 4) {
                    Text("Didn't receive a code?")
                        .foregroundColor(BrandColor.lightBrown)
                        .font(BrandFont.body)
                    
                    if canResend {
                        Button {
                            Task { await resendCode() }
                        } label: {
                            Text("Retry")
                                .foregroundColor(BrandColor.orange)
                                .font(BrandFont.body)
                                .underline()
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Retry in \(countdown)s")
                            .foregroundColor(BrandColor.lightBrown)
                            .font(BrandFont.body)
                    }
                }
                .padding(.bottom, BrandSpacing.lg)
                
                // Next button
                Button {
                    Task { await verifyCode() }
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("NEXT")
                                .font(BrandFont.headline)
                        }
                    }
                }
                .primaryButton(isEnabled: isValidCode && !isLoading)
                .disabled(!isValidCode || isLoading)
                }
                .padding(.horizontal, BrandSpacing.xxxl)
                
                Spacer()
            }
        }
        .onAppear {
            focusedField = 0
            startCountdown()
        }
        .onTapGesture {
            focusedField = nil
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    onBack?()
                }
                .foregroundColor(BrandColor.orange)
            }
        }
    }
    
    // MARK: - Actions
    private func startCountdown() {
        canResend = false
        countdown = 15
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                canResend = true
                timer.invalidate()
            }
        }
    }
    
    private func resendCode() async {
        do {
            // Send a new OTP code
            try await supabase.auth.signInWithOTP(phone: phone)
            
            // Clear any existing error and restart countdown
            errorMessage = nil
            startCountdown()
            
            // Clear the code fields for new entry
            code = Array(repeating: "", count: 6)
            focusedField = 0
            
            #if DEBUG
            print("New code sent to: \(phone)")
            #endif
        } catch {
            errorMessage = "Failed to send new code. Please try again."
            #if DEBUG
            print("Resend OTP error:", error.localizedDescription)
            #endif
        }
    }
    
    private func verifyCode() async {
        guard isValidCode, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let codeString = code.joined()
        
        do {
            // Verify OTP with Supabase
            #if DEBUG
            print("🔐 Attempting OTP verification for phone: \(phone)")
            print("🔐 Using code: \(codeString)")
            #endif
            try await supabase.auth.verifyOTP(phone: phone, token: codeString, type: .sms)
            
            #if DEBUG
            print("✅ OTP verification successful for phone: \(phone)")
            print("🔍 Checking if AuthManager needs manual update...")
            #endif
            
            // Manual check to ensure AuthManager is updated
            if let currentUser = supabase.auth.currentUser {
                print("🔄 Manual AuthManager update - User found: \(currentUser.phone ?? "Unknown")")
                await MainActor.run {
                    AuthManager.shared.currentUser = currentUser
                    AuthManager.shared.isAuthenticated = true
                    print("🔄 Manual update: AuthManager.isAuthenticated set to TRUE")
                }
            } else {
                print("⚠️ No current user found after successful OTP verification")
            }
            
            // Check if user already has a profile
            await checkExistingProfile()
            
        } catch {
            errorMessage = "Invalid code. Please try again."
            // Clear the code for retry
            code = Array(repeating: "", count: 6)
            focusedField = 0
            
            #if DEBUG
            print("OTP verification error:", error.localizedDescription)
            #endif
        }
    }
    
    private func checkExistingProfile() async {
        do {
            let existingProfile = try await ProfileService.shared.checkProfileExists(phoneNumber: phone)
            
            DispatchQueue.main.async {
                if existingProfile != nil {
                    // User already has a profile - auth state should handle navigation automatically
                    #if DEBUG
                    print("🏠 Existing user detected - waiting for auth state to trigger MainContentView transition")
                    print("🔍 Current auth state: \(supabase.auth.currentUser != nil ? "AUTHENTICATED" : "NOT_AUTHENTICATED")")
                    #endif
                    // Don't call onExistingUser - let auth state change handle the transition
                    // onExistingUser?()
                } else {
                    // New user - proceed to profile setup
                    #if DEBUG
                    print("👤 New user - proceeding to profile setup")
                    #endif
                    onSuccess?()
                }
            }
        } catch {
            #if DEBUG
            print("⚠️ Error checking profile existence: \(error)")
            print("🔄 Falling back to profile setup flow")
            #endif
            
            // If there's an error checking the profile, proceed to profile setup as fallback
            DispatchQueue.main.async {
                onSuccess?()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VerificationView(
        phone: "+1234567890",
        onSuccess: { print("New user - proceed to profile setup") },
        onExistingUser: { print("Existing user - go to home") },
        onBack: { print("Back tapped") }
    )
}
