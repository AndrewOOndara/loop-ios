import SwiftUI
import PhotosUI

struct CreateGroupView: View {
    @State private var groupName: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var groupImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let groupService = GroupService()
    
    var onNext: (String, UIImage?) -> Void // Pass group name and image, not created group
    var onBack: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    
    private var isValidGroupName: Bool {
        groupName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with properly aligned Cancel button
            ZStack {
                // Centered title
                HStack {
                    Spacer()
                    Text("Create a Group")
                        .font(BrandFont.title2)
                        .foregroundColor(BrandColor.black)
                    Spacer()
                }
                
                // Right-aligned Cancel button
                HStack {
                    Spacer()
                    Button("Cancel") {
                        // Cancel takes user back to home screen
                        onCancel?()
                    }
                    .font(.system(size: 17))
                    .foregroundColor(BrandColor.orange)
                }
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.xl)
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
                    ZStack {
                        // Group image or placeholder - matching ProfileSetupView style
                        if let groupImage {
                            Image(uiImage: groupImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(BrandColor.white)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(BrandColor.lightBrown)
                                )
                        }
                        
                        // Camera button - matching ProfileSetupView style
                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                Circle()
                                    .fill(BrandColor.orange)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(x: 40, y: 40)
                    }
                    
                    Text("Upload a group photo")
                        .font(BrandFont.caption1)
                        .foregroundColor(BrandColor.lightBrown)
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
                    proceedToNext()
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
    
    private func proceedToNext() {
        guard isValidGroupName else { return }
        
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        print("[CreateGroup] Proceeding with group name: \(trimmedName)")
        
        // Just pass the name and image to next screen - don't create group yet
        onNext(trimmedName, groupImage)
    }
}

#Preview {
    CreateGroupView(
        onNext: { name, image in
            print("Proceeding with group name: \(name)")
        },
        onBack: {
            print("Back tapped")
        },
        onCancel: {
            print("Cancel tapped")
        }
    )
}
