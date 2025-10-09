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
                    MediaTile(item: item)
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
        } catch {
            print("[GroupDetailView] Failed to load media: \(error)")
            await MainActor.run { self.isLoadingMedia = false }
        }
    }
}
