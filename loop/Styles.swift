//
//  Styles.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Global styling system for the entire app
//  Contains brand colors, typography, spacing, and reusable UI components
//

import SwiftUI
import UIKit

// MARK: - Brand Theme
enum BrandColor {
    // Primary brand colors
    static let white         = Color(hex: 0xFFFFFF)
    static let orange        = Color(hex: 0xE27814)
    static let black         = Color(hex: 0x000000)
    static let cream         = Color(hex: 0xFEF2E4)
    static let lightBrown    = Color(hex: 0xAF916E)
    
    // Semantic colors
    static let error         = Color.red
    static let success       = Color.green
    static let warning       = Color.orange
    
    // iOS System Colors (adapts to light/dark mode)
    static let systemBackground = Color(.systemBackground)
    static let systemGroupedBackground = Color(.systemGroupedBackground)
    static let secondarySystemBackground = Color(.secondarySystemBackground)
    static let tertiarySystemBackground = Color(.tertiarySystemBackground)
    static let systemGray = Color(.systemGray)
    static let systemGray2 = Color(.systemGray2)
    static let systemGray3 = Color(.systemGray3)
    static let systemGray4 = Color(.systemGray4)
    static let systemGray5 = Color(.systemGray5)
    static let systemGray6 = Color(.systemGray6)
}

// MARK: - Typography with Dynamic Type Support
enum BrandFont {
    // Custom wordmark font - Sacramento
    static let wordmark = "Sacramento"
    static let wordmarkFallback = "Clicker Script"
    
    // System fonts with Dynamic Type support
    static let largeTitle = Font.largeTitle
    static let title1 = Font.title
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption1 = Font.caption
    static let caption2 = Font.caption2
    
    // Custom sizes for specific use cases
    static let customLarge = Font.system(size: 64, weight: .regular, design: .default)
    static let customMedium = Font.system(size: 36, weight: .regular, design: .default)
}

// MARK: - Spacing System
enum BrandSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
    static let huge: CGFloat = 96
    
    // iOS Standard spacing values
    static let iOSStandard: CGFloat = 16
    static let iOSCompact: CGFloat = 8
    static let iOSLarge: CGFloat = 20
}

// MARK: - UI Constants
enum BrandUI {
    // Button dimensions
    static let buttonHeight: CGFloat = 50
    static let buttonHeightCompact: CGFloat = 40
    static let buttonHeightLarge: CGFloat = 60
    
    // Input field dimensions
    static let inputHeight: CGFloat = 56
    static let inputHeightCompact: CGFloat = 44
    
    // Corner radius values
    static let cornerRadiusSmall: CGFloat = 4
    static let cornerRadius: CGFloat = 8
    static let cornerRadiusLarge: CGFloat = 12
    static let cornerRadiusExtraLarge: CGFloat = 25
    
    // Shadow values
    static let shadowRadius: CGFloat = 4
    static let shadowOpacity: CGFloat = 0.1
    static let shadowOffset = CGSize(width: 0, height: 2)
    
    // Animation durations
    static let animationFast: CGFloat = 0.2
    static let animationMedium: CGFloat = 0.3
    static let animationSlow: CGFloat = 0.5
}

// MARK: - Validation Helpers
struct ValidationHelper {
    static func isValidPhone(_ phone: String) -> Bool {
        let digits = phone.filter(\.isNumber)
        return digits.count == 10
    }
    
    static func formatPhone(_ phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        guard digits.count == 10 else { return phone }
        
        let areaCode = String(digits.prefix(3))
        let middle = String(digits.dropFirst(3).prefix(3))
        let last = String(digits.suffix(4))
        
        return "(\(areaCode)) \(middle)-\(last)"
    }
    
    static func isValidCode(_ code: [String]) -> Bool {
        return code.allSatisfy { $0.count == 1 && $0.first?.isNumber == true } &&
               code.joined().count == 6
    }
    
    static func cleanPhoneInput(_ input: String) -> String {
        return input.filter(\.isNumber)
    }
}

// MARK: - Button Styles
enum ButtonSize {
    case compact, standard, large
    
    var height: CGFloat {
        switch self {
        case .compact: return BrandUI.buttonHeightCompact
        case .standard: return BrandUI.buttonHeight
        case .large: return BrandUI.buttonHeightLarge
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    init(isEnabled: Bool = true, size: ButtonSize = .standard) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandFont.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: size.height)
            .background(isEnabled ? BrandColor.orange : BrandColor.systemGray3)
            .cornerRadius(BrandUI.cornerRadiusExtraLarge)
            .opacity(isEnabled ? 1.0 : 0.6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    init(isEnabled: Bool = true, size: ButtonSize = .standard) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandFont.headline)
            .foregroundColor(isEnabled ? BrandColor.orange : BrandColor.systemGray3)
            .frame(maxWidth: .infinity, minHeight: size.height)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: BrandUI.cornerRadiusExtraLarge)
                    .stroke(isEnabled ? BrandColor.orange : BrandColor.systemGray3, lineWidth: 2)
            )
            .opacity(isEnabled ? 1.0 : 0.6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - View Modifiers
struct ErrorMessageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(BrandFont.caption1)
            .foregroundColor(BrandColor.error)
            .padding(.horizontal, BrandSpacing.sm)
    }
}

struct SuccessMessageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(BrandFont.caption1)
            .foregroundColor(BrandColor.success)
            .padding(.horizontal, BrandSpacing.sm)
    }
}

struct LoadingStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .opacity(0.6)
            .disabled(true)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(BrandColor.systemBackground)
            .cornerRadius(BrandUI.cornerRadiusLarge)
            .shadow(
                color: .black.opacity(BrandUI.shadowOpacity),
                radius: BrandUI.shadowRadius,
                x: BrandUI.shadowOffset.width,
                y: BrandUI.shadowOffset.height
            )
    }
}

struct ListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, BrandSpacing.sm)
            .padding(.horizontal, BrandSpacing.md)
            .background(BrandColor.systemBackground)
    }
}

struct NavigationBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(BrandColor.systemBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct SheetStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
    }
}

// MARK: - Haptic Feedback Manager
struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Wordmark Component
struct LoopWordmark: View {
    var fontSize: CGFloat = 64
    var color: Color = BrandColor.orange
    
    var body: some View {
        Text("loop")
            .font(.custom(BrandFont.wordmark, size: fontSize))
            .foregroundColor(color)
            .onAppear {
                // Debug: Print available fonts to help verify Sacramento is loaded
                #if DEBUG
                print("=== SACRAMENTO FONT DEBUG ===")
                for familyName in UIFont.familyNames {
                    if familyName.lowercased().contains("sacramento") {
                        print("✅ Found Sacramento family: \(familyName)")
                        let fontNames = UIFont.fontNames(forFamilyName: familyName)
                        for fontName in fontNames {
                            print("  - Font: \(fontName)")
                        }
                    }
                }
                print("=== END FONT DEBUG ===")
                #endif
            }
    }
}



// MARK: - Authentication-Specific Components

/// Enhanced input field style specifically designed for authentication forms
/// Handles validation states, focus states, and error display
struct AuthInputStyle: ViewModifier {
    let isValid: Bool
    let isFocused: Bool
    let hasError: Bool
    
    init(isValid: Bool = true, isFocused: Bool = false, hasError: Bool = false) {
        self.isValid = isValid
        self.isFocused = isFocused
        self.hasError = hasError
    }
    
    private var borderColor: Color {
        if hasError {
            return BrandColor.error
        } else if isFocused {
            return BrandColor.orange
        } else if !isValid {
            return BrandColor.error.opacity(0.5)
        } else {
            return BrandColor.lightBrown
        }
    }
    
    private var borderWidth: CGFloat {
        (isFocused || hasError) ? 2 : 1
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, BrandSpacing.lg)
            .frame(maxWidth: .infinity, minHeight: BrandUI.inputHeight)
            .background(Color.clear) // Transparent background for clean look
            .overlay(
                RoundedRectangle(cornerRadius: BrandUI.cornerRadiusExtraLarge)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: BrandUI.animationFast), value: isFocused)
            .animation(.easeInOut(duration: BrandUI.animationFast), value: hasError)
    }
}

/// Constants specific to the authentication flow
enum AuthConstants {
    // OTP/Verification specific
    static let otpDigitCount = 6
    static let otpResendDelay = 15 // seconds
    
    // Phone validation
    static let phoneDigitCount = 10
    
    // Profile setup
    static let bioCharacterLimit = 100
    static let profileImageSize: CGFloat = 120
    static let profileImageCornerRadius: CGFloat = 60 // circular
    
    // Navigation
    static let authFlowAnimationDuration: CGFloat = 0.3
}

// MARK: - Extensions
extension View {
    // Auth-specific extensions
    func authInput(isValid: Bool = true, isFocused: Bool = false, hasError: Bool = false) -> some View {
        self.modifier(AuthInputStyle(isValid: isValid, isFocused: isFocused, hasError: hasError))
    }
    
    // Button style extensions
    func primaryButton(isEnabled: Bool = true, size: ButtonSize = .standard) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, size: size))
    }
    
    func secondaryButton(isEnabled: Bool = true, size: ButtonSize = .standard) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled, size: size))
    }
    
    // Message style extensions
    func errorMessage() -> some View {
        self.modifier(ErrorMessageStyle())
    }
    
    func successMessage() -> some View {
        self.modifier(SuccessMessageStyle())
    }
    
    func loading() -> some View {
        self.modifier(LoadingStyle())
    }
    
    // Layout style extensions
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
    
    func listRowStyle() -> some View {
        self.modifier(ListRowStyle())
    }
    
    func navigationBarStyle() -> some View {
        self.modifier(NavigationBarStyle())
    }
    
    func sheetStyle() -> some View {
        self.modifier(SheetStyle())
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
