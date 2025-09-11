import SwiftUI

struct UploadOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    let onDismiss: () -> Void
    let onPhotoTap: () -> Void
    let onVideoTap: () -> Void
    let onAudioTap: () -> Void
    let onMusicTap: () -> Void
    
    var body: some View {
        VStack(spacing: BrandSpacing.xl) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(BrandColor.lightBrown)
                .frame(width: 40, height: 4)
                .padding(.top, BrandSpacing.sm)
            
            // Header
            VStack(spacing: BrandSpacing.md) {
                Text("Upload Media")
                    .font(BrandFont.title1)
                    .foregroundColor(BrandColor.black)
                    .padding(.top, BrandSpacing.xl)
                
                Text("Upload photos, videos, audio, or music!")
                    .font(BrandFont.body)
                    .foregroundColor(BrandColor.lightBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.lg)
            }
            .padding(.top, BrandSpacing.xl)
            
            
            // Media type selection
            VStack(spacing: BrandSpacing.lg) {
                // 2x2 Grid of media options
                VStack(spacing: BrandSpacing.lg) {
                    // First row: Photo and Video
                    HStack(spacing: BrandSpacing.xl) {
                        MediaTypeButton(
                            icon: "camera.fill",
                            title: "Photo",
                            color: BrandColor.orange,
                            action: onPhotoTap
                        )
                        
                        MediaTypeButton(
                            icon: "video.fill",
                            title: "Video", 
                            color: BrandColor.orange,
                            action: onVideoTap
                        )
                    }
                    
                    // Second row: Audio and Music
                    HStack(spacing: BrandSpacing.xl) {
                        MediaTypeButton(
                            icon: "mic.fill",
                            title: "Audio",
                            color: BrandColor.orange,
                            action: onAudioTap
                        )
                        
                        MediaTypeButton(
                            icon: "music.note",
                            title: "Music",
                            color: BrandColor.orange,
                            action: onMusicTap
                        )
                    }
                }
                .padding(.horizontal, BrandSpacing.xxxl)
                .padding(.bottom, BrandSpacing.xl)
                .padding(.bottom, BrandSpacing.xl)
                .padding(.bottom, BrandSpacing.xl)
            }
            
            Spacer() // Push content to center
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct MediaTypeButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            HapticManager.impact(.medium)
            action()
        } label: {
            VStack(spacing: BrandSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: BrandUI.cornerRadiusLarge)
                        .fill(BrandColor.lightBrown.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(BrandFont.body)
                    .foregroundColor(BrandColor.black)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    UploadOptionsView(
        onDismiss: { print("Dismiss") },
        onPhotoTap: { print("Photo tapped") },
        onVideoTap: { print("Video tapped") },
        onAudioTap: { print("Audio tapped") },
        onMusicTap: { print("Music tapped") }
    )
}
