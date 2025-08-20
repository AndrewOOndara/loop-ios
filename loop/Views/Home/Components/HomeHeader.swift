import SwiftUI

struct HomeHeader: View {
    var onNotificationTap: () -> Void
    
    var body: some View {
        ZStack {
            // Centered Loop Logo
            LoopWordmark(fontSize: 32, color: BrandColor.orange)
            
            // Notification Bell (positioned to the right)
            HStack {
                Spacer()
                Button {
                    onNotificationTap()
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 24))
                        .foregroundColor(BrandColor.lightBrown) // Changed to brown
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
    HomeHeader {
        print("Notification bell tapped")
    }
    .background(BrandColor.white)
}
