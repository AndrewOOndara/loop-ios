//
//  GroupRegistrationView.swift
//  loop
//
//  Created by Andrew Ondara on 8/12/25.
//

import SwiftUI

struct GroupRegistrationView: View {
    @State private var code: [String] = Array(repeating: "", count: 4)
    @FocusState private var focusedIndex: Int?
    
    var body: some View {
        VStack(spacing: 40) {
            
            // Logo at the top
            Text("loop")
                .font(.custom("Pacifico-Regular", size: 36)) // Replace with logo font or image
                .padding(.top, 60)
            
            // Instruction text
            Text("Please enter your\n4-digit group invite code here:")
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Code entry fields
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
            
            // Next button
            Button(action: {
                let enteredCode = code.joined()
                print("Entered code: \(enteredCode)")
                // Handle navigation or verification logic here
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
        .padding()
        .onAppear {
            focusedIndex = 0
        }
    }
}

#Preview {
    GroupRegistrationView()
}
