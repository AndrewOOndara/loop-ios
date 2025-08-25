import SwiftUI
import PhotosUI

struct CreateGroupView: View {
    @State private var groupName: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var groupImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var onNext: (String, UIImage?) -> Void
    var onBack: (() -> Void)? = nil
    
    private var isValidGroupName: Bool {
        groupName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrandColor.black)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Create a Group")
                    .font(BrandFont.title2)
                    .foregroundColor(BrandColor.black)
                
                Spacer()
                
                Button {
                    // Cancel action - same as back
                    onBack?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrandColor.black)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.md)
            .padding(.bottom, BrandSpacing.lg)
            
            // Main content in top 3/4 of screen
            VStack(spacing: BrandSpacing.xl) {
                // Question
                Text("What's your group name?")
                    .font(BrandFont.title3)
                    .foregroundColor(BrandColor.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.xl)
                
                // Photo Upload Section
                VStack(spacing: BrandSpacing.sm) {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        VStack(spacing: BrandSpacing.sm) {
                            ZStack {
                                if let groupImage {
                                    // User selected image
                                    Image(uiImage: groupImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    // Default group logo with brand colors
                                    Circle()
                                        .fill(BrandColor.orange)
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Image(systemName: "person.3.fill")
                                                .font(.system(size: 32, weight: .semibold))
                                                .foregroundColor(.white)
                                        )
                                }
                                
                                // Camera overlay for upload hint - positioned on bottom right
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(BrandColor.black)
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                        }
                                        .offset(x: -10, y: -10)
                                    }
                                }
                                .frame(width: 120, height: 120)
                            }
                            
                            Text("Upload a group photo")
                                .font(BrandFont.body)
                                .foregroundColor(BrandColor.lightBrown)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // Group Name Input
                VStack(spacing: BrandSpacing.md) {
                    TextField("Group Name", text: $groupName)
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.black)
                        .padding(.horizontal, BrandSpacing.md)
                        .padding(.vertical, BrandSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: BrandUI.cornerRadiusExtraLarge)
                                .fill(BrandColor.white)
                                .stroke(BrandColor.lightBrown, lineWidth: 1)
                        )
                        .textInputAutocapitalization(.words)
                        .textContentType(.name)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .errorMessage()
                    }
                }
                .padding(.horizontal, BrandSpacing.lg)
                
                // Next Button
                Button {
                    createGroup()
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Next")
                                .font(BrandFont.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .primaryButton(isEnabled: isValidGroupName && !isLoading)
                .disabled(!isValidGroupName || isLoading)
                .padding(.horizontal, BrandSpacing.lg)
            }
            .padding(.top, BrandSpacing.xl)
            
            Spacer() // Pushes all content to top 3/4
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .onChange(of: selectedPhoto) { oldValue, newValue in
            loadSelectedPhoto()
        }
    }
    
    private func loadSelectedPhoto() {
        guard let selectedPhoto else { return }
        
        Task {
            do {
                if let data = try await selectedPhoto.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        self.groupImage = image
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load selected photo"
                }
            }
        }
    }
    
    private func createGroup() {
        guard isValidGroupName else { return }
        
        isLoading = true
        errorMessage = nil
        
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            
            // For demo purposes, always proceed to group code
            // In real app, this would create the group on backend
            onNext(trimmedName, groupImage)
        }
    }
}

#Preview {
    CreateGroupView(
        onNext: { name, image in
            print("Creating group: \(name)")
        },
        onBack: {
            print("Back tapped")
        }
    )
}
