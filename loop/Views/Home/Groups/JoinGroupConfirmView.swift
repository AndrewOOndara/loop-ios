import SwiftUI

struct JoinGroupConfirmView: View {
    let group: UserGroup
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var memberCount: Int = 0
    @State private var founderName: String = "Unknown"
    
    private let groupService = GroupService()
    
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with properly aligned Cancel button
            ZStack {
                // Centered title
                HStack {
                    Spacer()
                    Text("Join a Group")
                        .font(BrandFont.title2)
                        .foregroundColor(BrandColor.black)
                    Spacer()
                }
                // Right-aligned Cancel button
                HStack {
                    Button("Cancel") {
                        onCancel() // Cancel takes user back to home screen
                    }
                    .font(.system(size: 17))
                    .foregroundColor(BrandColor.orange)
                }
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.xl)
            .padding(.bottom, BrandSpacing.lg)
            
            VStack(spacing: BrandSpacing.xl) {
                // Question
                Text("Is this the group you would like to join?")
                    .font(BrandFont.title3)
                    .foregroundColor(BrandColor.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.xl)
                
                // Group Preview Card
                VStack(spacing: BrandSpacing.lg) {
                    // Group Icon
                    ZStack {
                        Circle()
                            .fill(BrandColor.cream)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 32))
                            .foregroundColor(BrandColor.orange)
                    }
                    
                    // Group Info
                    VStack(spacing: BrandSpacing.sm) {
                        Text(group.name)
                            .font(BrandFont.title2)
                            .foregroundColor(BrandColor.black)
                        
                        Text("Founded by \(founderName)")
                            .font(BrandFont.body)
                            .foregroundColor(BrandColor.lightBrown)
                        
                        Text("\(memberCount) members")
                            .font(BrandFont.caption1)
                            .foregroundColor(BrandColor.lightBrown)
                    }
                }
                .padding(BrandSpacing.xl)
                .background(BrandColor.white)
                .cardStyle()
                .padding(.horizontal, BrandSpacing.lg)
                
                // Action Buttons - positioned closer to content
                HStack(spacing: BrandSpacing.md) {
                    // No Button
                    Button {
                        onCancel()
                    } label: {
                        Text("No")
                            .font(BrandFont.headline)
                            .foregroundColor(BrandColor.lightBrown)
                    }
                    .secondaryButton(isEnabled: !isLoading)
                    .disabled(isLoading)
                    
                    // Yes Button
                    Button {
                        joinGroup()
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Yes")
                                    .font(BrandFont.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .primaryButton(isEnabled: !isLoading)
                    .disabled(isLoading)
                }
                .padding(.horizontal, BrandSpacing.lg)
                
                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .errorMessage()
                        .padding(.horizontal, BrandSpacing.lg)
                }
                
                Spacer() // Pushes content to top 3/4
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .onAppear {
            loadGroupInfo()
        }
    }
    
    private func loadGroupInfo() {
        Task {
            do {
                // Get member count
                let count = try await groupService.getMemberCount(groupId: group.id)
                
                // Note: In a real app, you'd also fetch the founder's name from profiles table
                // For now, we'll show a placeholder
                
                await MainActor.run {
                    memberCount = count
                    founderName = "Group Admin" // Placeholder - would fetch from profiles in real app
                }
            } catch {
                print("[JoinGroupConfirm] Error loading group info: \(error)")
            }
        }
    }
    
    private func joinGroup() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Get current user ID from Supabase auth
                guard let user = supabase.auth.currentUser else {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Please log in to join a group"
                    }
                    return
                }
                
                print("[JoinGroupConfirm] User \(user.id) joining group \(group.id)")
                
                // Actually join the group
                _ = try await groupService.joinGroup(groupId: group.id, userId: user.id)
                
                await MainActor.run {
                    isLoading = false
                    onConfirm() // Navigate to success screen
                }
                
            } catch {
                print("[JoinGroupConfirm] Error joining group: \(error)")
                await MainActor.run {
                    isLoading = false
                    if let groupError = error as? GroupServiceError {
                        errorMessage = groupError.localizedDescription
                    } else {
                        errorMessage = "Failed to join group. Please try again."
                    }
                }
            }
        }
    }
}

#Preview {
    let previewGroup = UserGroup(
        id: 1,
        name: "Preview Group",
        groupCode: "1234",
        avatarURL: nil,
        createdBy: UUID(),
        createdAt: Date(),
        updatedAt: Date(),
        isActive: true,
        maxMembers: 6
    )
    
    JoinGroupConfirmView(
        group: previewGroup,
        onConfirm: { print("Group joined!") },
        onCancel: { print("Cancelled") }
    )
}
