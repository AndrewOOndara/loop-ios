import SwiftUI

struct ProfileSetupView: View {
    // Step tracking: 0 = Name, 1 = Username & Bio, 2 = Avatar
    @State private var step: Int = 0
    
    // Form state
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    
    // Focus state
    @FocusState private var focusedField: Field?
    private enum Field { case firstName, lastName, username, bio }
    
    // Avatar sizes
    private let avatarSize: CGFloat = 148
    private let cameraSize: CGFloat = 42
    
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack {
                LoopWordmark(fontSize: 50, color: BrandColor.orange)
                    .padding(.top, 36)
                
                Spacer(minLength: 20)
                
                // Step content
                Group {
                    switch step {
                    case 0: nameStep
                    case 1: usernameBioStep
                    case 2: avatarStep
                    default: EmptyView()
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if step > 0 {
                        Button("Back") { step -= 1 }
                            .foregroundColor(BrandColor.lightBrown)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button(step == 2 ? "Finish" : "Next") {
                        if step < 2 { step += 1 }
                        else { submitProfile() }
                    }
                    .disabled(!isStepValid)
                    .foregroundColor(.white)
                    .frame(width: 120, height: BrandUI.buttonHeight)
                    .background(isStepValid ? BrandColor.orange : BrandColor.lightBrown)
                    .cornerRadius(BrandUI.cornerRadiusExtraLarge)
                    .padding(.horizontal)
                }
                .padding(.bottom, BrandSpacing.xxl)
            }
            .padding(.horizontal, BrandSpacing.xxl)
        }
    }
    
    // MARK: - Steps
    
    private var nameStep: some View {
        VStack(spacing: BrandSpacing.lg) {
            UnderlinedField(title: "First Name (required)",
                            placeholder: "Enter your first name",
                            text: $firstName,
                            isFocused: focusedField == .firstName)
            .focused($focusedField, equals: .firstName)
            .onAppear { focusedField = .firstName }
            
            UnderlinedField(title: "Last Name (required)",
                            placeholder: "Enter your last name",
                            text: $lastName,
                            isFocused: focusedField == .lastName)
            .focused($focusedField, equals: .lastName)
            .onAppear { focusedField = .lastName }
        }
    }
    
    private var usernameBioStep: some View {
        VStack(spacing: BrandSpacing.lg) {
            UnderlinedField(title: "@username",
                            placeholder: "Enter your username",
                            text: $username,
                            isFocused: focusedField == .username)
            .focused($focusedField, equals: .username)
            .onAppear { focusedField = .username }
            
            UnderlinedField(title: "Bio (optional)",
                            placeholder: "Add a short bio",
                            text: $bio,
                            isFocused: focusedField == .bio)
            .focused($focusedField, equals: .bio)
            .onAppear { focusedField = .bio }
        }
    }
    
    private var avatarStep: some View {
        VStack(spacing: BrandSpacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(BrandColor.white)
                    .frame(width: avatarSize, height: avatarSize)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                Button {
                    
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
            }
            
            Text("Upload a photo")
                .font(BrandFont.caption1)
                .foregroundColor(BrandColor.lightBrown)
        }
    }
    
    // MARK: - Helpers
    
    private var isStepValid: Bool {
        switch step {
        case 0: return !firstName.isEmpty && !lastName.isEmpty
        case 1: return !username.isEmpty
        default: return true
        }
    }
    
    private func submitProfile() {
        // Save profile data to Supabase here
        print("Profile submitted:", firstName, lastName, username, bio)
    }
}

// MARK: - Underlined Field (kept from your styling)
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
