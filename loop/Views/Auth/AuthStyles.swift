//
//  AuthStyles.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Comprehensive iOS-native styling system following Apple's HIG
//

import SwiftUI

// MARK: - Brand Theme
enum BrandColor {
    // Primary colors
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
    // Wordmark font (replace with your custom "loopy" font when available)
    static let wordmark = "Clicker Script"
    
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

// MARK: - Spacing & Layout (iOS Standard)
enum BrandSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let huge: CGFloat = 60
    
    // iOS Standard spacing
    static let iOSStandard: CGFloat = 16
    static let iOSCompact: CGFloat = 8
    static let iOSLarge: CGFloat = 24
}

// MARK: - UI Constants (iOS Standard)
enum BrandUI {
    // Button dimensions
    static let buttonHeight: CGFloat = 44
    static let buttonHeightLarge: CGFloat = 50
    static let buttonHeightCompact: CGFloat = 32
    
    // Input dimensions
    static let inputHeight: CGFloat = 52
    static let inputHeightCompact: CGFloat = 44
    
    // Corner radius (iOS standard)
    static let cornerRadius: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusExtraLarge: CGFloat = 26
    
    // Shadows and elevation
    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Float = 0.1
    static let shadowOffset = CGSize(width: 0, height: 2)
    
    // Animation durations
    static let animationFast: Double = 0.2
    static let animationMedium: Double = 0.3
    static let animationSlow: Double = 0.5
}

// MARK: - Validation Helpers
struct ValidationHelper {
    // Phone number validation
    static func isValidPhone(_ phone: String) -> Bool {
        let digits = phone.filter(\.isNumber)
        return digits.count == 10
    }
    
    // Format phone number for display
    static func formatPhone(_ phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        guard digits.count == 10 else { return phone }
        
        let areaCode = String(digits.prefix(3))
        let prefix = String(digits.dropFirst(3).prefix(3))
        let lineNumber = String(digits.dropFirst(6))
        
        return "(\(areaCode)) \(prefix)-\(lineNumber)"
    }
    
    // Code validation (4 digits only)
    static func isValidCode(_ code: [String]) -> Bool {
        return code.allSatisfy { $0.count == 1 && $0.first?.isNumber == true } &&
               code.joined().count == 4
    }
    
    // Clean phone input (remove non-digits)
    static func cleanPhoneInput(_ input: String) -> String {
        return input.filter(\.isNumber)
    }
}

// MARK: - iOS-Specific Components

// MARK: - Card Style
struct CardStyle: ViewModifier {
    let elevation: CGFloat
    let cornerRadius: CGFloat
    
    init(elevation: CGFloat = 2, cornerRadius: CGFloat = BrandUI.cornerRadiusMedium) {
        self.elevation = elevation
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(BrandColor.systemBackground)
            .cornerRadius(cornerRadius)
            .shadow(
                color: .black.opacity(Double(BrandUI.shadowOpacity)),
                radius: elevation * BrandUI.shadowRadius,
                x: BrandUI.shadowOffset.width,
                y: BrandUI.shadowOffset.height
            )
    }
}

// MARK: - List Row Style
struct ListRowStyle: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, BrandSpacing.md)
            .padding(.vertical, BrandSpacing.sm)
            .background(isSelected ? BrandColor.systemGray6 : BrandColor.systemBackground)
            .cornerRadius(BrandUI.cornerRadius)
    }
}

// MARK: - Navigation Bar Style
struct NavigationBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .toolbarBackground(BrandColor.systemBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Sheet Style
struct SheetStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(BrandUI.cornerRadiusLarge)
    }
}

// MARK: - Enhanced Button Styles

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
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

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandFont.headline)
            .foregroundColor(BrandColor.orange)
            .frame(maxWidth: .infinity, minHeight: BrandUI.buttonHeight)
            .background(BrandColor.systemBackground)
            .overlay(
                RoundedRectangle(cornerRadius: BrandUI.cornerRadiusExtraLarge)
                    .stroke(BrandColor.orange, lineWidth: 2)
            )
            .opacity(isEnabled ? 1.0 : 0.6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Enhanced Input Field Styles
struct AuthInputStyle: ViewModifier {
    let isValid: Bool
    let isFocused: Bool
    let hasError: Bool
    
    init(isValid: Bool = true, isFocused: Bool = false, hasError: Bool = false) {
        self.isValid = isValid
        self.isFocused = isFocused
        self.hasError = hasError
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, BrandSpacing.lg)
            .frame(maxWidth: .infinity, minHeight: BrandUI.inputHeight)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: BrandUI.cornerRadiusExtraLarge)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: BrandUI.animationFast), value: isFocused)
            .animation(.easeInOut(duration: BrandUI.animationFast), value: hasError)
    }
    
    private var borderColor: Color {
        if hasError { return BrandColor.error }
        if isFocused { return BrandColor.orange }
        return BrandColor.lightBrown
    }
    
    private var borderWidth: CGFloat {
        if isFocused || hasError { return 2 }
        return 1
    }
}

// MARK: - Error Message Style
struct ErrorMessageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(BrandFont.footnote)
            .foregroundColor(BrandColor.error)
            .padding(.top, BrandSpacing.xs)
            .multilineTextAlignment(.center)
            .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Success Message Style
struct SuccessMessageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(BrandFont.footnote)
            .foregroundColor(BrandColor.success)
            .padding(.top, BrandSpacing.xs)
            .multilineTextAlignment(.center)
            .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Loading Style
struct LoadingStyle: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0.6 : 1.0)
            .disabled(isLoading)
            .animation(.easeInOut(duration: BrandUI.animationFast), value: isLoading)
    }
}

// MARK: - Wordmark helper
struct LoopWordmark: View {
    var fontSize: CGFloat = 64
    var color: Color = BrandColor.orange
    
    var body: some View {
        // TODO: Replace with your custom "loopy" font when available
        Text("loop")
            .font(.custom(BrandFont.wordmark, size: fontSize))
            .foregroundColor(color)
    }
}

// MARK: - Convenience Extensions
extension View {
    // Input styling
    func authInput(isValid: Bool = true, isFocused: Bool = false, hasError: Bool = false) -> some View {
        modifier(AuthInputStyle(isValid: isValid, isFocused: isFocused, hasError: hasError))
    }
    
    // Error message styling
    func errorMessage() -> some View {
        modifier(ErrorMessageStyle())
    }
    
    // Success message styling
    func successMessage() -> some View {
        modifier(SuccessMessageStyle())
    }
    
    // Primary button styling
    func primaryButton(isEnabled: Bool = true, size: PrimaryButtonStyle.ButtonSize = .standard) -> some View {
        buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, size: size))
    }
    
    // Secondary button styling
    func secondaryButton(isEnabled: Bool = true) -> some View {
        buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled))
    }
    
    // Card styling
    func card(elevation: CGFloat = 2, cornerRadius: CGFloat = BrandUI.cornerRadiusMedium) -> some View {
        modifier(CardStyle(elevation: elevation, cornerRadius: cornerRadius))
    }
    
    // List row styling
    func listRow(isSelected: Bool = false) -> some View {
        modifier(ListRowStyle(isSelected: isSelected))
    }
    
    // Navigation bar styling
    func navigationBarStyle() -> some View {
        modifier(NavigationBarStyle())
    }
    
    // Sheet styling
    func sheetStyle() -> some View {
        modifier(SheetStyle())
    }
    
    // Loading styling
    func loading(_ isLoading: Bool) -> some View {
        modifier(LoadingStyle(isLoading: isLoading))
    }
}

// MARK: - Haptic Feedback
struct HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    static func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
}

// MARK: - Hex helper
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
