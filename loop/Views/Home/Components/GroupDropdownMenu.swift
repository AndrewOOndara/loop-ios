import SwiftUI

// MARK: - Notification Names
extension Notification.Name {
    static let groupProfileUpdated = Notification.Name("groupProfileUpdated")
}

struct GroupDropdownMenu: View {
    @Binding var group: UserGroup
    let onDismiss: () -> Void
    let onShowMemberList: () -> Void
    @State private var showingEditProfile = false
    @State private var showingShareCode = false
    @State private var showingLeaveConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Edit group profile picture
            DropdownMenuItem(
                icon: "camera.fill",
                title: "Edit group profile",
                action: {
                    print("🎯 Edit group profile tapped")
                    showingEditProfile = true
                    print("🎯 showingEditProfile set to: \(showingEditProfile)")
                    // Don't auto-dismiss dropdown - let user close it manually
                }
            )
            
            Divider()
                .padding(.leading, 44)
            
            // Member list
            DropdownMenuItem(
                icon: "person.2.fill",
                title: "Member list",
                action: {
                    print("🔍 Member list tapped, calling callback...")
                    onDismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onShowMemberList()
                    }
                }
            )
            
            Divider()
                .padding(.leading, 44)
            
            // Share group code
            DropdownMenuItem(
                icon: "square.and.arrow.up.fill",
                title: "Share group code",
                action: {
                    onDismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingShareCode = true
                    }
                }
            )
            
            Divider()
                .padding(.leading, 44)
            
            // Leave group
            DropdownMenuItem(
                icon: "person.fill.xmark",
                title: "Leave group",
                iconColor: .red,
                titleColor: .red,
                action: {
                    onDismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingLeaveConfirmation = true
                    }
                }
            )
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showingEditProfile) {
            EditProfileWorkingView(group: $group, onDismiss: {
                showingEditProfile = false
                onDismiss()
            })
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .onAppear {
                print("🎯 Edit profile sheet appeared!")
            }
            .onDisappear {
                print("🎯 Edit profile sheet disappeared!")
            }
        }
        .sheet(isPresented: $showingShareCode) {
            ShareCodeView(group: group)
        }
        .alert("Leave Group", isPresented: $showingLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                // TODO: Implement leave group functionality
                print("User wants to leave group: \(group.name)")
            }
        } message: {
            Text("Are you sure you want to leave \"\(group.name)\"? You'll need the group code to rejoin.")
        }
    }
}

private struct DropdownMenuItem: View {
    let icon: String
    let title: String
    var iconColor: Color = BrandColor.orange
    var titleColor: Color = BrandColor.black
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 20, height: 20)
                
                // Title
                Text(title)
                    .font(BrandFont.body)
                    .foregroundColor(titleColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(isPressed ? Color(.systemGray6) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0) {
            // This won't trigger the action, just the visual feedback
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}

private struct ShareCodeView: View {
    let group: UserGroup
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: BrandSpacing.xl) {
                // Group info
                VStack(spacing: BrandSpacing.md) {
                    Text("Share Group Code")
                        .font(BrandFont.title1)
                        .foregroundColor(BrandColor.black)
                    
                    Text("Share this code with friends to let them join \"\(group.name)\"")
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.systemGray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, BrandSpacing.xl)
                
                // Group code display
                VStack(spacing: BrandSpacing.md) {
                    Text("Group Code")
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                        .textCase(.uppercase)
                        .tracking(1.0)
                    
                    Text(group.groupCode)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(BrandColor.orange)
                        .tracking(8.0)
                        .padding(.horizontal, BrandSpacing.lg)
                        .padding(.vertical, BrandSpacing.md)
                        .background(BrandColor.cream)
                        .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                }
                
                // Share button
                Button {
                    // Share the group code
                    let shareText = "Join my group \"\(group.name)\" on Loop! Use code: \(group.groupCode)"
                    let activityViewController = UIActivityViewController(
                        activityItems: [shareText],
                        applicationActivities: nil
                    )
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(activityViewController, animated: true)
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Share Code")
                            .font(BrandFont.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.md)
                    .background(BrandColor.orange)
                    .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                }
                .padding(.horizontal, BrandSpacing.lg)
                
                Spacer()
            }
            .padding(.horizontal, BrandSpacing.lg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(BrandColor.orange)
                }
            }
        }
    }
}

#Preview {
    let sampleGroup = UserGroup(
        id: 1,
        name: "jones 2025",
        groupCode: "ABC123",
        avatarURL: nil,
        createdBy: UUID(),
        createdAt: Date(),
        updatedAt: Date(),
        isActive: true,
        maxMembers: 10
    )
    
    return GroupDropdownMenu(group: .constant(sampleGroup), onDismiss: {}, onShowMemberList: {})
        .padding()
        .background(BrandColor.cream)
}

struct EditProfileWorkingView: View {
    @Binding var group: UserGroup
    let onDismiss: () -> Void
    @State private var groupName: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let groupService = GroupService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Profile Image Section
                    Button(action: {
                        showingImagePicker = true
                        print("📸 Opening image picker")
                    }) {
                        ZStack {
                            if let selectedImage = selectedImage {
                                // Show selected image
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else if let avatarURL = group.avatarURL, !avatarURL.isEmpty {
                                // Show existing group avatar
                                AsyncImage(url: URL(string: avatarURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Circle()
                                        .fill(BrandColor.cream)
                                        .overlay(
                                            Image(systemName: "person.2.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(BrandColor.orange)
                                        )
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                            } else {
                                // Show default group icon (same as GroupCard)
                                Circle()
                                    .fill(BrandColor.cream)
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(BrandColor.orange)
                                    )
                            }
                            
                            // Camera overlay button in bottom right
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(.orange)
                                        .clipShape(Circle())
                                        .offset(x: -8, y: -8)
                                }
                            }
                            .frame(width: 120, height: 120)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 20)
                    
                    // Edit Profile Section
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Edit Group Profile")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Name")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("*")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            
                            TextField("Group name", text: $groupName)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                                .autocapitalization(.words)
                            
                            Rectangle()
                                .fill(.secondary)
                                .frame(height: 1)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Error message display
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(" Group Settings")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isLoading ? "Saving..." : "Save") {
                        saveChanges()
                    }
                    .foregroundColor(.orange)
                    .disabled(groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
            }
        }
        .onAppear {
            groupName = group.name
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func saveChanges() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                // Convert selected image to data if needed
                var imageData: Data? = nil
                if let selectedImage = selectedImage {
                    imageData = selectedImage.jpegData(compressionQuality: 0.8)
                }
                
                // Update group profile in backend
                let newAvatarURL = try await groupService.updateGroupProfile(
                    groupId: group.id,
                    newName: trimmedName,
                    avatarImageData: imageData
                )
                
                // Update local group object with new data
                await MainActor.run {
                    let updatedGroup = UserGroup(
                        id: group.id,
                        name: trimmedName,
                        groupCode: group.groupCode,
                        avatarURL: newAvatarURL ?? group.avatarURL,
                        createdBy: group.createdBy,
                        createdAt: group.createdAt,
                        updatedAt: Date(),
                        isActive: group.isActive,
                        maxMembers: group.maxMembers
                    )
                    group = updatedGroup
                    isLoading = false
                    
                    print("🎯 ✅ Group profile updated successfully!")
                    print("   - Name: \(group.name)")
                    print("   - Avatar URL: \(group.avatarURL ?? "none")")
                    print("   - Image uploaded: \(selectedImage != nil)")
                    
                    // Notify HomeView to refresh the groups list
                    NotificationCenter.default.post(name: .groupProfileUpdated, object: nil)
                    
                    onDismiss()
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to update group: \(error.localizedDescription)"
                    print("❌ Error updating group profile: \(error)")
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct GroupMemberListView: View {
    let group: UserGroup
    @State private var members: [GroupMemberWithProfile] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    private let groupService = GroupService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.orange)
                        Text("Loading members...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Unable to load members")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(members) { member in
                                MemberRow(member: member)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Members")
                            .font(.system(size: 18, weight: .semibold))
                        Text("\(members.count) member\(members.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            loadMembers()
        }
    }
    
    private func loadMembers() {
        print("🔄 Loading members for group: \(group.name) (ID: \(group.id))")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let groupMembers = try await groupService.getGroupMembers(groupId: group.id)
                
                await MainActor.run {
                    self.members = groupMembers
                    self.isLoading = false
                    print("✅ Loaded \(groupMembers.count) members for group: \(group.name)")
                    
                    // Debug member details
                    for member in groupMembers {
                        print("   - Member: \(member.profiles.firstName ?? "Unknown") (Role: \(member.role), Avatar: \(member.profiles.avatarURL ?? "none"))")
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ Error loading members: \(error)")
                    print("   Error details: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct MemberRow: View {
    let member: GroupMemberWithProfile
    private let groupService = GroupService()
    
    var displayName: String {
        if let firstName = member.profiles.firstName, !firstName.isEmpty {
            if let lastName = member.profiles.lastName, !lastName.isEmpty {
                return "\(firstName) \(lastName)"
            }
            return firstName
        } else if let username = member.profiles.username, !username.isEmpty {
            return username
        } else {
            return "Unknown User"
        }
    }
    
    var roleDisplay: String {
        return member.role.capitalized
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Photo
            AsyncImage(url: getProfileImageURL(from: member.profiles.avatarURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(BrandColor.cream)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(BrandColor.orange)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Member Info
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(roleDisplay)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            member.role == "admin" ? Color.orange.opacity(0.2) : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(
                            member.role == "admin" ? .orange : .secondary
                        )
                        .clipShape(Capsule())
                    
                    if let joinedAt = member.joinedAt {
                        Text("Joined \(formatJoinDate(joinedAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private func getProfileImageURL(from avatarURL: String?) -> URL? {
        guard let avatarURL = avatarURL, !avatarURL.isEmpty else {
            return nil
        }
        
        // Try to get the public URL using GroupService
        do {
            return try groupService.getPublicURL(for: avatarURL)
        } catch {
            print("❌ Error getting public URL for avatar: \(error)")
            return nil
        }
    }
    
    private func formatJoinDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "today"
        } else if calendar.isDateInYesterday(date) {
            return "yesterday"
        } else if calendar.dateInterval(of: .weekOfYear, for: Date())?.contains(date) == true {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).lowercased()
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}


