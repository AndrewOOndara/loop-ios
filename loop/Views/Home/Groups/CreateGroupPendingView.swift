import SwiftUI
import Supabase

struct CreateGroupPendingView: View {
    let groupName: String
    let groupImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var createdGroup: UserGroup?
    
    private let groupService = GroupService()
    
    var onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                // Spacer to balance any future right-side elements
                Spacer()
                
                Text("Create a Group")
                    .font(BrandFont.title2)
                    .foregroundColor(BrandColor.black)
                
                Spacer()
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.md)
            .padding(.bottom, BrandSpacing.lg)
            .padding(.bottom, BrandSpacing.xl)
            .padding(.bottom, BrandSpacing.xl)
            
            // Main content in top 3/4 of screen
            VStack(spacing: BrandSpacing.xl) {
                if isLoading {
                    // Loading state
                    VStack(spacing: BrandSpacing.lg) {
                        ProgressView()
                            .tint(BrandColor.orange)
                            .scaleEffect(1.5)
                        
                        Text("Creating your group...")
                            .font(BrandFont.title3)
                            .foregroundColor(BrandColor.black)
                            .multilineTextAlignment(.center)
                    }
                } else if let errorMessage = errorMessage {
                    // Error state
                    VStack(spacing: BrandSpacing.lg) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(BrandColor.orange)
                        
                        Text("Oops!")
                            .font(BrandFont.title2)
                            .foregroundColor(BrandColor.black)
                        
                        Text(errorMessage)
                            .font(BrandFont.body)
                            .foregroundColor(BrandColor.lightBrown)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, BrandSpacing.lg)
                    }
                } else if let createdGroup = createdGroup {
                    // Success Message - matching JoinGroupSuccessView style
                    VStack(spacing: BrandSpacing.lg) {
                        Text("Your group")
                            .font(BrandFont.title2)
                            .foregroundColor(BrandColor.black)
                            .multilineTextAlignment(.center)
                        
                        Text(createdGroup.name)
                            .font(BrandFont.title1)
                            .foregroundColor(BrandColor.orange)
                            .multilineTextAlignment(.center)
                        
                        Text("has been created!")
                            .font(BrandFont.title2)
                            .foregroundColor(BrandColor.black)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    // Initial state - should start creating immediately
                    VStack(spacing: BrandSpacing.lg) {
                        Text("Creating your group...")
                            .font(BrandFont.title2)
                            .foregroundColor(BrandColor.black)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Success Icon - only show when group is created
                if createdGroup != nil {
                    ZStack {
                        Circle()
                            .fill(BrandColor.cream)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(BrandColor.orange)
                    }
                    
                    // Additional Info
                    Text("Share the group code with friends so they can join and start sharing photos!")
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.lightBrown)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.lg)
                    
                    // Done Button - positioned closer to content
                    Button {
                        onDone()
                    } label: {
                        Text("Done")
                            .font(BrandFont.headline)
                            .foregroundColor(.white)
                    }
                    .primaryButton(isEnabled: true)
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.md)
                } else if errorMessage != nil {
                    // Retry Button
                    Button {
                        createGroup()
                    } label: {
                        Text("Try Again")
                            .font(BrandFont.headline)
                            .foregroundColor(.white)
                    }
                    .primaryButton(isEnabled: true)
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.md)
                }
            }
            
            Spacer() // Pushes all content to top 3/4
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .onAppear {
            createGroup()
        }
    }
    
    private func createGroup() {
        // Don't create if already loading or already created
        guard !isLoading && createdGroup == nil else { return }
        
        isLoading = true
        errorMessage = nil
        
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
                
                print("[CreateGroupPending] Creating group: \(groupName)")
                
                // TODO: Handle image upload to Supabase Storage if groupImage exists
                let avatarURL: String? = nil
                if groupImage != nil {
                    // For now, we'll skip image upload - you can add this later
                    print("[CreateGroupPending] Image upload not implemented yet")
                }
                
                // Create the group
                let newGroup = try await groupService.createGroup(
                    name: groupName,
                    createdBy: currentUser.id,
                    avatarURL: avatarURL
                )
                
                await MainActor.run {
                    isLoading = false
                    createdGroup = newGroup
                    print("[CreateGroupPending] Successfully created group: \(newGroup.name) with code: \(newGroup.groupCode)")
                }
                
            } catch {
                print("[CreateGroupPending] Error creating group: \(error)")
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
    CreateGroupPendingView(
        groupName: "My Test Group",
        groupImage: nil,
        onDone: {
            print("Done tapped")
        }
    )
}
