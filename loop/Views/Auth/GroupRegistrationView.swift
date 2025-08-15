//
//  GroupRegistrationView.swift
//  loop
//
//  Created by Andrew Ondara on 8/12/25.
//

import SwiftUI

struct GroupRegistrationView: View {
    var onNext: (() -> Void)?
    var onBack: (() -> Void)?

    @State private var code: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedIndex: Int?
    
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Top bar with optional back button
                HStack {
                    if onBack != nil {
                        Button(action: { onBack?() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(BrandColor.black)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 20)
                
                // Logo at the top
                LoopWordmark(fontSize: 36, color: BrandColor.orange)
                    .padding(.top, 60)
                
                // Instruction text
                Text("Please enter your\n4-digit group invite code here:")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(BrandColor.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Code entry fields
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
            .padding()
            .onAppear {
                focusedIndex = 0
            }
        }
    }
}

#Preview {
    GroupRegistrationView(onNext: {}, onBack: {})
}
