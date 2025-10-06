import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Kingfisher

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
        case mediaUpload(mediaType: GroupMediaType)
    }

    private let groupService = GroupService()

    // Fixed tile size for consistent grid
    private let tileSize: CGFloat = 160

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

// MARK: - Media Grid
private extension GroupDetailView {
    var mediaGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if isLoadingMedia {
                loadingSkeleton
            } else if mediaItems.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: [
                    GridItem(.fixed(tileSize), spacing: BrandSpacing.sm),
                    GridItem(.fixed(tileSize), spacing: BrandSpacing.sm)
                ], spacing: BrandSpacing.sm) {
                    ForEach(mediaItems, id: \.id) { item in
                        MediaTile(item: item, tileSize: tileSize)
                    }
                }
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
                        .frame(width: tileSize, height: tileSize)
                    RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                        .fill(BrandColor.systemGray5)
                        .frame(width: tileSize, height: tileSize)
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
                uploadFlowState = .mediaUpload(mediaType: .image)
            },
            onVideoTap: {
                selectedMediaType = .video
                showingUploadOptions = false
                uploadFlowState = .mediaUpload(mediaType: .video)
            },
            onAudioTap: {
                selectedMediaType = .audio
                showingUploadOptions = false
                uploadFlowState = .mediaUpload(mediaType: .audio)
            },
            onMusicTap: {
                selectedMediaType = .music
                showingUploadOptions = false
                uploadFlowState = .mediaUpload(mediaType: .music)
            }
        )
    }

    @ViewBuilder
    var uploadFlowView: some View {
        switch uploadFlowState {
        case .none:
            EmptyView()
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

// MARK: - Media Tile
private struct MediaTile: View {
    let item: GroupMedia
    let tileSize: CGFloat
    private let service = GroupService()

    var body: some View {
        ZStack {
            if let url = try? service.getPublicURL(for: item.thumbnailPath ?? item.storagePath) {
                KFImage(url)
                    .cacheOriginalImage()
                    .placeholder {
                        Color(UIColor.systemGray5)
                            .frame(width: tileSize, height: tileSize)
                    }
                    .fade(duration: 0.25)
                    .resizable()
                    .scaledToFill()
                    .frame(width: tileSize, height: tileSize)
                    .clipped()
            } else {
                Color(UIColor.systemGray5)
                    .frame(width: tileSize, height: tileSize)
            }

            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: tileSize, height: tileSize)
            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))

            if item.mediaType == .video {
                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                    .frame(width: tileSize, height: tileSize, alignment: .bottomTrailing)
            }
        }
        .frame(width: tileSize, height: tileSize)
        .background(BrandColor.systemGray6)
        .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                .stroke(BrandColor.systemGray6, lineWidth: 0.5)
        )
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
