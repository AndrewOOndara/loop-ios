//
//  VerificationView.swift
//  loop
//
//  Created by Andrew Ondara on 8/12/25.
//

import SwiftUI

struct VerificationView: View {
    // Inputs
    let phone: String
    var onNext: (() -> Void)?
    var onBack: (() -> Void)?

    // Local state
    @State private var code: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedIndex: Int?
    @State private var retryTime = 59
    @State private var timerActive = true
    @State private var countdownTimer: Timer?
    
    private var maskedPhone: String {
        let digits = phone.filter(\.isNumber)
        let last4 = digits.suffix(4)
        return "*** - *** - \(String(last4))"
    }

    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // Top bar with back button
                HStack {
                    Button(action: {
                        onBack?()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(BrandColor.black)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                
                // Logo
                LoopWordmark(fontSize: 36, color: BrandColor.orange)
                
                // Verification message
                VStack(spacing: 8) {
                    Text("We've sent a verification code to:")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(BrandColor.black)
                        .multilineTextAlignment(.center)
                    
                    Text(maskedPhone)
                        .font(.system(size: 16))
                        .foregroundColor(BrandColor.black)
                }
                .padding(.top, 10)
                
                // Code entry
                HStack(spacing: BrandSpacing.md) {
                    ForEach(0..<4, id: \.self) { index in
                        TextField("", text: $code[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .focused($focusedIndex, equals: index)
                            .frame(width: 40, height: 44)
                            .background(
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(BrandColor.black)
                                }
                            )
                            .onChange(of: code[index]) { oldValue, newValue in
                                // Only allow single digits
                                let cleaned = newValue.filter(\.isNumber)
                                if cleaned.count > 1 {
                                    code[index] = String(cleaned.prefix(1))
                                } else {
                                    code[index] = cleaned
                                }
                                
                                // Auto-advance to next field
                                if !cleaned.isEmpty && index < 3 {
                                    focusedIndex = index + 1
                                }
                            }
                    }
                }
                .padding(.top, BrandSpacing.lg)
                
                // Retry link with countdown
                HStack(spacing: BrandSpacing.xs) {
                    Text("Didn't receive a code?")
                        .foregroundColor(BrandColor.lightBrown)
                        .font(BrandFont.caption1)
                    Button(action: {
                        retryTime = 59
                        startTimer()
                    }) {
                        Text("Retry")
                            .foregroundColor(retryTime == 0 ? BrandColor.orange : BrandColor.lightBrown)
                            .underline()
                            .font(BrandFont.caption1)
                    }
                    Text("in \(retryTime)s.")
                        .foregroundColor(BrandColor.lightBrown)
                        .font(BrandFont.caption1)
                }
                .padding(.top, BrandSpacing.sm)
                
                // Next button
                Button(action: {
                    let enteredCode = code.joined()
                    print("Entered code: \(enteredCode)")
                    onNext?()
                }) {
                    Text("Next")
                        .font(BrandFont.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: BrandUI.buttonHeight)
                        .background(ValidationHelper.isValidCode(code) ? BrandColor.orange : BrandColor.lightBrown)
                        .cornerRadius(BrandUI.cornerRadiusExtraLarge)
                }
                .disabled(!ValidationHelper.isValidCode(code))
                .opacity(ValidationHelper.isValidCode(code) ? 1.0 : 0.6)
                .padding(.top, BrandSpacing.lg)
                
                Spacer()
            }
            .padding(.horizontal)
            .onAppear {
                focusedIndex = 0
                startTimer()
            }
        }
    }
    
    // Countdown timer logic
    private func startTimer() {
        countdownTimer?.invalidate()
        timerActive = true
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if retryTime > 0 && timerActive {
                retryTime -= 1
            } else {
                timer.invalidate()
                timerActive = false
            }
        }
    }
}

#Preview {
    VerificationView(phone: "+1 (555) 867-5309", onNext: {}, onBack: {})
}
