import SwiftUI

struct CreateGroupCodeView: View {
    let groupName: String
    let groupImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var showingShareSheet = false
    @State private var previewCode: String = ""
    
    var onNext: () -> Void
    var onBack: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    
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
                        onCancel?() // Close the entire flow - takes user back to home screen
                    }
                    .font(.system(size: 17))
                    .foregroundColor(BrandColor.orange)
                }
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.xl)
            .padding(.bottom, BrandSpacing.lg)
            
            VStack(spacing: BrandSpacing.xl) {
                // Code Section
                VStack(spacing: BrandSpacing.lg) {
                    Text("This is your group code:")
                        .font(BrandFont.title3)
                        .foregroundColor(BrandColor.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.lg)
                        .padding(.top, BrandSpacing.xl)
                    
                    // Group Code Display (Preview)
                    HStack(spacing: BrandSpacing.md) {
                        ForEach(Array(previewCode.enumerated()), id: \.offset) { index, digit in
                            Text(String(digit))
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(BrandColor.black)
                                .frame(width: 60, height: 60)
                                .background(BrandColor.white)
                                .cornerRadius(BrandUI.cornerRadiusLarge)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BrandUI.cornerRadiusLarge)
                                        .stroke(BrandColor.lightBrown, lineWidth: 2)
                                )
                        }
                    }
                }
                
                // Invite Section
                VStack(spacing: BrandSpacing.md) {
                    Text("Invite your friends!")
                        .font(BrandFont.title3)
                        .foregroundColor(BrandColor.black)
                        .multilineTextAlignment(.center)
                    
                    Text("You have up to 6 invites for this group.")
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.lightBrown)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.lg)
                }
                
                // Share Link Button
                Button {
                    shareGroupCode()
                } label: {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                        Text("Share a Link")
                            .font(BrandFont.headline)
                    }
                    .foregroundColor(BrandColor.lightBrown)
                }
                .secondaryButton(isEnabled: true)
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
                .primaryButton(isEnabled: !isLoading)
                .disabled(isLoading)
                .padding(.horizontal, BrandSpacing.lg)
                
                Spacer() // Pushes content to top 3/4
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .onAppear {
            generatePreviewCode()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateShareText()])
        }
    }
    
    private func shareGroupCode() {
        showingShareSheet = true
    }
    
    private func generatePreviewCode() {
        // Generate a preview code (4 random digits)
        previewCode = String(format: "%04d", Int.random(in: 1000...9999))
    }
    
    private func generateShareText() -> String {
        return "Join my group '\(groupName)' on Loop! Use code: \(previewCode)"
    }
    
    private func proceedToNext() {
        isLoading = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            onNext()
        }
    }
}

// Share Sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CreateGroupCodeView(
        groupName: "My Test Group",
        groupImage: nil,
        onNext: {
            print("Proceeding to pending view")
        },
        onBack: {
            print("Back tapped")
        },
        onCancel: {
            print("Cancel tapped")
        }
    )
}
