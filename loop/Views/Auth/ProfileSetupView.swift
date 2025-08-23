//
//  ProfileSetupView.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Profile setup screen for new users
//

import SwiftUI
import PhotosUI
import Storage

struct ProfileSetupView: View {
    var onComplete: (() -> Void)?
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, username
    }
    
    private var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
                ZStack {
            BrandColor.cream.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Wordmark at the very top
                    LoopWordmark(fontSize: 64, color: BrandColor.orange)
                        .padding(.bottom, BrandSpacing.md)
                    
                    // Main content centered
                    VStack(spacing: BrandSpacing.lg) {
                        // Title
                        Text("Set up your profile!")
                            .font(BrandFont.headline)
                            .foregroundColor(BrandColor.black)
                            .padding(.bottom, BrandSpacing.md)
                    
                    // Profile Picture Section
                    VStack(spacing: BrandSpacing.sm) {
                        ZStack {
                            // Profile image or placeholder
                            if let profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                                        } else {
                                Circle()
                                    .fill(BrandColor.white)
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(BrandColor.lightBrown)
                                    )
                            }
                            
                            // Camera button
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(BrandColor.orange)
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                            }
                            .offset(x: 40, y: 40)
                        }
                        
                        Text("Add a profile picture")
                            .font(BrandFont.caption1)
                            .foregroundColor(BrandColor.lightBrown)
                    }
                    .padding(.bottom, BrandSpacing.lg)
                    
                    // Form Fields
                    VStack(spacing: BrandSpacing.md) {
                        // First Name
                        UnderlinedField(
                            title: "First Name",
                            text: $firstName,
                            isRequired: true
                        )
                        .focused($focusedField, equals: .firstName)
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                        
                        // Last Name
                        UnderlinedField(
                            title: "Last Name", 
                            text: $lastName,
                            isRequired: true
                        )
                        .focused($focusedField, equals: .lastName)
                        .textContentType(.familyName)
                        .autocapitalization(.words)
                        
                        // Username
                        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                            HStack {
                                Text("Username")
                                    .font(BrandFont.caption1)
                                    .foregroundColor(BrandColor.lightBrown)
                                
                                Text("*")
                                    .font(BrandFont.caption1)
                                    .foregroundColor(BrandColor.orange)
                                
                                Spacer()
                                
                                Text("\(username.count)/20")
                                    .font(BrandFont.caption2)
                                    .foregroundColor(username.count > 20 ? BrandColor.error : BrandColor.lightBrown)
                            }
                            
                            TextField("", text: $username)
                                .focused($focusedField, equals: .username)
                                .foregroundColor(BrandColor.black)
                                .font(BrandFont.body)
                                .padding(.vertical, BrandSpacing.sm)
                                .onChange(of: username) { oldValue, newValue in
                                    if newValue.count > 20 {
                                        username = String(newValue.prefix(20))
                                    }
                                }
                            
                            Rectangle()
                                .fill(focusedField == .username ? BrandColor.orange : BrandColor.lightBrown)
                                .frame(height: 1)
                                .animation(.easeInOut(duration: 0.2), value: focusedField == .username)
                        }
                    }
                    .padding(.bottom, BrandSpacing.xl)
                    
                    // Error message
                    if let errorMessage {
                        Text(errorMessage)
                            .errorMessage()
                    }
                    
                    // Complete button
                    Button {
                        Task { await completeSetup() }
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("COMPLETE SETUP")
                                    .font(BrandFont.headline)
                            }
                        }
                    }
                    .primaryButton(isEnabled: isValid && !isLoading)
                    .disabled(!isValid || isLoading)
                    }
                    .padding(.horizontal, BrandSpacing.xxxl)
                }
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        profileImage = uiImage
                    }
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    
    
    // MARK: - Actions
    private func completeSetup() async {
        guard isValid, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let user = try await supabase.auth.session.user
            
            // Handle profile image upload first if selected
            var avatarURL: String? = nil
            
            // Upload profile image if selected
            if let profileImage = profileImage,
               let imageData = profileImage.jpegData(compressionQuality: 0.8) {
                let fileName = "\(user.id)_profile_\(UUID().uuidString).jpg"
                
                // Upload to Supabase storage
                let _ = try await supabase.storage
                    .from("avatars")
                    .upload(
                        fileName,
                        data: imageData,
                        options: FileOptions(contentType: "image/jpeg")
                    )
                
                // Get public URL
                let publicURL = try supabase.storage
                    .from("avatars")
                    .getPublicURL(path: fileName)
                
                avatarURL = publicURL.absoluteString
            }
            
            // Create the profile using ProfileService
            let _ = try await ProfileService.shared.createProfile(
                userID: user.id,
                phoneNumber: user.phone ?? "",
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                profileBio: nil,
                avatarURL: avatarURL
            )
            
            // Call completion handler
            onComplete?()
            
        } catch {
            errorMessage = "Failed to set up profile. Please try again."
            print("Profile setup error:", error.localizedDescription)
        }
    }
}

// MARK: - ProfileUpdateData Struct
struct ProfileUpdateData: Codable {
    let id: String
    let first_name: String
    let last_name: String
    let username: String
    let updated_at: String
    var avatar_url: String?
}

// MARK: - UnderlinedField Component
struct UnderlinedField: View {
    let title: String
    @Binding var text: String
    let isRequired: Bool
    
    @FocusState private var isFocused: Bool
    
    init(title: String, text: Binding<String>, isRequired: Bool = false) {
        self.title = title
        self._text = text
        self.isRequired = isRequired
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
            HStack {
            Text(title)
                    .font(BrandFont.caption1)
                    .foregroundColor(BrandColor.lightBrown)
                
                if isRequired {
                    Text("*")
                        .font(BrandFont.caption1)
                        .foregroundColor(BrandColor.orange)
                }
            }
            
            TextField("", text: $text)
                .focused($isFocused)
                .foregroundColor(BrandColor.black)
                .font(BrandFont.body)
                .padding(.vertical, BrandSpacing.sm)

            Rectangle()
                .fill(isFocused ? BrandColor.orange : BrandColor.lightBrown)
                .frame(height: 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileSetupView(
        onComplete: { print("Profile setup completed") }
    )
}
