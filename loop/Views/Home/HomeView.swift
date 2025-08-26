import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: [AuthRoute]
    @State private var selectedTab: NavigationBar.Tab = .home
    @State private var showingGroupOptions = false
    @State private var groups: [GroupModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let groupService = GroupService()
    
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
                        if isLoading {
                            // Loading state
                            VStack(spacing: BrandSpacing.lg) {
                                ProgressView()
                                    .tint(BrandColor.orange)
                                Text("Loading your groups...")
                                    .font(BrandFont.body)
                                    .foregroundColor(BrandColor.lightBrown)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding(.top, BrandSpacing.xl)
                        } else if groups.isEmpty {
                            // Empty state - centered on screen
                            
                            Spacer()
                            
                            VStack(spacing: BrandSpacing.lg) {
                                Image(systemName: "person.2.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundColor(BrandColor.lightBrown)
                                    .padding(.top, BrandSpacing.xl)
                                    .padding(.top, BrandSpacing.xl)
                                    .padding(.top, BrandSpacing.xl)
                                    .padding(.top, BrandSpacing.xl)
                                
                                Text("No Groups Yet")
                                    .font(BrandFont.title2)
                                    .foregroundColor(BrandColor.black)
                                
                                Text("Join a group or create your own to get started!")
                                    .font(BrandFont.body)
                                    .foregroundColor(BrandColor.lightBrown)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    showGroupOptions()
                                } label: {
                                    Text("Join or Create Group")
                                        .font(BrandFont.headline)
                                        .foregroundColor(.white)
                                }
                                .primaryButton(isEnabled: true)
                                .padding(.horizontal, BrandSpacing.xl)
                                .padding(.top, BrandSpacing.md)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, BrandSpacing.lg)
                            
                            Spacer()
                        } else {
                            // Groups list
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
                        }
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .errorMessage()
                                .padding(.horizontal, BrandSpacing.lg)
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
        .onAppear {
            loadUserGroups()
        }
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
    
    func refreshGroups() {
        loadUserGroups()
    }
    
    private func navigateToCreateGroup() {
        print("Navigate to create group")
        navigationPath.append(.createGroup)
    }
    
    // MARK: - Data Loading
    private func loadUserGroups() {
        guard let currentUser = supabase.auth.currentUser else {
            print("[HomeView] No current user")
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let userGroups = try await groupService.getUserGroups(userId: currentUser.id)
                await MainActor.run {
                    self.groups = userGroups.map { convertToGroupModel($0) }
                    self.isLoading = false
                    print("[HomeView] Loaded \(userGroups.count) groups")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load groups"
                    self.isLoading = false
                    print("[HomeView] Error loading groups: \(error)")
                }
            }
        }
    }
    
    private func convertToGroupModel(_ userGroup: UserGroup) -> GroupModel {
        return GroupModel(
            id: UUID(), // Generate a new UUID for UI purposes
            name: userGroup.name,
            lastUpload: "No uploads yet", // Placeholder - would come from actual uploads
            previewImages: [] // Placeholder - would come from actual uploads
        )
    }
}

#Preview {
    HomeView(navigationPath: .constant([]))
}
