import SwiftUI
import Kingfisher

struct GroupCard: View {
    @Binding var group: UserGroup
    let mediaItems: [GroupMedia] // Recent media items for this group
    var onGroupTap: () -> Void
    var onMenuTap: () -> Void
    @State private var isPressed: Bool = false
    @State private var userNames: [UUID: String] = [:] // Cache for user names
    @State private var currentMemberCount: Int = 0
    @State private var showingDropdownMenu: Bool = false
    @State private var showingMemberList: Bool = false
    private let groupService = GroupService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            // Group Header
            HStack {
                // Group Profile Photo
                if let avatarURL = group.avatarURL, let url = try? groupService.getPublicURL(for: avatarURL) {
                    KFImage(url)
                        .placeholder {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(BrandColor.orange)
                        }
                        .cacheMemoryOnly(false) // Enable disk caching
                        .fade(duration: 0.1) // Quick fade for better UX
                        .loadDiskFileSynchronously() // Load from disk cache synchronously
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } else {
                    // Default group icon when no avatar
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(BrandColor.orange)
                        .padding(BrandSpacing.sm)
                        .background(BrandColor.cream)
                        .clipShape(Circle())
                }
                
                // Group Name with Arrow
                Button {
                    // Temporary highlight then navigate
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isPressed = false
                        onGroupTap()
                    }
                } label: {
                    HStack(spacing: BrandSpacing.xs) {
                        Text(group.name)
                            .font(BrandFont.title2)
                            .foregroundColor(isPressed ? BrandColor.orange : BrandColor.black)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isPressed ? BrandColor.orange : BrandColor.black)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Three Dots Menu
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingDropdownMenu.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(showingDropdownMenu ? BrandColor.orange : BrandColor.systemGray)
                        .rotationEffect(.degrees(90))
                }
                .buttonStyle(.plain)
            }
            
            // Subtitle: show last upload info and member count
            HStack {
                // Last upload info
                if let lastMedia = mediaItems.first {
                    Text(formatLastUpload(lastMedia))
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                } else {
                    Text("No uploads yet")
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                }
                
                Spacer()
                
                // Member count
                Text("\(currentMemberCount) members")
                    .font(BrandFont.footnote)
                    .foregroundColor(BrandColor.systemGray)
            }
            
            // Preview Images Grid (2x2) - Always show 4 squares
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: BrandSpacing.sm), count: 2),
                spacing: BrandSpacing.sm
            ) {
                ForEach(0..<4, id: \.self) { index in
                    if index < mediaItems.count {
                        // Show actual media preview
                        let media = mediaItems[index]
                        PreviewTile(media: media)
                    } else {
                        // Show empty placeholder
                        PreviewTile(media: nil)
                    }
                }
            }
        }
        .padding(BrandSpacing.md)
        .cardStyle() // Apply card styling from our design system
        .overlay(alignment: .topTrailing) {
            if showingDropdownMenu {
                GroupDropdownMenu(
                    group: $group,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingDropdownMenu = false
                        }
                    },
                    onShowMemberList: {
                        print("🔍 GroupCard: Showing member list...")
                        showingMemberList = true
                    }
                )
                .frame(width: 220)
                .offset(x: -8, y: 40) // Position it below the three dots
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing))
                ))
                .zIndex(1000) // Ensure it appears above other content
            }
        }
        .onTapGesture {
            // Dismiss dropdown when tapping outside
            if showingDropdownMenu {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingDropdownMenu = false
                }
            }
        }
        .onAppear {
            loadUserNames()
            loadMemberCount()
        }
        .sheet(isPresented: $showingMemberList) {
            GroupMemberListView(group: group)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .onAppear {
                    print("🎯 Member list sheet appeared from GroupCard!")
                }
                .onDisappear {
                    print("🎯 Member list sheet disappeared from GroupCard!")
                }
        }
    }
    
    // Helper function to format last upload with user name and smart date/time
    private func formatLastUpload(_ media: GroupMedia) -> String {
        guard let createdAt = media.createdAt else { return "Last upload: Unknown" }
        
        let userName = userNames[media.userId] ?? "Unknown User"
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(createdAt, inSameDayAs: now) {
            // Same day - show time
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let timeString = formatter.string(from: createdAt)
            return "Last upload by \(userName) at \(timeString)"
        } else {
            // Different day - show date
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            let dateString = formatter.string(from: createdAt)
            return "Last upload by \(userName) on \(dateString)"
        }
    }
    
    // Helper function to format dates (kept for compatibility)
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Load user names for media items
    private func loadUserNames() {
        let userIds = Set(mediaItems.map { $0.userId })
        
        Task {
            for userId in userIds {
                if userNames[userId] == nil {
                    do {
                        let profile = try await ProfileService.shared.getProfile(userId: userId)
                        await MainActor.run {
                            let fullName = "\(profile.firstName ?? "") \(profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
                            userNames[userId] = fullName.isEmpty ? "Unknown User" : fullName
                        }
                    } catch {
                        print("[GroupCard] Failed to load user name for \(userId): \(error)")
                        await MainActor.run {
                            userNames[userId] = "Unknown User"
                        }
                    }
                }
            }
        }
    }
    
    // Load current member count for the group
    private func loadMemberCount() {
        Task {
            do {
                let count = try await groupService.getMemberCount(groupId: group.id)
                await MainActor.run {
                    currentMemberCount = count
                }
            } catch {
                print("[GroupCard] Failed to load member count for group \(group.name): \(error)")
                await MainActor.run {
                    currentMemberCount = 0
                }
            }
        }
    }
}

private struct PreviewTile: View {
    let media: GroupMedia?
    private let groupService = GroupService()
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            ZStack {
                // Background placeholder
                Rectangle()
                    .fill(BrandColor.systemGray5)
                    .frame(width: size, height: size)
                
                if let media = media {
                    // Show actual media preview
                    if let url = try? groupService.getPublicURL(for: media.storagePath) {
                        KFImage(url)
                            .placeholder {
                                Image(systemName: "photo")
                                    .foregroundColor(BrandColor.systemGray3)
                            }
                            .cacheMemoryOnly(false) // Enable disk caching
                            .fade(duration: 0.1) // Quick fade for better UX
                            .loadDiskFileSynchronously() // Load from disk cache synchronously
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipped()
                            .transaction { t in t.animation = nil }
                    } else {
                        // Show placeholder icon if URL creation fails
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(BrandColor.systemGray3)
                    }
                } else {
                    // Show empty placeholder icon (like the mountain/sun icon you showed)
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(BrandColor.systemGray3)
                }
            }
            .frame(width: size, height: size)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                    .stroke(BrandColor.systemGray6, lineWidth: 0.5)
            )
        }
        .aspectRatio(1, contentMode: .fit) // Force square aspect ratio
        .frame(maxWidth: .infinity) // Take available width
    }
}

#Preview {
    let sampleGroup = UserGroup(
        id: 1,
        name: "jones 2025",
        groupCode: "ABC123",
        avatarURL: nil,
        createdBy: UUID(),
        createdAt: Date(),
        updatedAt: Date(),
        isActive: true,
        maxMembers: 10
    )
    
    return GroupCard(
        group: .constant(sampleGroup),
        mediaItems: [], // Empty for preview
        onGroupTap: { print("Group tapped: \(sampleGroup.name)") },
        onMenuTap: { print("Menu tapped for: \(sampleGroup.name)") }
    )
    .padding()
    .background(BrandColor.cream)
}
