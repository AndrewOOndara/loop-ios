import SwiftUI
import PhotosUI

struct CaptionInputView: View {
    let group: UserGroup
    let mediaType: GroupMediaType
    let selectedMedia: [PhotosPickerItem]
    let onBack: () -> Void
    let onComplete: () -> Void
    
    @State private var caption: String = ""
    @State private var isUploading: Bool = false
    @State private var errorMessage: String?
    @State private var uploadedMedia: [GroupMedia] = []
    @State private var selectedPHPickerItems: [PhotosPickerItem] = []
    @State private var selectedImageData: Data?
    @State private var showingMediaRequiredAlert: Bool = false
    
    private let groupService = GroupService()
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            contentView
        }
        .background(BrandColor.cream)
        .onAppear {
            // Initialize with passed selectedMedia
            selectedPHPickerItems = selectedMedia
            Task {
                await loadMediaPreview()
            }
        }
        .onChange(of: selectedPHPickerItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            Task { await loadMediaPreview() }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button {
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(BrandColor.black)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("New upload")
                .font(BrandFont.title2)
                .foregroundColor(BrandColor.black)
            
            Spacer()
            
            Button {
                // Cancel button - go back to home screen
                onComplete()
            } label: {
                Text("Cancel")
                    .font(BrandFont.body)
                    .foregroundColor(BrandColor.lightBrown)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BrandSpacing.lg)
        .padding(.top, BrandSpacing.lg)
        .padding(.bottom, BrandSpacing.md)
    }
    
    private var contentView: some View {
        VStack(spacing: BrandSpacing.lg) {
            // Media preview placeholder
            mediaPreviewView
            
            // Caption input field
            captionInputField
            
            Spacer()
            
            // Post button
            postButton
        }
        .padding(.horizontal, BrandSpacing.lg)
        .padding(.bottom, BrandSpacing.xl)
    }
    
    private var mediaPreviewView: some View {
        VStack {
            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                // Show actual image with proper aspect ratio
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(BrandUI.cornerRadius)
                    .clipped()
                    .background(
                        RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                            .fill(BrandColor.cream)
                    )
                    .overlay(
                        PhotosPicker(
                            selection: $selectedPHPickerItems,
                            maxSelectionCount: 1,
                            matching: mediaType == .image ? .images : .videos
                        ) {
                            RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                .fill(Color.clear)
                        }
                    )
            } else {
                // Show placeholder with white background
                RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                    .fill(BrandColor.white)
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: mediaType.iconName)
                                .font(.system(size: 40, weight: .regular))
                                .foregroundColor(BrandColor.lightBrown)
                            Text("Select Media")
                                .font(BrandFont.body)
                                .foregroundColor(BrandColor.lightBrown)
                        }
                    )
                    .overlay(
                        PhotosPicker(
                            selection: $selectedPHPickerItems,
                            maxSelectionCount: 1,
                            matching: mediaType == .image ? .images : .videos
                        ) {
                            RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                .fill(Color.clear)
                                .frame(height: 300)
                        }
                    )
            }
        }
        .padding(.horizontal, BrandSpacing.md)
    }
    
    private var captionInputField: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            Text("Caption")
                .font(BrandFont.headline)
                .foregroundColor(BrandColor.black)
            
            ZStack(alignment: .topLeading) {
                if caption.isEmpty {
                    Text("Add a caption")
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.lightBrown)
                        .padding(.horizontal, BrandSpacing.md)
                        .padding(.vertical, BrandSpacing.md)
                        .allowsHitTesting(false)
                }
                
                TextField("", text: $caption, axis: .vertical)
                    .font(BrandFont.body)
                    .foregroundColor(BrandColor.black)
                    .padding(BrandSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                            .fill(BrandColor.cream)
                            .stroke(BrandColor.lightBrown, lineWidth: 1)
                    )
                    .lineLimit(4...8)
                    .textFieldStyle(.plain)
            }
        }
    }
    
    private var postButton: some View {
        Button {
            // Check if media is selected
            if selectedPHPickerItems.isEmpty {
                showingMediaRequiredAlert = true
                return
            }
            
            Task {
                await uploadMedia()
            }
        } label: {
            Text(isUploading ? "Posting..." : "Post")
                .font(BrandFont.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: BrandUI.cornerRadiusExtraLarge)
                        .fill(isUploading ? BrandColor.systemGray3 : BrandColor.orange)
                )
        }
        .disabled(isUploading)
        .buttonStyle(.plain)
        .alert("Media Required", isPresented: $showingMediaRequiredAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select media before posting. You cannot post without a media upload.")
        }
    }
    
    // MARK: - Private helpers
    
    private func loadMediaPreview() async {
        guard let item = selectedPHPickerItems.first else {
            await MainActor.run {
                selectedImageData = nil
            }
            return
        }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    selectedImageData = data
                }
            }
        } catch {
            print("❌ Failed to load media preview: \(error)")
            await MainActor.run {
                selectedImageData = nil
            }
        }
    }
    
    private func uploadMedia() async {
        guard let currentUser = supabase.auth.currentUser else {
            await MainActor.run {
                errorMessage = "Please log in to upload"
            }
            return
        }
        
        isUploading = true
        errorMessage = nil
        defer { 
            isUploading = false
        }
        
        for item in selectedPHPickerItems {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    // Determine type via content types / extensions
                    let utType = item.supportedContentTypes.first
                    let ext = utType?.preferredFilenameExtension?.lowercased() ?? "jpg"
                    let detectedMediaType: GroupMediaType = (utType?.conforms(to: .movie) == true || ext == "mp4" || ext == "mov") ? .video : .image
                    
                    // Upload with caption
                    let uploadedMedia = try await groupService.uploadMedia(
                        groupId: group.id,
                        userId: currentUser.id,
                        data: data,
                        fileExtension: ext,
                        mediaType: detectedMediaType,
                        caption: caption.isEmpty ? nil : caption,
                        thumbnailData: nil
                    )
                    
                    print("✅ Successfully uploaded \(detectedMediaType.rawValue) with caption to group: \(group.name) - Media ID: \(uploadedMedia.id)")
                    
                    await MainActor.run {
                        self.uploadedMedia.append(uploadedMedia)
                    }
                }
            } catch {
                print("❌ Upload failed: \(error)")
                await MainActor.run {
                    errorMessage = "Upload failed: \(error.localizedDescription)"
                }
                return
            }
        }
        
        // All uploads successful, close the view
        await MainActor.run {
            onComplete()
        }
    }
}

// MARK: - GroupMediaType Extension
extension GroupMediaType {
    var iconName: String {
        switch self {
        case .image:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "music.note"
        case .music:
            return "music.note.list"
        }
    }
}

#Preview {
    CaptionInputView(
        group: UserGroup(
            id: 1,
            name: "Test Group",
            groupCode: "ABC123",
            avatarURL: nil,
            createdBy: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true,
            maxMembers: 50
        ),
        mediaType: .image,
        selectedMedia: [],
        onBack: {},
        onComplete: {}
    )
}
