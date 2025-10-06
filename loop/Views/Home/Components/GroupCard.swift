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
    @State private var showingEditProfile: Bool = false
    @State private var showingShareCode: Bool = false
    
    private let groupService = GroupService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            // MARK: - Header
            HStack {
                GroupAvatarView(avatarURL: group.avatarURL)
                    .frame(width: 32, height: 32)
                
                // Group Name
                Button {
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
                
                // Dropdown Menu
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingDropdownMenu.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .rotationEffect(.degrees(90))
                        .foregroundColor(showingDropdownMenu ? BrandColor.orange : BrandColor.systemGray)
                }
                .buttonStyle(.plain)
            }
            
            // MARK: - Subtitle
            HStack {
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
                
                Text("\(currentMemberCount) members")
                    .font(BrandFont.footnote)
                    .foregroundColor(BrandColor.systemGray)
            }
            
            // MARK: - Preview Grid (2x2)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: BrandSpacing.sm), count: 2),
                spacing: BrandSpacing.sm
            ) {
                ForEach(0..<4, id: \.self) { index in
                    if index < mediaItems.count {
                        PreviewTile(media: mediaItems[index])
                    } else {
                        PreviewTile(media: nil)
                    }
                }
            }
        }
        .padding(BrandSpacing.md)
        .cardStyle()
        .overlay(alignment: .topTrailing) {
            if showingDropdownMenu {
                GroupDropdownMenu(
                    group: $group,
                    onDismiss: { showingDropdownMenu = false },
                    onShowMemberList: { showingMemberList = true },
                    onShowEditProfile: { showingEditProfile = true },
                    onShowShareCode: { showingShareCode = true }
                )
                .frame(width: 220)
                .offset(x: -8, y: 40)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing))
                ))
                .zIndex(1000)
            }
        }
        .onTapGesture {
            if showingDropdownMenu {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingDropdownMenu = false
                }
            }
        }
        .onAppear {
            prefetchImages()
            loadUserNames()
            loadMemberCount()
        }
        // MARK: - Sheets
        .sheet(isPresented: $showingMemberList) {
            GroupMemberListView(group: group)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileWorkingView(group: $group, onDismiss: {
                showingEditProfile = false
            })
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingShareCode) {
            ShareGroupCodeView(group: group)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Helper Methods
    
    private func prefetchImages() {
        let urls = mediaItems.compactMap { try? groupService.getPublicURL(for: $0.storagePath) }
        ImagePrefetcher(urls: urls).start()
    }
    
    private func formatLastUpload(_ media: GroupMedia) -> String {
        guard let createdAt = media.createdAt else { return "Last upload: Unknown" }
        let userName = userNames[media.userId] ?? "Unknown User"
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(createdAt, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Last upload by \(userName) at \(formatter.string(from: createdAt))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return "Last upload by \(userName) on \(formatter.string(from: createdAt))"
        }
    }
    
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
                        await MainActor.run { userNames[userId] = "Unknown User" }
                    }
                }
            }
        }
    }
    
    private func loadMemberCount() {
        Task {
            do {
                let count = try await groupService.getMemberCount(groupId: group.id)
                await MainActor.run { currentMemberCount = count }
            } catch {
                await MainActor.run { currentMemberCount = 0 }
            }
        }
    }
}

// MARK: - Group Avatar
private struct GroupAvatarView: View {
    let avatarURL: String?
    private let groupService = GroupService()
    
    var body: some View {
        if let avatarURL = avatarURL, let url = try? groupService.getPublicURL(for: avatarURL) {
            KFImage(url)
                .placeholder { Image(systemName: "person.2.fill").foregroundColor(BrandColor.orange) }
                .fade(duration: 0.25)
                .cacheOriginalImage()
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else {
            Image(systemName: "person.2.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(BrandColor.orange)
                .padding(BrandSpacing.sm)
                .background(BrandColor.cream)
                .clipShape(Circle())
        }
    }
}

// MARK: - Preview Tile
private struct PreviewTile: View {
    let media: GroupMedia?
    private let groupService = GroupService()
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            ZStack {
                Rectangle()
                    .fill(BrandColor.systemGray5)
                
                if let media = media, let url = try? groupService.getPublicURL(for: media.storagePath) {
                    KFImage(url)
                        .placeholder { Rectangle().fill(BrandColor.systemGray5) }
                        .fade(duration: 0.25)
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(BrandColor.systemGray3)
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                    .stroke(BrandColor.systemGray6, lineWidth: 0.5)
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }
}
