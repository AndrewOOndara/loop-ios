import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Kingfisher
import WaterfallGrid 

struct GroupDetailView: View {
    let group: UserGroup
    @Environment(\.dismiss) private var dismiss
    @State private var mediaItems: [GroupMedia] = []
    @State private var isUploading: Bool = false
    @State private var isLoadingMedia: Bool = true
    @State private var showingUploadOptions = false
    @State private var uploadFlowState: UploadFlowState = .none
    @State private var selectedMediaType: GroupMediaType = .image
    @State private var selectedMediaItem: GroupMedia? = nil
    @State private var showingEnlargedMedia: Bool = false
    @State private var mediaLikeStates: [Int: (isLiked: Bool, likeCount: Int)] = [:]

    enum UploadFlowState: Equatable {
        case none
        case captionInput(mediaType: GroupMediaType, selectedMedia: [PhotosPickerItem])
        case mediaUpload(mediaType: GroupMediaType)
    }

    private let groupService = GroupService()
    
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                weekInfoSection
                mediaGrid
            }
        }
        .navigationBarHidden(true)
        .task { await loadMedia() }
        .sheet(isPresented: $showingUploadOptions) {
            uploadOptionsSheet
        }
        .sheet(isPresented: .constant(uploadFlowState != .none)) {
            uploadFlowView
        }
        .overlay {
            if showingEnlargedMedia, let selectedItem = selectedMediaItem {
                EnlargedMediaView(
                    mediaItem: selectedItem,
                    allMediaItems: mediaItems,
                    getLikeState: { mediaId in
                        mediaLikeStates[mediaId] ?? (isLiked: false, likeCount: 0)
                    },
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingEnlargedMedia = false
                            selectedMediaItem = nil
                        }
                    },
                    onMediaChange: { newItem in
                        selectedMediaItem = newItem
                    },
                    onToggleLike: { mediaId in
                        Task { await toggleLike(for: mediaId) }
                    }
                )
            }
        }
        .onAppear {
            // 👇 Prefetch all media thumbnails for smoother scrolling
            let urls = mediaItems.compactMap {
                try? groupService.getPublicURL(for: $0.thumbnailPath ?? $0.storagePath)
            }
            ImagePrefetcher(urls: urls).start()
        }
    }
}

// MARK: - Header
private extension GroupDetailView {
    var headerView: some View {
                HStack {
            Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(BrandColor.black)
                    }
                    .buttonStyle(.plain)
                    
                    Text(group.name)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColor.black)
                    
                    Spacer()

            Button {
                showingUploadOptions = true
            } label: {
                        if isUploading {
                            ProgressView().tint(BrandColor.orange)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(BrandColor.orange)
                        }
                    }
            .buttonStyle(.plain)
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.top, BrandSpacing.md)
                .padding(.bottom, BrandSpacing.lg)
    }
}
                
// MARK: - Week Info Section
private extension GroupDetailView {
    var weekInfoSection: some View {
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    HStack {
                        Text("This week's collage")
                            .font(BrandFont.headline)
                            .foregroundColor(BrandColor.black)
                        
                        Text("(7/28 - 8/3)")
                            .font(BrandFont.subheadline)
                            .foregroundColor(BrandColor.orange)
                    }
                    
                    Text("Group Details")
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.bottom, BrandSpacing.xl)
    }
}
                
// MARK: - Media Grid (Waterfall)
private extension GroupDetailView {
    var mediaGrid: some View {
                ScrollView(.vertical, showsIndicators: false) {
                    if isLoadingMedia {
                loadingSkeleton
            } else if mediaItems.isEmpty {
                emptyState
            } else {
                WaterfallGrid(mediaItems, id: \.id) { item in
                    MediaTile(
                        item: item,
                        isSelected: selectedMediaItem?.id == item.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedMediaItem = item
                                showingEnlargedMedia = true
                            }
                        }
                    )
                }
                .gridStyle(
                    columns: 2,
                    spacing: BrandSpacing.sm,
                    animation: .easeInOut(duration: 0.25)
                )
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.bottom, 100)
            }
        }
    }

    var loadingSkeleton: some View {
                        VStack(spacing: BrandSpacing.md) {
                            ForEach(0..<4, id: \.self) { _ in
                                HStack(spacing: BrandSpacing.sm) {
                                    RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                        .fill(BrandColor.systemGray5)
                        .frame(height: 160)
                                    RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                        .fill(BrandColor.systemGray5)
                        .frame(height: 180)
                                }
                            }
                        }
                        .padding(.horizontal, BrandSpacing.lg)
                        .padding(.bottom, 100)
    }

    var emptyState: some View {
                        VStack {
                            Spacer(minLength: 60)
                            VStack(spacing: BrandSpacing.md) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 36, weight: .regular))
                                    .foregroundColor(BrandColor.lightBrown)
                                Text("No uploads yet")
                                    .font(BrandFont.headline)
                                    .foregroundColor(BrandColor.black)
                                Text("Be the first to add a memory to this group.")
                                    .font(BrandFont.body)
                                    .foregroundColor(BrandColor.lightBrown)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, BrandSpacing.lg)
                            Spacer(minLength: 120)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 100)
    }
}

// MARK: - Upload Sheets
private extension GroupDetailView {
    var uploadOptionsSheet: some View {
        UploadOptionsView(
            onDismiss: { showingUploadOptions = false },
            onPhotoTap: {
                selectedMediaType = .image
                showingUploadOptions = false
                uploadFlowState = .captionInput(mediaType: .image, selectedMedia: [])
            },
            onVideoTap: {
                selectedMediaType = .video
                showingUploadOptions = false
                uploadFlowState = .captionInput(mediaType: .video, selectedMedia: [])
            },
            onAudioTap: {
                selectedMediaType = .audio
                showingUploadOptions = false
                uploadFlowState = .captionInput(mediaType: .audio, selectedMedia: [])
            },
            onMusicTap: {
                selectedMediaType = .music
                showingUploadOptions = false
                uploadFlowState = .captionInput(mediaType: .music, selectedMedia: [])
            }
        )
    }

    @ViewBuilder
    var uploadFlowView: some View {
        switch uploadFlowState {
        case .none:
            EmptyView()
        case .captionInput(let mediaType, let selectedMedia):
            CaptionInputView(
                group: group,
                mediaType: mediaType,
                selectedMedia: selectedMedia,
                onBack: { uploadFlowState = .none },
                onComplete: {
                    uploadFlowState = .none
                    Task { await loadMedia() }
                }
            )
        case .mediaUpload(let mediaType):
            SimpleUploadView(
                group: group,
                mediaType: mediaType,
                onBack: { uploadFlowState = .none },
                onComplete: {
                    uploadFlowState = .none
                    Task { await loadMedia() }
                }
            )
        }
    }
}

// MARK: - Media Tile (Dynamic Height)
private struct MediaTile: View {
    let item: GroupMedia
    let isSelected: Bool
    let onTap: () -> Void
    private let service = GroupService()
    @State private var imageSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            if let url = try? service.getPublicURL(for: item.thumbnailPath ?? item.storagePath) {
                KFImage(url)
                    .placeholder {
                        Color(UIColor.systemGray5)
                            .frame(height: 200)
                    }
                    .onSuccess { result in
                        imageSize = result.image.size
                    }
                    .fade(duration: 0.25)
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(
                        imageSize.width > 0 ? imageSize.width / imageSize.height : 1,
                        contentMode: .fit
                    )
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                            .stroke(BrandColor.systemGray6, lineWidth: 0.5)
                    )
            } else {
                Color(UIColor.systemGray5)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
            }

            if item.mediaType == .video {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
        }
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Helpers
private extension GroupDetailView {
    func loadMedia() async {
        await MainActor.run { isLoadingMedia = true }
        
        do {
            let media = try await groupService.fetchGroupMedia(groupId: group.id)
            await MainActor.run {
                self.mediaItems = media
                self.isLoadingMedia = false
            }
            
            // Load like states for all media
            await loadLikeStates(for: media)
        } catch {
            print("[GroupDetailView] Failed to load media: \(error)")
            await MainActor.run { self.isLoadingMedia = false }
        }
    }
    
    func loadLikeStates(for media: [GroupMedia]) async {
        guard let currentUser = AuthManager.shared.currentUser else { return }
        
        var newLikeStates: [Int: (isLiked: Bool, likeCount: Int)] = [:]
        
        for item in media {
            do {
                let isLiked = try await groupService.hasUserLikedMedia(mediaId: item.id, userId: currentUser.id)
                let likeCount = try await groupService.getLikeCount(mediaId: item.id)
                newLikeStates[item.id] = (isLiked: isLiked, likeCount: likeCount)
            } catch {
                print("[GroupDetailView] Failed to load like state for media \(item.id): \(error)")
                newLikeStates[item.id] = (isLiked: false, likeCount: 0)
            }
        }
        
        await MainActor.run {
            self.mediaLikeStates = newLikeStates
        }
    }
    
    func toggleLike(for mediaId: Int) async {
        guard let currentUser = AuthManager.shared.currentUser else { return }
        
        let currentState = mediaLikeStates[mediaId] ?? (isLiked: false, likeCount: 0)
        
        do {
            if currentState.isLiked {
                // Unlike
                try await groupService.unlikeMedia(mediaId: mediaId, userId: currentUser.id)
                let newLikeCount = max(0, currentState.likeCount - 1)
                await MainActor.run {
                    mediaLikeStates[mediaId] = (isLiked: false, likeCount: newLikeCount)
                }
            } else {
                // Like
                try await groupService.likeMedia(mediaId: mediaId, userId: currentUser.id)
                let newLikeCount = currentState.likeCount + 1
                await MainActor.run {
                    mediaLikeStates[mediaId] = (isLiked: true, likeCount: newLikeCount)
                }
            }
        } catch {
            print("[GroupDetailView] Failed to toggle like for media \(mediaId): \(error)")
        }
    }
}

// MARK: - Enlarged Media View
struct EnlargedMediaView: View {
    let mediaItem: GroupMedia
    let allMediaItems: [GroupMedia]
    let getLikeState: (Int) -> (isLiked: Bool, likeCount: Int)
    let onDismiss: () -> Void
    let onMediaChange: (GroupMedia) -> Void
    let onToggleLike: (Int) -> Void
    
    @State private var imageSize: CGSize = .zero
    @State private var userProfile: Profile? = nil
    @State private var currentMediaItem: GroupMedia
    @State private var showHeartAnimation = false
    @State private var heartAnimationOffset: CGSize = .zero
    private let service = GroupService()
    
    // Computed property that always gets the current like state from parent
    private var currentLikeState: (isLiked: Bool, likeCount: Int) {
        getLikeState(currentMediaItem.id)
    }
    
    init(mediaItem: GroupMedia, allMediaItems: [GroupMedia], getLikeState: @escaping (Int) -> (isLiked: Bool, likeCount: Int), onDismiss: @escaping () -> Void, onMediaChange: @escaping (GroupMedia) -> Void, onToggleLike: @escaping (Int) -> Void) {
        self.mediaItem = mediaItem
        self.allMediaItems = allMediaItems
        self.getLikeState = getLikeState
        self.onDismiss = onDismiss
        self.onMediaChange = onMediaChange
        self.onToggleLike = onToggleLike
        self._currentMediaItem = State(initialValue: mediaItem)
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: BrandSpacing.lg) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.top, BrandSpacing.lg)
                
                // Enlarged media with navigation arrows
                ZStack {
                    // Main image
                    if let url = try? service.getPublicURL(for: currentMediaItem.thumbnailPath ?? currentMediaItem.storagePath) {
                    KFImage(url)
                        .placeholder {
                            Color(UIColor.systemGray5)
                                .frame(height: 300)
                        }
                        .onSuccess { result in
                            imageSize = result.image.size
                        }
                        .fade(duration: 0.25)
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(
                            imageSize.width > 0 ? imageSize.width / imageSize.height : 1,
                            contentMode: .fit
                        )
                        .padding(.horizontal, BrandSpacing.lg)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .onTapGesture(count: 2) {
                            // Double tap to like with animation
                            triggerHeartAnimation()
                            onToggleLike(currentMediaItem.id)
                        }
                        .overlay(
                            ZStack {
                                // Video play button if needed
                                if currentMediaItem.mediaType == .video {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                
                                // Heart animation overlay
                                if showHeartAnimation {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 80, weight: .bold))
                                        .foregroundColor(.white.opacity(0.6))
                                        .scaleEffect(showHeartAnimation ? 1.2 : 0.1)
                                        .opacity(showHeartAnimation ? 1.0 : 0.0)
                                        .offset(heartAnimationOffset)
                                        .animation(.easeOut(duration: 0.6), value: showHeartAnimation)
                                        .animation(.easeOut(duration: 0.6), value: heartAnimationOffset)
                                }
                            }
                        )
                    } else {
                        Color(UIColor.systemGray5)
                            .frame(height: 300)
                            .padding(.horizontal, BrandSpacing.lg)
                    }
                }
                
                // Content section - centered
                VStack(spacing: BrandSpacing.md) {
                    // Interaction elements and upload info in one row
                    HStack {
                        // Left side - interaction elements
                        HStack(spacing: BrandSpacing.lg) {
                            // Heart icon with like count
                            HStack(spacing: BrandSpacing.sm) {
                                Button(action: {
                                    onToggleLike(currentMediaItem.id)
                                }) {
                                    Image(systemName: currentLikeState.isLiked ? "heart.fill" : "heart")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(currentLikeState.isLiked ? .red : .white)
                                        .scaleEffect(currentLikeState.isLiked ? 1.1 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: currentLikeState.isLiked)
                                }
                                .buttonStyle(.plain)
                                
                                Text("\(currentLikeState.likeCount)")
                                    .font(BrandFont.body)
                                    .foregroundColor(.white)
                                    .animation(.easeInOut(duration: 0.2), value: currentLikeState.likeCount)
                            }
                            
                            // Comment icon with comment count
                            HStack(spacing: BrandSpacing.sm) {
                                Image(systemName: "message")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                Text("0")
                                    .font(BrandFont.body)
                                    .foregroundColor(.white)
                            }
                            
                            // More options - directly after comment icon
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Right side - upload time info (directly below image)
                        Text("Uploaded \(formatUploadDate(mediaItem.createdAt))")
                            .font(BrandFont.caption1)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                    
                    // User info and caption section
                    VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                        // User profile, name, and caption in one row
                        HStack(spacing: BrandSpacing.sm) {
                            // Profile photo - using actual profile photo if available
                            Group {
                                if let profileURL = getProfilePhotoURL() {
                                    KFImage(profileURL)
                                        .placeholder {
                                            Circle()
                                                .fill(BrandColor.lightBrown)
                                                .overlay(
                                                    Text(getUserInitials())
                                                        .font(BrandFont.caption1)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                )
                                        }
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(BrandColor.lightBrown)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(getUserInitials())
                                                .font(BrandFont.caption1)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            
                            // User name
                            Text(getUserName())
                                .font(BrandFont.body)
                                .foregroundColor(.white)
                            
                            // Caption (if exists) - to the right of name in bold
                            if let caption = currentMediaItem.caption, !caption.isEmpty {
                                Text(caption)
                                    .font(BrandFont.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                }
                
                Spacer()
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    let threshold: CGFloat = 50
                    if gesture.translation.width > threshold && canNavigatePrevious() {
                        // Swipe right - go to previous
                        navigateToPrevious()
                    } else if gesture.translation.width < -threshold && canNavigateNext() {
                        // Swipe left - go to next
                        navigateToNext()
                    }
                }
        )
        .onAppear {
            Task {
                await loadUserProfile()
            }
        }
    }
    
    private func formatUploadDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func loadUserProfile() async {
        do {
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentMediaItem.userId)
                .single()
                .execute()
                .value
            
            await MainActor.run {
                userProfile = profile
                }
            } catch {
            print("Failed to load user profile: \(error)")
        }
    }
    
    // MARK: - Navigation Functions
    
    private func getCurrentIndex() -> Int? {
        allMediaItems.firstIndex(where: { $0.id == currentMediaItem.id })
    }
    
    private func canNavigatePrevious() -> Bool {
        guard let currentIndex = getCurrentIndex() else { return false }
        return currentIndex > 0
    }
    
    private func canNavigateNext() -> Bool {
        guard let currentIndex = getCurrentIndex() else { return false }
        return currentIndex < allMediaItems.count - 1
    }
    
    private func navigateToPrevious() {
        guard let currentIndex = getCurrentIndex(), currentIndex > 0 else { return }
        let newItem = allMediaItems[currentIndex - 1]
        currentMediaItem = newItem
        onMediaChange(newItem)
        
        // Reload user profile for new media item
        Task {
            await loadUserProfile()
        }
    }
    
    private func navigateToNext() {
        guard let currentIndex = getCurrentIndex(), currentIndex < allMediaItems.count - 1 else { return }
        let newItem = allMediaItems[currentIndex + 1]
        currentMediaItem = newItem
        onMediaChange(newItem)
        
        // Reload user profile for new media item
        Task {
            await loadUserProfile()
        }
    }
    
    private func triggerHeartAnimation() {
        // Reset animation state
        showHeartAnimation = false
        heartAnimationOffset = .zero
        
        // Start animation
        withAnimation(.easeOut(duration: 0.3)) {
            showHeartAnimation = true
            heartAnimationOffset = CGSize(width: 0, height: -20) // Move up slightly
        }
        
        // Fade out and reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeIn(duration: 0.3)) {
                showHeartAnimation = false
                heartAnimationOffset = .zero
            }
        }
    }
    
    private func getProfilePhotoURL() -> URL? {
        guard let profile = userProfile,
              let avatarURL = profile.avatarURL,
              !avatarURL.isEmpty else {
            return nil
        }
        
        // If it's already a full URL, use it directly
        if avatarURL.hasPrefix("http") {
            return URL(string: avatarURL)
        }
        
        // Otherwise, construct the URL from Supabase storage
        return try? supabase.storage
            .from("avatars")
            .getPublicURL(path: avatarURL)
    }
    
    private func getUserName() -> String {
        guard let profile = userProfile else { return "Unknown User" }
        let firstName = profile.firstName ?? ""
        let lastName = profile.lastName ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return fullName.isEmpty ? (profile.username ?? "Unknown User") : fullName
    }
    
    private func getUserInitials() -> String {
        guard let profile = userProfile else { return "??" }
        let firstName = profile.firstName ?? ""
        let lastName = profile.lastName ?? ""
        
        let firstInitial = firstName.isEmpty ? "" : String(firstName.prefix(1)).uppercased()
        let lastInitial = lastName.isEmpty ? "" : String(lastName.prefix(1)).uppercased()
        
        if !firstInitial.isEmpty && !lastInitial.isEmpty {
            return firstInitial + lastInitial
        } else if !firstInitial.isEmpty {
            return firstInitial
        } else if let username = profile.username, !username.isEmpty {
            return String(username.prefix(2)).uppercased()
        } else {
            return "??"
        }
    }
}
