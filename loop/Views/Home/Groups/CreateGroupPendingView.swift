import SwiftUI

struct CreateGroupPendingView: View {
    let group: UserGroup
    let groupImage: UIImage?
    
    var onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    onDone()
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
                
                // Invisible spacer for balance
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .opacity(0)
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.md)
            .padding(.bottom, BrandSpacing.lg)
            .padding(.bottom, BrandSpacing.xl)
            .padding(.bottom, BrandSpacing.xl)
            
            // Main content in top 3/4 of screen
            VStack(spacing: BrandSpacing.xl) {
                // Success Message - matching JoinGroupSuccessView style
                VStack(spacing: BrandSpacing.lg) {
                    Text("Your group")
                        .font(BrandFont.title2)
                        .foregroundColor(BrandColor.black)
                        .multilineTextAlignment(.center)
                    
                    Text(group.name)
                        .font(BrandFont.title1)
                        .foregroundColor(BrandColor.orange)
                        .multilineTextAlignment(.center)
                    
                    Text("has been created!")
                        .font(BrandFont.title2)
                        .foregroundColor(BrandColor.black)
                        .multilineTextAlignment(.center)
                }
                
                // Success Icon - matching JoinGroupSuccessView style
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
            }
            
            Spacer() // Pushes all content to top 3/4
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
    }
}

#Preview {
    CreateGroupPendingView(
        group: UserGroup(id: 1, name: "My Test Group", groupCode: "1234", avatarURL: nil, createdBy: UUID(), createdAt: Date(), updatedAt: Date(), isActive: true, maxMembers: 6),
        groupImage: nil,
        onDone: {
            print("Done tapped")
        }
    )
}
