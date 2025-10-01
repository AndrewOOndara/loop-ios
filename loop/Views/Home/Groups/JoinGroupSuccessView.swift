import SwiftUI

struct JoinGroupSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    let groupName: String = "test group 1" // Demo group name
    
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
                
                Text("Join a Group")
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
                // Success Message
                VStack(spacing: BrandSpacing.lg) {
                    Text("You have successfully joined")
                        .font(BrandFont.title2)
                        .foregroundColor(BrandColor.black)
                        .multilineTextAlignment(.center)
                    
                    Text(groupName)
                        .font(BrandFont.title1)
                        .foregroundColor(BrandColor.orange)
                        .multilineTextAlignment(.center)
                }
                
                // Success Icon
                ZStack {
                    Circle()
                        .fill(BrandColor.cream)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(BrandColor.orange)
                }
                
                // Additional Info
                Text("You can now see \(groupName) on your home screen and start sharing photos!")
                    .font(BrandFont.body)
                    .foregroundColor(BrandColor.lightBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.lg)
                
                // Done Button - positioned closer to content
                Button {
                    // Refresh the home page to show the new group
                    NotificationCenter.default.post(name: .groupProfileUpdated, object: nil)
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
    JoinGroupSuccessView {
        print("Done tapped")
    }
}
