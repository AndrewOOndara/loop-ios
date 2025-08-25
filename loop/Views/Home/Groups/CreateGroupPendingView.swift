import SwiftUI

struct CreateGroupPendingView: View {
    let groupName: String
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
            
            VStack(spacing: BrandSpacing.xl) {
                // Success Content
                VStack(spacing: BrandSpacing.xl) {
                    // Status Message
                    VStack(spacing: BrandSpacing.md) {
                        Text("Your group \"\(groupName)\" is pending!")
                            .font(BrandFont.title3)
                            .foregroundColor(BrandColor.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, BrandSpacing.lg)
                    }
                    .padding(.top, BrandSpacing.xl)
                    
                    // Success Icon with checkmark
                    ZStack {
                        Circle()
                            .fill(BrandColor.orange)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Additional Info
                    Text("You must wait for at least 2 other friends to accept the invite to make the group official.")
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.lightBrown)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.lg)
                }
                
                // Done Button
                Button {
                    onDone()
                } label: {
                    Text("Done")
                        .font(BrandFont.headline)
                        .foregroundColor(.white)
                }
                .primaryButton(isEnabled: true)
                .padding(.horizontal, BrandSpacing.lg)
                
                Spacer() // Pushes content to top 3/4
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
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
