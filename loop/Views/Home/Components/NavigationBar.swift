import SwiftUI

struct NavigationBar: View {
    @Binding var selectedTab: Tab
    
    enum Tab {
        case home, upload, profile
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Thin brown separator line
            Rectangle()
                .fill(BrandColor.lightBrown)
                .frame(height: 1)
            
            // Navigation content
            HStack(spacing: BrandSpacing.xxxl) {
                // Home Button
                Button {
                    selectedTab = .home
                    print("Home tapped")
                } label: {
                    VStack(spacing: BrandSpacing.xs) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 24))
                        Text("Home")
                            .font(BrandFont.caption2) // Smaller font to fit better
                            .lineLimit(1) // Prevent text wrapping
                    }
                    .foregroundColor(selectedTab == .home ? BrandColor.orange : BrandColor.lightBrown)
                }
                .buttonStyle(.plain)
                
                // Upload Button (Center)
                Button {
                    selectedTab = .upload
                    print("Upload tapped")
                } label: {
                    ZStack {
                        Circle()
                            .fill(BrandColor.lightBrown)
                            .frame(width: 56, height: 56) // Slightly smaller
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(BrandColor.white)
                    }
                }
                .buttonStyle(.plain)
                
                // Profile Button
                Button {
                    selectedTab = .profile
                    print("Profile tapped")
                } label: {
                    VStack(spacing: BrandSpacing.xs) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                        Text("Profile")
                            .font(BrandFont.caption2) // Smaller font to fit better
                            .lineLimit(1) // Prevent text wrapping
                    }
                    .foregroundColor(selectedTab == .profile ? BrandColor.orange : BrandColor.lightBrown)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BrandSpacing.xxxl)
            .padding(.top, BrandSpacing.sm) // Reduced top padding
            .padding(.bottom, BrandSpacing.xs) // Minimal bottom padding
            .background(BrandColor.white)
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: NavigationBar.Tab = .home
    return NavigationBar(selectedTab: $selectedTab)
        .background(BrandColor.cream)
}
