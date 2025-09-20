import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct SimpleUploadView: View {
    let group: UserGroup
    let mediaType: GroupMediaType
    let onBack: () -> Void
    let onComplete: () -> Void
    
    @State private var isUploading: Bool = false
    @State private var selectedPHPickerItems: [PhotosPickerItem] = []
    @State private var errorMessage: String?
    private let groupService = GroupService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
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
                
                Text("Upload to \(group.name)")
                    .font(BrandFont.title2)
                    .foregroundColor(BrandColor.black)
                
                Spacer()
                
                // Invisible spacer for balance
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .opacity(0)
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.md)
            .padding(.bottom, BrandSpacing.lg)
            
            VStack(spacing: BrandSpacing.lg) {
                // Upload Button
                PhotosPicker(
                    selection: $selectedPHPickerItems,
                    matching: mediaType == .image ? .images : .any(of: [.images, .videos]),
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: BrandSpacing.md) {
                        if isUploading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(BrandColor.orange)
                        } else {
                            Image(systemName: mediaType == .image ? "photo" : "video")
                                .font(.system(size: 48))
                                .foregroundColor(BrandColor.orange)
                        }
                        
                        Text(isUploading ? "Uploading..." : "Tap to select \(mediaType.rawValue)")
                            .font(BrandFont.headline)
                            .foregroundColor(BrandColor.black)
                        
                        Text("Upload to \(group.name)")
                            .font(BrandFont.body)
                            .foregroundColor(BrandColor.systemGray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                            .fill(BrandColor.cream)
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                    .stroke(BrandColor.orange, lineWidth: 2, lineCap: .round, dash: [8])
                            )
                    )
                }
                .disabled(isUploading)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(BrandFont.caption1)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.horizontal, BrandSpacing.lg)
        }
        .background(BrandColor.white)
        .onChange(of: selectedPHPickerItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            Task { await handlePicked(items: newItems) }
        }
    }
    
    // MARK: - Private helpers
    private func handlePicked(items: [PhotosPickerItem]) async {
        guard let currentUser = supabase.auth.currentUser else { 
            await MainActor.run {
                errorMessage = "Please log in to upload"
            }
            return 
        }
        
        isUploading = true
        errorMessage = nil
        defer { 
            await MainActor.run {
                isUploading = false
                selectedPHPickerItems = []
            }
        }
        
        for item in items {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    // Determine type via content types / extensions
                    let utType = item.supportedContentTypes.first
                    let ext = utType?.preferredFilenameExtension?.lowercased() ?? "jpg"
                    let detectedMediaType: GroupMediaType = (utType?.conforms(to: .movie) == true || ext == "mp4" || ext == "mov") ? .video : .image
                    
                    // For videos we could generate thumbnail client-side later. For now omit.
                    let uploaded = try await groupService.uploadMedia(
                        groupId: group.id,
                        userId: currentUser.id,
                        data: data,
                        fileExtension: ext,
                        mediaType: detectedMediaType,
                        thumbnailData: nil
                    )
                    
                    print("✅ Successfully uploaded \(detectedMediaType.rawValue) to group: \(group.name)")
                    
                    // Upload successful, close the view
                    await MainActor.run {
                        onComplete()
                    }
                }
            } catch {
                print("❌ Upload failed: \(error)")
                await MainActor.run {
                    errorMessage = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    SimpleUploadView(
        group: UserGroup(
            id: 1,
            name: "Test Group",
            groupCode: "1234",
            avatarURL: nil,
            createdBy: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true,
            maxMembers: 10
        ),
        mediaType: .image,
        onBack: { print("Back tapped") },
        onComplete: { print("Upload completed") }
    )
}
