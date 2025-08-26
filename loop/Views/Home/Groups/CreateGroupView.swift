import SwiftUI
import PhotosUI

struct CreateGroupView: View {
    @State private var groupName: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var groupImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let groupService = GroupService()
    
    var onNext: (UserGroup, UIImage?) -> Void // Changed to pass the created UserGroup
    var onBack: (() -> Void)? = nil
    
    private var isValidGroupName: Bool {
        groupName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrandColor.black)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Create a Group")
                    .font(BrandFont.title2)
                    .foregroundColor(BrandColor.black)
                
                Spacer()
                
                Button {
                    // Cancel action - same as back
                    onBack?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrandColor.black)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.md)
            .padding(.bottom, BrandSpacing.lg)
            
            // Main content in top 3/4 of screen
            VStack(spacing: BrandSpacing.xl) {
                // Question
                Text("What's your group name?")
                    .font(BrandFont.title3)
                    .foregroundColor(BrandColor.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.xl)
                
                // Photo Upload Section
                VStack(spacing: BrandSpacing.sm) {
                    ZStack {
                        // Group image or placeholder - matching ProfileSetupView style
                        if let groupImage {
                            Image(uiImage: groupImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(BrandColor.white)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(BrandColor.lightBrown)
                                )
                        }
                        
                        // Camera button - matching ProfileSetupView style
                        PhotosPicker(
                            selection: $selectedPhoto,
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
                    
                    Text("Upload a group photo")
                        .font(BrandFont.caption1)
                        .foregroundColor(BrandColor.lightBrown)
                }
                
                // Group Name Input
                VStack(spacing: BrandSpacing.md) {
                    TextField("Group Name", text: $groupName)
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.black)
                        .padding(.horizontal, BrandSpacing.md)
                        .padding(.vertical, BrandSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: BrandUI.cornerRadiusExtraLarge)
                                .fill(BrandColor.white)
                                .stroke(BrandColor.lightBrown, lineWidth: 1)
                        )
                        .textInputAutocapitalization(.words)
                        .textContentType(.name)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .errorMessage()
                    }
                }
                .padding(.horizontal, BrandSpacing.lg)
                
                // Next Button
                Button {
                    createGroup()
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Next")
                                .font(BrandFont.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .primaryButton(isEnabled: isValidGroupName && !isLoading)
                .disabled(!isValidGroupName || isLoading)
                .padding(.horizontal, BrandSpacing.lg)
            }
            .padding(.top, BrandSpacing.xl)
            
            Spacer() // Pushes all content to top 3/4
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .onChange(of: selectedPhoto) { oldValue, newValue in
            loadSelectedPhoto()
        }
    }
    
    private func loadSelectedPhoto() {
        guard let selectedPhoto else { return }
        
        Task {
            do {
                if let data = try await selectedPhoto.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        self.groupImage = image
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load selected photo"
                }
            }
        }
    }
    
    private func createGroup() {
        guard isValidGroupName else { return }
        
        isLoading = true
        errorMessage = nil
        
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                // Get current user
                guard let currentUser = supabase.auth.currentUser else {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Please log in to create a group"
                    }
                    return
                }
                
                print("[CreateGroup] Creating group: \(trimmedName)")
                
                // TODO: Handle image upload to Supabase Storage if groupImage exists
                var avatarURL: String? = nil
                if let groupImage = groupImage {
                    // For now, we'll skip image upload - you can add this later
                    print("[CreateGroup] Image upload not implemented yet")
                }
                
                // Create the group
                let createdGroup = try await groupService.createGroup(
                    name: trimmedName,
                    createdBy: currentUser.id,
                    avatarURL: avatarURL
                )
                
                await MainActor.run {
                    isLoading = false
                    print("[CreateGroup] Successfully created group: \(createdGroup.name) with code: \(createdGroup.groupCode)")
                    onNext(createdGroup, groupImage)
                }
                
            } catch {
                print("[CreateGroup] Error creating group: \(error)")
                await MainActor.run {
                    isLoading = false
                    if let groupError = error as? GroupServiceError {
                        errorMessage = groupError.localizedDescription
                    } else {
                        errorMessage = "Failed to create group. Please try again."
                    }
                }
            }
        }
    }
}

#Preview {
    CreateGroupView(
        onNext: { name, image in
            print("Creating group: \(name)")
        },
        onBack: {
            print("Back tapped")
        }
    )
}
