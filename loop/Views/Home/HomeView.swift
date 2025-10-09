import SwiftUI
import PhotosUI

struct HomeView: View {
    @Binding var navigationPath: [AuthRoute]
    @ObservedObject private var authManager = AuthManager.shared
    @State private var selectedTab: NavigationBar.Tab = .home
    @State private var showingGroupOptions = false
    @State private var showingUploadOptions = false
    @State private var uploadFlowState: UploadFlowState = .none
    @State private var selectedMediaType: GroupMediaType = .image
    
    enum UploadFlowState: Equatable {
        case none
        case groupSelection(mediaType: GroupMediaType)
        case captionInput(group: UserGroup, mediaType: GroupMediaType, selectedMedia: [PhotosPickerItem])
        case photoUpload(group: UserGroup, mediaType: GroupMediaType)
    }
    @State private var groups: [UserGroup] = []
    @State private var groupMedia: [Int: [GroupMedia]] = [:] // Group ID -> Media items
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var lastLoadTime: Date? = nil
    private let cacheTimeout: TimeInterval = 30 // 30 seconds cache
    
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
                loadUserGroupsIfNeeded()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .groupProfileUpdated)) { _ in
            // Refresh groups when a group profile is updated
            print("🔄 Group profile updated notification received, refreshing groups...")
            loadUserGroups()
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .home {
                loadUserGroupsIfNeeded()
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
                    uploadFlowState = .groupSelection(mediaType: .image)
                },
                onVideoTap: {
                    showingUploadOptions = false
                    uploadFlowState = .groupSelection(mediaType: .video)
                },
                onAudioTap: {
                    showingUploadOptions = false
                    uploadFlowState = .groupSelection(mediaType: .audio)
                },
                onMusicTap: {
                    showingUploadOptions = false
                    uploadFlowState = .groupSelection(mediaType: .music)
                }
            )
        }
        .sheet(isPresented: Binding(
            get: { uploadFlowState != .none },
            set: { _ in uploadFlowState = .none }
        )) {
            switch uploadFlowState {
            case .none:
                EmptyView()
            case .groupSelection(let mediaType):
                GroupSelectionView(
                    onBack: {
                        uploadFlowState = .none
                    },
                    onNext: { selectedGroup in
                        print("🎯 Group selected: \(selectedGroup.name)")
                        uploadFlowState = .captionInput(group: selectedGroup, mediaType: mediaType, selectedMedia: [])
                        print("🎯 Upload flow state set to captionInput with group: \(selectedGroup.name) and mediaType: \(mediaType.rawValue)")
                    }
                )
            case .captionInput(let group, let mediaType, let selectedMedia):
                CaptionInputView(
                    group: group,
                    mediaType: mediaType,
                    selectedMedia: selectedMedia,
                    onBack: {
                        uploadFlowState = .groupSelection(mediaType: mediaType)
                    },
                    onComplete: {
                        uploadFlowState = .none
                    }
                )
            case .photoUpload(let group, let mediaType):
                SimpleUploadView(
                    group: group,
                    mediaType: mediaType,
                    onBack: {
                        if case .groupSelection(let mediaType) = uploadFlowState {
                            uploadFlowState = .groupSelection(mediaType: mediaType)
                        } else {
                            uploadFlowState = .groupSelection(mediaType: .image)
                        }
                    },
                    onComplete: {
                        uploadFlowState = .none
                    }
                )
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
    private func loadUserGroupsIfNeeded() {
        // Check if we need to reload based on cache timeout
        if let lastLoad = lastLoadTime,
           Date().timeIntervalSince(lastLoad) < cacheTimeout,
           !groups.isEmpty {
            print("🚀 Using cached groups data (loaded \(Date().timeIntervalSince(lastLoad))s ago)")
            return
        }
        
        loadUserGroups()
    }
    
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
                
                // Load media for all groups in parallel for better performance
                let mediaDict = await withTaskGroup(of: (Int, [GroupMedia]).self) { group in
                    var result: [Int: [GroupMedia]] = [:]
                    
                    for userGroup in userGroups {
                        group.addTask {
                            do {
                                let media = try await groupService.fetchGroupMedia(groupId: userGroup.id, limit: 4)
                                return (userGroup.id, media)
                            } catch {
                                print("[HomeView] Error loading media for group \(userGroup.name): \(error)")
                                return (userGroup.id, []) // Empty array if no media
                            }
                        }
                    }
                    
                    for await (groupId, media) in group {
                        result[groupId] = media
                    }
                    
                    return result
                }
                
                await MainActor.run {
                    self.groups = userGroups
                    self.groupMedia = mediaDict
                    self.isLoading = false
                    self.lastLoadTime = Date() // Update cache timestamp
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
