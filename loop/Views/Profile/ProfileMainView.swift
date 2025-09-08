import PhotosUI
import Storage
import Supabase
import SwiftUI

struct ProfileMainView: View {
    @State var username = "Sarah Luan"
    @State var joinedDate = "joined May 2025"
    @State var bio = ""
    @ObservedObject private var authManager = AuthManager.shared
    @State private var showingSettings = false
    
    @State var imageSelection: PhotosPickerItem?
    @State var avatarImage: AvatarImage?
    
    // Stats data
    @State private var activeLoops = 5
    @State private var mostActiveGroup = "jones 2025"
    @State private var weekUploadStreak = 3
    @State private var topMedia = "audio addict"
    
    var body: some View {
        ScrollView {
            VStack(spacing: BrandSpacing.xl) {
                // Header with settings button
                HStack {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(BrandColor.lightBrown)
                    }
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.top, BrandSpacing.sm)
                
                // Profile Info Section
                VStack(spacing: BrandSpacing.lg) {
                    // Profile Image
                    VStack(spacing: BrandSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(BrandColor.white)
                                .frame(width: 120, height: 120)
                            
                            if let avatarImage {
                                avatarImage.image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 116, height: 116)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(BrandColor.lightBrown)
                            }
                        }
                        
                        // Name and join date
                        VStack(spacing: BrandSpacing.xs) {
                            Text(username)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(joinedDate)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        // Bio section
                        VStack(spacing: BrandSpacing.sm) {
                            if bio.isEmpty {
                                Button {
                                    showingSettings = true
                                } label: {
                                    Text("Add bio")
                                        .font(.system(size: 16))
                                        .foregroundColor(BrandColor.orange)
                                }
                            } else {
                                Text(bio)
                                    .font(.system(size: 16))
                                    .foregroundColor(BrandColor.lightBrown)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, BrandSpacing.lg)
                            }
                        }
                    }
                }
                .padding(.horizontal, BrandSpacing.lg)
                
                // My Stats Section
                VStack(spacing: BrandSpacing.lg) {
                    HStack {
                        Text("My Stats")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                    
                    // Stats Grid - All cards using cream color
                    VStack(spacing: BrandSpacing.md) {
                        HStack(spacing: BrandSpacing.md) {
                            StatCard(
                                number: "\(activeLoops)",
                                label: "active loops",
                                color: BrandColor.cream
                            )
                            
                            StatCard(
                                number: mostActiveGroup,
                                label: "most active",
                                color: BrandColor.cream
                            )
                        }
                        
                        HStack(spacing: BrandSpacing.md) {
                            StatCard(
                                number: "\(weekUploadStreak)",
                                label: "week upload streak",
                                color: BrandColor.cream
                            )
                            
                            StatCard(
                                number: topMedia,
                                label: "top media of the week",
                                color: BrandColor.cream
                            )
                        }
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                }
                
                // Share Profile Button
                Button {
                    shareProfile()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Share Profile")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(BrandColor.orange)
                    .cornerRadius(25)
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.bottom, 100) // Space for navigation bar
            }
        }
        .background(BrandColor.white.ignoresSafeArea())
        .onAppear {
            Task {
                await getInitialProfile()
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            print("🟡 ProfileMainView: Auth state changed to: \(isAuthenticated)")
            if !isAuthenticated {
                print("🟡 User is no longer authenticated, should redirect to login")
            }
        }
        .onChange(of: imageSelection) { _, newValue in
            guard let newValue else { return }
            loadTransferable(from: newValue)
        }
        .sheet(isPresented: $showingSettings) {
            ProfileSettingsView(
                username: $username,
                bio: $bio,
                avatarImage: $avatarImage,
                imageSelection: $imageSelection
            )
        }
    }
    
    // MARK: - Profile Data Functions
    func getInitialProfile() async {
        // Check if user is authenticated first
        guard let currentUser = supabase.auth.currentUser else {
            print("No authenticated user found")
            return
        }
        
        do {
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            await MainActor.run {
                username = "\(profile.firstName ?? "") \(profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
                bio = profile.profileBio ?? ""
                
                // Format join date
                if let createdAt = profile.createdAt {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMMM yyyy"
                    joinedDate = "joined \(formatter.string(from: createdAt))"
                }
            }
            
            if let avatarURL = profile.avatarURL, !avatarURL.isEmpty {
                try await downloadImage(path: avatarURL)
            }
        } catch {
            print("Error loading profile: \(error)")
            // Don't crash the app, just use default values
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func downloadImage(path: String) async throws {
        let data = try await supabase.storage.from("avatars").download(path: path)
        avatarImage = AvatarImage(data: data)
    }
    
    private func shareProfile() {
        print("Share profile tapped")
        HapticManager.impact(.light)
        
        // Create share content
        let profileText = createShareText()
        
        // Present iOS share sheet
        let activityViewController = UIActivityViewController(
            activityItems: [profileText],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, 
                                      y: UIScreen.main.bounds.height / 2, 
                                      width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    private func createShareText() -> String {
        var shareText = "Check out my Loop profile! 📱\n\n"
        shareText += "👤 \(username)\n"
        
        if !bio.isEmpty {
            shareText += "📝 \(bio)\n"
        }
        
        shareText += "📅 \(joinedDate)\n\n"
        shareText += "📊 My Stats:\n"
        shareText += "• \(activeLoops) active loops\n"
        shareText += "• Most active in: \(mostActiveGroup)\n"
        shareText += "• \(weekUploadStreak) week upload streak\n"
        shareText += "• Top media: \(topMedia)\n\n"
        shareText += "Join Loop to connect with friends! 🔄"
        
        return shareText
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let number: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: BrandSpacing.sm) {
            Text(number)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(BrandColor.lightBrown)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(color)
        .cornerRadius(12)
    }
}

#Preview {
    ProfileMainView()
}
