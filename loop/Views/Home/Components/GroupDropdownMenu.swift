import SwiftUI

struct GroupDropdownMenu: View {
    @Binding var group: UserGroup
    let onDismiss: () -> Void
    @State private var showingEditProfile = false
    @State private var showingMemberList = false
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
                    onDismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingMemberList = true
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
        .sheet(isPresented: $showingMemberList) {
            // TODO: Implement member list view
            Text("Member List Coming Soon")
                .font(BrandFont.body)
                .foregroundColor(BrandColor.systemGray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BrandColor.cream)
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
    
    return GroupDropdownMenu(group: .constant(sampleGroup), onDismiss: {})
        .padding()
        .background(BrandColor.cream)
}

struct EditProfileWorkingView: View {
    @Binding var group: UserGroup
    let onDismiss: () -> Void
    @State private var groupName: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
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
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(.orange)
                    .disabled(groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        if !trimmedName.isEmpty {
            // TODO: Upload selectedImage to storage and get URL
            let newAvatarURL = selectedImage != nil ? "updated_image_url" : group.avatarURL
            
            // Create updated group with new name and potentially new avatar
            let updatedGroup = UserGroup(
                id: group.id,
                name: trimmedName,
                groupCode: group.groupCode,
                avatarURL: newAvatarURL,
                createdBy: group.createdBy,
                createdAt: group.createdAt,
                updatedAt: Date(),
                isActive: group.isActive,
                maxMembers: group.maxMembers
            )
            group = updatedGroup
            print("🎯 Group profile updated - Name: \(group.name), Image: \(selectedImage != nil ? "Updated" : "No change")")
        }
        onDismiss()
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


