import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct GroupDetailView: View {
    let group: UserGroup
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
                    
                    Text("Group Details")
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.bottom, BrandSpacing.xl)
                
                // Collage grid
                ScrollView(.vertical, showsIndicators: false) {
                    if mediaItems.isEmpty {
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
                    } else {
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
        }
        .navigationBarHidden(true)
        .task { await loadMedia() }
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
    
    GroupDetailView(group: sampleGroup)
}

// MARK: - Media Tile
private struct MediaTile: View {
    let item: GroupMedia
    private let service = GroupService()
    
    var body: some View {
        ZStack {
            // Image
            AsyncImage(url: try? service.getPublicURL(for: item.thumbnailPath ?? item.storagePath)) { phase in
                switch phase {
                case .empty:
                    Color(UIColor.systemGray5)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Color(UIColor.systemGray5)
                @unknown default:
                    Color(UIColor.systemGray5)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipped()

            // Gradient overlay for readability
            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))

            // Video badge
            if item.mediaType == .video {
                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .background(BrandColor.systemGray6)
        .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                .stroke(BrandColor.systemGray6, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
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
                    // Determine type via content types / extensions
                    let utType = item.supportedContentTypes.first
                    let ext = utType?.preferredFilenameExtension?.lowercased() ?? "jpg"
                    let mediaType: GroupMediaType = (utType?.conforms(to: .movie) == true || ext == "mp4" || ext == "mov") ? .video : .image
                    
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
