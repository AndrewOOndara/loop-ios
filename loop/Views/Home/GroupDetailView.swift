import SwiftUI

struct GroupDetailView: View {
    let group: GroupModel
    @Environment(\.dismiss) private var dismiss
    @State private var mediaItems: [GroupMedia] = []
    @State private var isUploading: Bool = false
    @State private var showPicker: Bool = false
    @State private var selectedPHPickerItems: [PhotosPickerItem] = []
    private let groupService = GroupService()
    
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and group name
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(BrandColor.black)
                    }
                    .buttonStyle(.plain)
                    
                    Text(group.name)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColor.black)
                    
                    Spacer()
                    PhotosPicker(selection: $selectedPHPickerItems, matching: .any(of: [.images, .videos]), photoLibrary: .shared()) {
                        if isUploading {
                            ProgressView().tint(BrandColor.orange)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(BrandColor.orange)
                        }
                    }
                    .onChange(of: selectedPHPickerItems) { _, newItems in
                        guard !newItems.isEmpty else { return }
                        Task { await handlePicked(items: newItems) }
                    }
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.top, BrandSpacing.md)
                .padding(.bottom, BrandSpacing.lg)
                
                // Week information section
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    HStack {
                        Text("This week's collage")
                            .font(BrandFont.headline)
                            .foregroundColor(BrandColor.black)
                        
                        Text("(7/28 - 8/3)")
                            .font(BrandFont.subheadline)
                            .foregroundColor(BrandColor.orange)
                    }
                    
                    Text(group.lastUpload)
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.bottom, BrandSpacing.xl)
                
                // Collage grid
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: BrandSpacing.sm),
                        GridItem(.flexible(), spacing: BrandSpacing.sm)
                    ], spacing: BrandSpacing.sm) {
                        ForEach(mediaItems, id: \.id) { item in
                            MediaTile(item: item)
                        }
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.bottom, 100) // Space for navigation bar
                }
            }
        }
        .navigationBarHidden(true)
        .task { await loadMedia() }
    }
}

#Preview {
    let sampleGroup = GroupModel(
        id: UUID(),
        name: "jones 2025",
        lastUpload: "Last upload by Sarah Luan on 7/30/2025 at 11:10 AM",
        previewImages: ["photo1", "photo2", "photo3", "photo4"]
    )
    
    return GroupDetailView(group: sampleGroup)
}

// MARK: - Media Tile
private struct MediaTile: View {
    let item: GroupMedia
    private let service = GroupService()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: try? service.getPublicURL(for: item.thumbnailPath ?? item.storagePath)) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(BrandColor.systemGray5)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle().fill(BrandColor.systemGray5)
                @unknown default:
                    Rectangle().fill(BrandColor.systemGray5)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
            
            if item.mediaType == .video {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .padding(8)
            }
        }
    }
}

// MARK: - Private helpers
private extension GroupDetailView {
    func loadMedia() async {
        do {
            mediaItems = try await groupService.fetchGroupMedia(groupId: group.id)
        } catch {
            print("[GroupDetailView] Failed to load media: \(error)")
        }
    }
    
    func handlePicked(items: [PhotosPickerItem]) async {
        guard let currentUser = supabase.auth.currentUser else { return }
        isUploading = true
        defer { isUploading = false }
        
        for item in items {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    // Determine type via uniform type identifiers
                    let supportsVideo = (try? await item.loadTransferable(type: Movie.self)) != nil
                    // Fallback using content type from item
                    let suggestedType = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
                    let lower = suggestedType.lowercased()
                    let mediaType: GroupMediaType = (lower == "mp4" || lower == "mov") || supportsVideo ? .video : .image
                    let ext = lower
                    
                    // For videos we could generate thumbnail client-side later. For now omit.
                    let uploaded = try await groupService.uploadMedia(
                        groupId: group.id,
                        userId: currentUser.id,
                        data: data,
                        fileExtension: ext,
                        mediaType: mediaType,
                        thumbnailData: nil
                    )
                    mediaItems.insert(uploaded, at: 0)
                }
            } catch {
                print("[GroupDetailView] Upload failed: \(error)")
            }
        }
        selectedPHPickerItems = []
    }
}
