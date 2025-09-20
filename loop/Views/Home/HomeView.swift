import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: [AuthRoute]
    @ObservedObject private var authManager = AuthManager.shared
    @State private var selectedTab: NavigationBar.Tab = .home
    @State private var showingGroupOptions = false
    @State private var showingUploadOptions = false
    @State private var showingGroupSelection = false
    @State private var showingPhotoUpload = false
    @State private var selectedGroupForUpload: UserGroup? {
        didSet {
            print("🔄 selectedGroupForUpload changed from \(oldValue?.name ?? "nil") to \(selectedGroupForUpload?.name ?? "nil")")
        }
    }
    @State private var selectedMediaType: GroupMediaType = .image
    @State private var groups: [UserGroup] = []
    @State private var groupMedia: [Int: [GroupMedia]] = [:] // Group ID -> Media items
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
                                        ForEach(groups.indices, id: \.self) { index in
                                            GroupCard(
                                                group: $groups[index],
                                                mediaItems: groupMedia[groups[index].id] ?? [], // Pass media for this group
                                                onGroupTap: {
                                                    navigateToGroup(groups[index])
                                                },
                                                onMenuTap: {
                                                    showGroupMenu(groups[index])
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
                    
                    case .profile:
                        ProfileMainView()
                    }
                }
            }
            
            // Bottom Navigation Bar - Fixed to bottom
            VStack {
                Spacer()
                NavigationBar(selectedTab: $selectedTab, onUploadTap: {
                    showingUploadOptions = true
                })
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
        .onReceive(NotificationCenter.default.publisher(for: .groupProfileUpdated)) { _ in
            // Refresh groups when a group profile is updated
            print("🔄 Group profile updated notification received, refreshing groups...")
            loadUserGroups()
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
        .sheet(isPresented: $showingUploadOptions) {
            UploadOptionsView(
                onDismiss: {
                    showingUploadOptions = false
                },
                onPhotoTap: {
                    showingUploadOptions = false
                    selectedMediaType = .image
                    showingGroupSelection = true
                },
                onVideoTap: {
                    showingUploadOptions = false
                    selectedMediaType = .video
                    showingGroupSelection = true
                },
                onAudioTap: {
                    showingUploadOptions = false
                    selectedMediaType = .audio
                    showingGroupSelection = true
                },
                onMusicTap: {
                    showingUploadOptions = false
                    selectedMediaType = .music
                    showingGroupSelection = true
                }
            )
        }
        .sheet(isPresented: $showingGroupSelection) {
            GroupSelectionView(
                onBack: {
                    showingGroupSelection = false
                },
                onNext: { selectedGroup in
                    print("🎯 Group selected: \(selectedGroup.name)")
                    selectedGroupForUpload = selectedGroup
                    print("🎯 selectedGroupForUpload set to: \(selectedGroup.name)")
                    
                    // Immediately show the photo upload without delay
                    showingGroupSelection = false
                    showingPhotoUpload = true
                    print("🎯 showingPhotoUpload set to true immediately")
                }
            )
        }
        .sheet(isPresented: $showingPhotoUpload) {
            Group {
                if let group = selectedGroupForUpload {
                    DebugUploadView(
                        selectedGroup: group,
                        mediaType: selectedMediaType,
                        onClose: {
                            showingPhotoUpload = false
                            selectedGroupForUpload = nil // Reset after upload
                        }
                    )
                } else {
                    VStack {
                        Text("Error: No group selected")
                            .foregroundColor(.red)
                        Text("selectedGroupForUpload is nil")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Debug info:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("showingPhotoUpload: \(showingPhotoUpload)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button("Close") {
                            showingPhotoUpload = false
                        }
                    }
                    .padding()
                    .onAppear {
                        print("🚨 ERROR: Photo upload sheet appeared but selectedGroupForUpload is nil!")
                        print("🚨 showingPhotoUpload: \(showingPhotoUpload)")
                        print("🚨 selectedGroupForUpload: \(selectedGroupForUpload?.name ?? "nil")")
                    }
                }
            }
            .onAppear {
                print("🎯 Photo upload sheet appeared")
                print("🎯 selectedGroupForUpload: \(selectedGroupForUpload?.name ?? "nil")")
            }
        }
    }
    
    // MARK: - Navigation Actions
    private func navigateToNotifications() {
        print("Navigate to notifications")
        navigationPath.append(.notifications)
    }
    
    private func navigateToGroup(_ group: UserGroup) {
        print("Navigate to group: \(group.name)")
        navigationPath.append(.groupDetail(group: group))
    }
    
    private func showGroupMenu(_ group: UserGroup) {
        print("Show menu for group: \(group.name)")
        // Menu is now handled directly in GroupCard with dropdown
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
                
                // Load media for each group
                var mediaDict: [Int: [GroupMedia]] = [:]
                for group in userGroups {
                    do {
                        let media = try await groupService.fetchGroupMedia(groupId: group.id, limit: 4)
                        mediaDict[group.id] = media
                    } catch {
                        print("[HomeView] Error loading media for group \(group.name): \(error)")
                        mediaDict[group.id] = [] // Empty array if no media
                    }
                }
                
                await MainActor.run {
                    self.groups = userGroups
                    self.groupMedia = mediaDict
                    self.isLoading = false
                    print("[HomeView] Loaded \(userGroups.count) groups with media")
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
    
}

#Preview {
    HomeView(navigationPath: .constant([]))
}
