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
    
    private var maskedPhone: String {
        let digits = phone.filter(\.isNumber)
        let last4 = digits.suffix(4)
        return "*** - *** - \(String(last4))"
    }

    var body: some View {
        VStack(spacing: 30) {
            
            // Top bar with back button
            HStack {
                Button(action: {
                    onBack?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.top, 20)
            
            // Logo
            Text("loop")
                .font(.custom("Pacifico-Regular", size: 36))
            
            // Verification message
            VStack(spacing: 8) {
                Text("We’ve sent a verification code to:")
                    .font(.system(size: 18, weight: .medium))
                    .multilineTextAlignment(.center)
                
                Text(maskedPhone)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .padding(.top, 10)
            
            // Code entry
            HStack(spacing: 16) {
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
                                    .foregroundColor(.black)
                            }
                        )
                        .onChange(of: code[index]) { newValue in
                            if newValue.count > 1 {
                                code[index] = String(newValue.prefix(1))
                            }
                            if !newValue.isEmpty && index < 3 {
                                focusedIndex = index + 1
                            }
                        }
                }
            }
            .padding(.top, 20)
            
            // Retry link with countdown
            HStack(spacing: 4) {
                Text("Didn’t receive a code?")
                    .foregroundColor(.black)
                Button(action: {
                    if retryTime == 0 {
                        retryTime = 59
                        timerActive = true
                    }
                }) {
                    Text("Retry")
                        .foregroundColor(retryTime == 0 ? .blue : .gray)
                        .underline()
                }
                Text("in \(retryTime)s.")
                    .foregroundColor(.black)
            }
            .font(.system(size: 14))
            .padding(.top, 10)
            
            // Next button
            Button(action: {
                let enteredCode = code.joined()
                print("Entered code: \(enteredCode)")
                onNext?()
            }) {
                Text("Next")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            focusedIndex = 0
            startTimer()
        }
    }
    
    // Countdown timer logic
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
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
