import SwiftUI

struct HomeHeader: View {
    var onNotificationTap: () -> Void
    var onCreateGroupTap: () -> Void
    
    var body: some View {
        ZStack {
            // Centered Loop Logo
            LoopWordmark(fontSize: 32, color: BrandColor.orange)
            
            // Left and Right buttons
            HStack {
                // Create/Join Group Button (left)
                Button {
                    onCreateGroupTap()
                } label: {
                    Image(systemName: "person.2.badge.plus")
                        .font(.system(size: 24))
                        .foregroundColor(BrandColor.lightBrown)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Notification Bell (right)
                Button {
                    onNotificationTap()
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 24))
                        .foregroundColor(BrandColor.lightBrown)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, BrandSpacing.lg)
        .padding(.top, BrandSpacing.xs) // Reduced from lg to xs
        .padding(.bottom, BrandSpacing.sm) // Reduced from md to sm
    }
}

#Preview {
    HomeHeader(
        onNotificationTap: { print("Notification bell tapped") },
        onCreateGroupTap: { print("Create group tapped") }
    )
    .background(BrandColor.white)
}
