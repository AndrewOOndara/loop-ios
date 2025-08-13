//
//  ProfileSetupView.swift
//  loop
//
//  Created by Sarah Luan on 8/13/25.
//
//  Post-registration profile setup
//

import SwiftUI

struct ProfileSetupView: View {
    // Form state
    @State private var fullName: String = ""
    @State private var bio: String = ""

    // Focused field controls keyboard
    @FocusState private var focused: Field?
    private enum Field { case name, bio }

    // Sizing
    private let avatarSize: CGFloat = 148
    private let cameraSize: CGFloat = 42

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 36)

                    // Wordmark
                    Text("loop")
                        .font(.custom("Clicker Script", size: 50))
                        .foregroundColor(.black)

                    // Subtitle
                    Text("Setup your profile!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: 0x141414))
                        .padding(.top, 6)

                    // Avatar + camera button
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: avatarSize, height: avatarSize)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .overlay(
                                VStack(spacing: 10) {
                                    Circle()
                                        .stroke(Color.black, lineWidth: 10)
                                        .frame(width: 44, height: 44)
                                    ArcShape()
                                        .stroke(Color.black, lineWidth: 10)
                                        .frame(width: 90, height: 44)
                                }
                                .opacity(0.95)
                            )

                        Button {
                            // TODO: present image picker (camera/photo library)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: 0xE0E0E0))
                                    .frame(width: cameraSize, height: cameraSize)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Upload a photo")
                        .offset(x: 6, y: 6)
                    }
                    .padding(.top, 6)

                    Text("Upload a photo")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: 0xAAAAAA))

                    // Fields with underlines
                    VStack(spacing: 18) {
                        UnderlinedField(
                            title: "Full Name (required)",
                            placeholder: "Enter your full name",
                            text: $fullName,
                            isFocused: focused == .name
                        )
                        .focused($focused, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focused = .bio }

                        UnderlinedField(
                            title: "Bio (optional)",
                            placeholder: "Add a short bio",
                            text: $bio,
                            isFocused: focused == .bio
                        )
                        .focused($focused, equals: .bio)
                        .submitLabel(.done)
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        // Tap outside to dismiss by clearing focus
        .simultaneousGesture(TapGesture().onEnded { focused = nil })
        .onAppear { focused = .name }
    }
}

#Preview {
    ProfileSetupView()
}

// MARK: - Underlined field

private struct UnderlinedField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.black)

            TextField(
                placeholder,
                text: $text,
                prompt: Text(placeholder).foregroundColor(Color(hex: 0xAAAAAA))
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .foregroundColor(.black)

            Rectangle()
                .fill(isFocused ? Color.black : Color(hex: 0xAAAAAA))
                .frame(height: 1)
        }
    }
}

// Simple arc for the avatar chest
private struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY),
            radius: rect.width / 2,
            startAngle: .degrees(200),
            endAngle: .degrees(-20),
            clockwise: true
        )
        return p
    }
}

// Hex color helper (if you don't already have one shared)
private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF)/255.0,
                  green: Double((hex >> 8) & 0xFF)/255.0,
                  blue: Double(hex & 0xFF)/255.0,
                  opacity: alpha)
    }
}
