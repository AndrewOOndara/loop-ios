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
            BrandColor.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 36)

                    // Wordmark
                    LoopWordmark(fontSize: 50, color: BrandColor.orange)

                    // Subtitle
                    Text("Setup your profile!")
                        .font(BrandFont.title3)
                        .foregroundColor(BrandColor.black)
                        .padding(.top, BrandSpacing.xs)

                    // Avatar + camera button
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(BrandColor.white)
                            .frame(width: avatarSize, height: avatarSize)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .overlay(
                                VStack(spacing: BrandSpacing.sm) {
                                    Circle()
                                        .stroke(BrandColor.orange, lineWidth: 10)
                                        .frame(width: 44, height: 44)
                                    ArcShape()
                                        .stroke(BrandColor.orange, lineWidth: 10)
                                        .frame(width: 90, height: 44)
                                }
                                .opacity(0.95)
                            )

                        Button {
                            // TODO: present image picker (camera/photo library)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(BrandColor.lightBrown)
                                    .frame(width: cameraSize, height: cameraSize)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(BrandColor.white)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Upload a photo")
                        .offset(x: 6, y: 6)
                    }
                    .padding(.top, BrandSpacing.xs)

                    Text("Upload a photo")
                        .font(BrandFont.caption1)
                        .foregroundColor(BrandColor.lightBrown)

                    // Fields with underlines
                    VStack(spacing: BrandSpacing.lg) {
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
                    .padding(.top, BrandSpacing.sm)

                    Spacer(minLength: BrandSpacing.lg)
                }
                .padding(.horizontal, BrandSpacing.xxl)
                .padding(.bottom, BrandSpacing.xxl)
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
                .foregroundColor(BrandColor.black)

            TextField(
                placeholder,
                text: $text,
                prompt: Text(placeholder).foregroundColor(BrandColor.lightBrown)
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .foregroundColor(BrandColor.black)

            Rectangle()
                .fill(isFocused ? BrandColor.orange : BrandColor.lightBrown)
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

// Color hex helper centralized in AuthStyles
