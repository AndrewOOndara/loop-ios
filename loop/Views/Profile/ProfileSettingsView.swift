import PhotosUI
import Storage
import Supabase
import SwiftUI

struct ProfileSettingsView: View {
    @Binding var username: String
    @Binding var bio: String
    @Binding var avatarImage: AvatarImage?
    @Binding var imageSelection: PhotosPickerItem?
    
    @State private var localName = ""
    @State private var localBio = ""
    @State private var isLoading = false
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BrandSpacing.xl) {
                    // Header
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("Settings")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Save") {
                            saveProfile()
                        }
                        .foregroundColor(BrandColor.orange)
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.sm)
                    
                    // Profile Image Section
                    VStack(spacing: BrandSpacing.md) {
                        PhotosPicker(selection: $imageSelection, matching: .images) {
                            ZStack {
                                Circle()
                                    .fill(BrandColor.systemGray6)
                                    .frame(width: 120, height: 120)
                                
                                if let avatarImage {
                                    avatarImage.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 116, height: 116)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(BrandColor.lightBrown)
                                }
                                
                                // Camera overlay
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .frame(width: 32, height: 32)
                                            .background(Color.black.opacity(0.7))
                                            .clipShape(Circle())
                                            .offset(x: -8, y: -8)
                                    }
                                }
                                .frame(width: 120, height: 120)
                            }
                        }
                    }
                    .padding(.top, BrandSpacing.lg)
                    
                    // Edit Profile Section
                    VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                        Text("Edit profile")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, BrandSpacing.lg)
                        
                        VStack(spacing: BrandSpacing.lg) {
                            // Name Field
                            VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                                HStack {
                                    Text("Name")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, BrandSpacing.lg)
                                
                                Rectangle()
                                    .fill(BrandColor.lightBrown.opacity(0.3))
                                    .frame(height: 1)
                                    .padding(.horizontal, BrandSpacing.lg)
                                
                                TextField("", text: $localName)
                                    .font(.system(size: 16))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.horizontal, BrandSpacing.lg)
                            }
                            
                            // Bio Field
                            VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                                HStack {
                                    Text("Bio")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, BrandSpacing.lg)
                                
                                Rectangle()
                                    .fill(BrandColor.lightBrown.opacity(0.3))
                                    .frame(height: 1)
                                    .padding(.horizontal, BrandSpacing.lg)
                                
                                TextField("", text: $localBio, axis: .vertical)
                                    .font(.system(size: 16))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .lineLimit(3...6)
                                    .padding(.horizontal, BrandSpacing.lg)
                            }
                        }
                    }
                    
                    Spacer(minLength: BrandSpacing.xxxl)
                    
                    // Action Buttons
                    VStack(spacing: BrandSpacing.md) {
                        // Log Out Button
                        Button {
                            logOut()
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Log Out")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(25)
                        .disabled(isLoading)
                        
                        // Delete Account Button
                        Button {
                            deleteAccount()
                        } label: {
                            Text("Delete Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(25)
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.bottom, BrandSpacing.xl)
                }
            }
            .background(BrandColor.white.ignoresSafeArea())
        }
        .onAppear {
            localName = username
            localBio = bio
        }
    }
    
    // MARK: - Actions
    private func saveProfile() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            guard let currentUser = supabase.auth.currentUser else {
                print("No authenticated user found")
                return
            }
            
            do {
                let imageURL = try await uploadImage()
                
                // Parse name into first and last name
                let nameComponents = localName.components(separatedBy: " ")
                let firstName = nameComponents.first ?? ""
                let lastName = nameComponents.dropFirst().joined(separator: " ")
                
                let updatedProfile = Profile(
                    id: currentUser.id,
                    phoneNumber: currentUser.phone ?? "",
                    firstName: firstName,
                    lastName: lastName,
                    username: nil, // Keep existing username
                    profileBio: localBio.isEmpty ? nil : localBio,
                    avatarURL: imageURL,
                    createdAt: nil,
                    updatedAt: Date()
                )
                
                try await supabase
                    .from("profiles")
                    .update(updatedProfile)
                    .eq("id", value: currentUser.id)
                    .execute()
                
                await MainActor.run {
                    // Update parent view bindings
                    username = localName
                    bio = localBio
                    dismiss()
                }
            } catch {
                print("Error saving profile: \(error)")
            }
        }
    }
    
    private func uploadImage() async throws -> String? {
        guard let data = avatarImage?.data else { return nil }
        
        let filePath = "\(UUID().uuidString).jpeg"
        
        try await supabase.storage
            .from("avatars")
            .upload(
                filePath,
                data: data,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        return filePath
    }
    
    private func logOut() {
        Task {
            isLoading = true
            await authManager.signOut()
            dismiss()
        }
    }
    
    private func deleteAccount() {
        // TODO: Implement account deletion with confirmation
        print("Delete account tapped")
    }
}

#Preview {
    ProfileSettingsView(
        username: .constant("Sarah Luan"),
        bio: .constant(""),
        avatarImage: .constant(nil),
        imageSelection: .constant(nil)
    )
}
