import SwiftUI

struct HomeView: View {
    @State private var selectedTab: NavigationBar.Tab = .home
    
    // Sample data - in real app this would come from backend
    let groups: [GroupModel] = [
        GroupModel(
            id: UUID(),
            name: "jones 2025",
            lastUpload: "Last upload by Sarah Luan on 7/30/2025 at 11:10 AM",
            previewImages: ["photo1", "photo2", "photo3", "photo4"]
        ),
        GroupModel(
            id: UUID(),
            name: "rice volleyball",
            lastUpload: "Last upload by Sam Lim on 7/31/2025 at 4:13 PM",
            previewImages: ["photo5", "photo6", "photo7", "photo8"]
        )
    ]
    
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with logo and notification bell
                HomeHeader {
                    navigateToNotifications()
                }
                
                // Main content area - Scrollable
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: BrandSpacing.xxl) {
                        ForEach(groups) { group in
                            GroupCard(
                                group: group,
                                onGroupTap: {
                                    navigateToGroup(group)
                                },
                                onMenuTap: {
                                    showGroupMenu(group)
                                }
                            )
                        }
                        
                        // Add some extra content to test scrolling
                        ForEach(0..<3, id: \.self) { index in
                            GroupCard(
                                group: GroupModel(
                                    id: UUID(),
                                    name: "test group \(index + 3)",
                                    lastUpload: "Last upload by Test User on 8/1/2025 at 2:00 PM",
                                    previewImages: ["photo1", "photo2", "photo3", "photo4"]
                                ),
                                onGroupTap: {
                                    print("Test group \(index + 3) tapped")
                                },
                                onMenuTap: {
                                    print("Test group \(index + 3) menu tapped")
                                }
                            )
                        }
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.bottom, 100) // Ensure content doesn't get hidden behind navbar
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure ScrollView takes available space
            }
            
            // Bottom Navigation Bar - Fixed to bottom
            VStack {
                Spacer()
                NavigationBar(selectedTab: $selectedTab)
                    .background(
                        BrandColor.white
                            .ignoresSafeArea(.container, edges: .bottom) // Extend white background to bottom edge
                    )
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Navigation Actions
    private func navigateToNotifications() {
        print("Navigate to notifications")
        // TODO: Implement navigation to notifications view
    }
    
    private func navigateToGroup(_ group: GroupModel) {
        print("Navigate to group: \(group.name)")
        // TODO: Implement navigation to group detail view
    }
    
    private func showGroupMenu(_ group: GroupModel) {
        print("Show menu for group: \(group.name)")
        // TODO: Implement group action menu
    }
}

#Preview {
    HomeView()
}