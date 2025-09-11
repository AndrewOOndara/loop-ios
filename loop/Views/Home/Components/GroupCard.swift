import SwiftUI

struct GroupCard: View {
    let group: UserGroup
    let mediaItems: [GroupMedia] // Recent media items for this group
    var onGroupTap: () -> Void
    var onMenuTap: () -> Void
    @State private var isPressed: Bool = false
    @State private var userNames: [UUID: String] = [:] // Cache for user names
    private let groupService = GroupService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            // Group Header
            HStack {
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
                    onMenuTap()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(BrandColor.systemGray)
                        .rotationEffect(.degrees(90))
                }
                .buttonStyle(.plain)
            }
            
            // Subtitle: show last upload info or empty state
            Group {
                if let lastMedia = mediaItems.first {
                    Text(formatLastUpload(lastMedia))
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                } else {
                    Text("No uploads yet")
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                }
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
        .onAppear {
            loadUserNames()
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
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.clear
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill() // This will crop rectangular images to fit square
                                    .frame(width: size, height: size)
                                    .clipped()
                            case .failure:
                                // Show placeholder icon on failure
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(BrandColor.systemGray3)
                            @unknown default:
                                Color.clear
                            }
                        }
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
        group: sampleGroup,
        mediaItems: [], // Empty for preview
        onGroupTap: { print("Group tapped: \(sampleGroup.name)") },
        onMenuTap: { print("Menu tapped for: \(sampleGroup.name)") }
    )
    .padding()
    .background(BrandColor.cream)
}
