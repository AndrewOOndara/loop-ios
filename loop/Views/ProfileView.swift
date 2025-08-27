import PhotosUI
import Storage
import Supabase
import SwiftUI

struct ProfileView: View {
    @State var username = ""
    @State var fullName = ""
    @StateObject private var authManager = AuthManager.shared
        
    
    @State var isLoading = false
    
    @State var imageSelection: PhotosPickerItem?
    @State var avatarImage: AvatarImage?
    
    @State private var postsCount = 46
    @State private var friendsCount = 218
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                PhotosPicker(selection: $imageSelection, matching: .images) {
                                    ZStack {
                                        if let avatarImage {
                                            avatarImage.image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 100, height: 100)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.gray)
                                                )
                                        }
                                        
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.white)
                                            )
                                            .opacity(0.8)
                                    }
                                }
                                
                                Text(fullName.isEmpty ? "Add Name" : fullName)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("@\(username.isEmpty ? "username" : username)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 40) {
                            VStack(spacing: 4) {
                                Text("\(postsCount)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Posts")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(friendsCount)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Friends")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Edit Profile")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            ProfileTextField(title: "Full Name", text: $fullName, placeholder: "Enter your full name")
                            ProfileTextField(title: "Username", text: $username, placeholder: "Enter username")
                        }
                        
                        Button(action: updateProfileButtonTapped) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Update Profile")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                        }
                        .disabled(isLoading)
                        // Sign Out Button
                        Button(action: signOut) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Friends")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                            Button("See All") {
                                // Handle see all friends
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            FriendCard(name: "George", imageName: "person.fill")
                            FriendCard(name: "Megan", imageName: "person.fill")
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
        .task {
            await getInitialProfile()
        }
        .onChange(of: imageSelection) { _, newValue in
            guard let newValue else { return }
            loadTransferable(from: newValue)
        }
    }
    
    func getInitialProfile() async {
        do {
            let currentUser = try await supabase.auth.session.user
            
            let profile: Profile =
            try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            username = profile.username ?? ""
            fullName = "\(profile.firstName ?? "") \(profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
            
            if let avatarURL = profile.avatarURL, !avatarURL.isEmpty {
                try await downloadImage(path: avatarURL)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func updateProfileButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let imageURL = try await uploadImage()
                
                let currentUser = try await supabase.auth.session.user
                
                // Get current user phone from auth
                let userPhone = currentUser.phone ?? ""
                
                let updatedProfile = Profile(
                    id: currentUser.id,
                    phoneNumber: userPhone,
                    firstName: fullName.components(separatedBy: " ").first ?? "",
                    lastName: fullName.components(separatedBy: " ").dropFirst().joined(separator: " "),
                    username: username,
                    profileBio: nil,
                    avatarURL: imageURL,
                    createdAt: nil,
                    updatedAt: Date()
                )
                
                try await supabase
                    .from("profiles")
                    .update(updatedProfile)
                    .eq("id", value: currentUser.id)
                    .execute()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func downloadImage(path: String) async throws {
        let data = try await supabase.storage.from("avatars").download(path: path)
        avatarImage = AvatarImage(data: data)
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
    
    private func signOut() {
        Task {
            await authManager.signOut()
        }
    }
}

// MARK: - Supporting Views

struct ProfileTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .textInputAutocapitalization(title == "Username" ? .never : .words)
                .textContentType(title == "Username" ? .username : .name)
        }
    }
}

struct FriendCard: View {
    let name: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: imageName)
                .font(.system(size: 30))
                .foregroundColor(.gray)
                .frame(width: 60, height: 60)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ProfileView()
}
