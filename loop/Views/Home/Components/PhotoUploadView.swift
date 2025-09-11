import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    let selectedGroup: UserGroup
    let mediaType: GroupMediaType
    let onBack: () -> Void
    let onComplete: () -> Void
    
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingImagePicker = false
    @FocusState private var isCaptionFocused: Bool
    
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
                
                Text("New upload")
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
                // Image preview or placeholder
                VStack(spacing: BrandSpacing.md) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(BrandUI.cornerRadiusLarge)
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandUI.cornerRadiusLarge)
                                    .stroke(BrandColor.lightBrown, lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: BrandUI.cornerRadiusLarge)
                            .fill(BrandColor.lightBrown.opacity(0.1))
                            .frame(height: 300)
                            .overlay(
                                VStack(spacing: BrandSpacing.md) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 48))
                                        .foregroundColor(BrandColor.lightBrown)
                                    
                                    Text("Tap to select photo")
                                        .font(BrandFont.body)
                                        .foregroundColor(BrandColor.lightBrown)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandUI.cornerRadiusLarge)
                                    .stroke(BrandColor.lightBrown, lineWidth: 1)
                            )
                    }
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                // Caption input
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("Add a caption...")
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.lightBrown)
                    
                    TextField("", text: $caption, axis: .vertical)
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.black)
                        .focused($isCaptionFocused)
                        .padding(.horizontal, BrandSpacing.md)
                        .padding(.vertical, BrandSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                .fill(BrandColor.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                        .stroke(isCaptionFocused ? BrandColor.orange : BrandColor.lightBrown, lineWidth: 1)
                                )
                        )
                        .lineLimit(3...6)
                }
                
                // Selected group info
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("Uploading to:")
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.lightBrown)
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(BrandColor.orange)
                        Text(selectedGroup.name)
                            .font(BrandFont.body)
                            .foregroundColor(BrandColor.black)
                        Spacer()
                    }
                }
                .padding(.horizontal, BrandSpacing.md)
                .padding(.vertical, BrandSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                        .fill(BrandColor.cream)
                )
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .errorMessage()
                }
                
                Spacer()
            }
            .padding(.horizontal, BrandSpacing.lg)
            
            // Post button
            Button {
                uploadMedia()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Text("Post")
                            .font(BrandFont.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .primaryButton(isEnabled: selectedImage != nil && !isLoading)
            .disabled(selectedImage == nil || isLoading)
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.bottom, BrandSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .photosPicker(
            isPresented: $showingImagePicker,
            selection: Binding(
                get: { nil },
                set: { newValue in
                    if let newValue = newValue {
                        loadImage(from: newValue)
                    }
                }
            ),
            matching: .images
        )
    }
    
    private func loadImage(from item: PhotosPickerItem) {
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        self.selectedImage = image
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load image"
                }
            }
        }
    }
    
    private func uploadMedia() {
        guard let selectedImage = selectedImage else {
            errorMessage = "Please upload your \(mediaType.rawValue)"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // TODO: Implement actual media upload to Supabase storage
                // For now, just simulate upload
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                await MainActor.run {
                    self.isLoading = false
                    self.onComplete()
                }
                
                print("\(mediaType.rawValue.capitalized) uploaded to group: \(selectedGroup.name)")
                print("Caption: \(caption.isEmpty ? "No caption" : caption)")
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to upload \(mediaType.rawValue). Please try again."
                }
            }
        }
    }
}

#Preview {
    PhotoUploadView(
        selectedGroup: UserGroup(
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
