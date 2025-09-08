import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: [AuthRoute]
    @ObservedObject private var authManager = AuthManager.shared
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
                // Main content area based on selected tab
                Group {
                    switch selectedTab {
                    case .home:
                        VStack(spacing: 0) {
                            // Header with logo and notification bell
                            HomeHeader(
                                onNotificationTap: {
                                    navigateToNotifications()
                                },
                                onCreateGroupTap: {
                                    showGroupOptions()
                                },
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
                    
                    case .upload:
                        // Upload content placeholder
                        VStack {
                            Spacer()
                            Text("Upload")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Upload functionality coming soon")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(BrandColor.white.ignoresSafeArea())
                    
                    case .profile:
                        ProfileMainView()
                    }
                }
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
            if selectedTab == .home {
                loadUserGroups()
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .home && groups.isEmpty {
                loadUserGroups()
            }
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
                var models = userGroups.map { convertToGroupModel($0) }
                // Fetch latest 4 media previews per group
                try await fetchPreviews(for: &models)
                await MainActor.run {
                    self.groups = models
                    self.isLoading = false
                    print("[HomeView] Loaded \(userGroups.count) groups with previews")
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
            backendId: userGroup.id,
            name: userGroup.name,
            lastUpload: "No uploads yet", // Placeholder - would come from actual uploads
            previewImages: [] // Will be filled by fetchPreviews
        )
    }
    
    private func fetchPreviews(for models: inout [GroupModel]) async throws {
        // Fetch previews concurrently
        try await withThrowingTaskGroup(of: (Int, [String]).self) { group in
            for (index, model) in models.enumerated() {
                group.addTask {
                    let media = try await groupService.fetchGroupMedia(groupId: model.backendId, limit: 4)
                    let paths = media.map { $0.thumbnailPath ?? $0.storagePath }
                    return (index, paths)
                }
            }
            for try await (index, paths) in group {
                models[index] = GroupModel(
                    id: models[index].id,
                    backendId: models[index].backendId,
                    name: models[index].name,
                    lastUpload: models[index].lastUpload,
                    previewImages: paths
                )
            }
        }
    }
}

#Preview {
    HomeView(navigationPath: .constant([]))
}
