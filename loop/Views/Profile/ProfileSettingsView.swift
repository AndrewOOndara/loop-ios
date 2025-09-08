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
    @State private var nameError: String?
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, bio
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BrandSpacing.xl) {
                    // Header
                    HStack {
                        Button("Cancel") {
                            print("Cancel button tapped")
                            dismiss()
                        }
                        .foregroundColor(.primary)
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text("Settings")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Save") {
                            print("Save button tapped")
                            saveProfile()
                        }
                        .foregroundColor(BrandColor.orange)
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.sm)
                    
                    // Profile Image Section
                    VStack(spacing: BrandSpacing.md) {
                        PhotosPicker(selection: $imageSelection, matching: .images, photoLibrary: .shared()) {
                            ZStack {
                                Circle()
                                    .fill(BrandColor.white)
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
                                            .background(BrandColor.orange)
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
                        Text("Edit Profile")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, BrandSpacing.lg)
                        
                        VStack(spacing: BrandSpacing.lg) {
                            // Name Field - Underlined style like profile setup
                            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                                HStack {
                                    Text("Name")
                                        .font(BrandFont.caption1)
                                        .foregroundColor(BrandColor.lightBrown)
                                    
                                    Text("*")
                                        .font(BrandFont.caption1)
                                        .foregroundColor(BrandColor.orange)
 
                                    Spacer()
                                }
                                
                                TextField("", text: $localName)
                                    .focused($focusedField, equals: .name)
                                    .foregroundColor(BrandColor.black)
                                    .font(BrandFont.body)
                                    .padding(.vertical, BrandSpacing.sm)
                                    .textContentType(.name)
                                    .autocapitalization(.words)
                                    .onChange(of: localName) { oldValue, newValue in
                                        if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            nameError = "You must have a name"
                                        } else {
                                            nameError = nil
                                        }
                                    }
                                
                                Rectangle()
                                    .fill(nameError != nil ? BrandColor.error : (focusedField == .name ? BrandColor.orange : BrandColor.lightBrown))
                                    .frame(height: 1)
                                    .animation(.easeInOut(duration: 0.2), value: focusedField == .name)
                                
                                if let nameError {
                                    Text(nameError)
                                        .font(BrandFont.caption2)
                                        .foregroundColor(BrandColor.error)
                                        .padding(.top, BrandSpacing.xs)
                                }
                            }
                            .padding(.horizontal, BrandSpacing.lg)
                            
                            // Bio Field - Underlined style
                            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                                HStack {
                                    Text("Bio")
                                        .font(BrandFont.caption1)
                                        .foregroundColor(BrandColor.lightBrown)
                                    
                                    Spacer()
                                    
                                    Text("\(localBio.count)/80")
                                        .font(BrandFont.caption2)
                                        .foregroundColor(localBio.count > 80 ? BrandColor.error : BrandColor.lightBrown)
                                }
                                
                                TextField("", text: $localBio, axis: .vertical)
                                    .focused($focusedField, equals: .bio)
                                    .foregroundColor(BrandColor.black)
                                    .font(BrandFont.body)
                                    .padding(.vertical, BrandSpacing.sm)
                                    .lineLimit(2...4)
                                    .onChange(of: localBio) { oldValue, newValue in
                                        if newValue.count > 80 {
                                            localBio = String(newValue.prefix(80))
                                        }
                                    }
                                
                                Rectangle()
                                    .fill(focusedField == .bio ? BrandColor.orange : BrandColor.lightBrown)
                                    .frame(height: 1)
                                    .animation(.easeInOut(duration: 0.2), value: focusedField == .bio)
                            }
                            .padding(.horizontal, BrandSpacing.lg)
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
            .background(BrandColor.cream.ignoresSafeArea())
        }
        .onAppear {
            localName = username
            localBio = bio
        }
        .onChange(of: imageSelection) { _, newValue in
            print("Image selection changed: \(newValue != nil)")
            guard let newValue else { return }
            loadTransferable(from: newValue)
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    
    // MARK: - Actions
    private func saveProfile() {
        print("saveProfile() called")
        
        // Validate name before saving
        if localName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("Name validation failed")
            nameError = "You must have a name"
            return
        }
        
        print("Name validation passed, starting save process")
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            guard let currentUser = supabase.auth.currentUser else {
                print("No authenticated user found")
                return
            }
            
            print("User authenticated, proceeding with save")
            
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
                
                print("Profile saved successfully to database")
                
                await MainActor.run {
                    print("Updating parent view and dismissing popup")
                    // Update parent view bindings
                    username = localName
                    bio = localBio
                    print("About to dismiss popup")
                    dismiss()
                    print("Dismiss called")
                }
            } catch {
                print("Error saving profile: \(error)")
                print("Save failed, popup will remain open")
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
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                print("Loading image from PhotosPicker")
                avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
                print("Image loaded successfully")
            } catch {
                print("Error loading image: \(error)")
            }
        }
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
