import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: [AuthRoute]
    @State private var selectedTab: NavigationBar.Tab = .home
    @State private var showingGroupOptions = false
    
    // Sample data - in real app this would come from backend
    let groups: [GroupModel] = [
        GroupModel(
            id: UUID(),
            name: "test group 1",
            lastUpload: "Last upload by test user on 8/01/2025 at 1:00 PM",
            previewImages: ["photo1", "photo2", "photo3", "photo4"]
        ),
        GroupModel(
            id: UUID(),
            name: "test group 2",
            lastUpload: "Last upload by test user on 8/01/2025 at 1:05 PM",
            previewImages: ["photo1", "photo2", "photo3", "photo4"]
        ),
        GroupModel(
            id: UUID(),
            name: "test group 3",
            lastUpload: "Last upload by test user on 8/01/2025 at 1:10 PM",
            previewImages: ["photo1", "photo2", "photo3", "photo4"]
        )
    ]
    
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with logo and notification bell
                HomeHeader(
                    onNotificationTap: {
                        navigateToNotifications()
                    },
                    onCreateGroupTap: {
                        showGroupOptions()
                    }
                )
                
                // Main content area - Scrollable
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: BrandSpacing.sm) {
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
                    .padding(.horizontal, BrandSpacing.sm)
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
        .sheet(isPresented: $showingGroupOptions) {
            GroupOptionsView(
                onJoinGroup: {
                    showingGroupOptions = false
                    navigateToJoinGroup()
                },
                onCreateGroup: {
                    showingGroupOptions = false
                    navigateToCreateGroup()
                }
            )
        }
    }
    
    // MARK: - Navigation Actions
    private func navigateToNotifications() {
        print("Navigate to notifications")
        navigationPath.append(.notifications)
    }
    
    private func navigateToGroup(_ group: GroupModel) {
        print("Navigate to group: \(group.name)")
        navigationPath.append(.groupDetail(group: group))
    }
    
    private func showGroupMenu(_ group: GroupModel) {
        print("Show menu for group: \(group.name)")
        // TODO: Implement group action menu
    }
    
    private func showGroupOptions() {
        showingGroupOptions = true
    }
    
    private func navigateToJoinGroup() {
        print("Navigate to join group")
        navigationPath.append(.joinGroup)
    }
    
    private func navigateToCreateGroup() {
        print("Navigate to create group")
        navigationPath.append(.createGroup)
    }
}

#Preview {
    HomeView(navigationPath: .constant([]))
}
