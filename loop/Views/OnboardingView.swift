//
//  OnboardingView.swift
//  loop
//
//  Created by Andrew Ondara on 7/20/25.
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var username = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var showImagePicker = false
    
    let totalPages = 5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    // Progress indicator
                    HStack {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index <= currentPage ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        WelcomePage()
                            .tag(0)
                        
                        FeaturesPage()
                            .tag(1)
                        
                        CollageDetailPage()
                            .tag(2)
                        
                        ProfileSetupPage(
                            username: $username,
                            selectedItem: $selectedItem,
                            profileImage: $profileImage
                        )
                        .tag(3)
                        
                        CompletePage()
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if currentPage < totalPages - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                // Complete onboarding
                                completeOnboarding()
                            }
                        }) {
                            Text(currentPage == totalPages - 1 ? "Get Started" : "Continue")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(canProceed() ? Color.orange : Color.gray)
                                .cornerRadius(25)
                        }
                        .disabled(!canProceed())
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func canProceed() -> Bool {
        switch currentPage {
        case 3: // Profile setup page
            return username.count >= 3
        default:
            return true
        }
    }
    
    private func completeOnboarding() {
        // Handle onboarding completion
        print("Onboarding completed with username: \(username)")
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.pink]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 96, height: 96)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("L")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text("Welcome to Loop")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Stay connected with friends through\nshared moments and memories")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Features Page
struct FeaturesPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("What you can do")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                FeatureCard(
                    icon: "grid",
                    title: "Create Collages",
                    description: "Combine photos, videos, and messages",
                    backgroundColor: Color.blue.opacity(0.1),
                    iconColor: Color.blue
                )
                
                FeatureCard(
                    icon: "person.2.fill",
                    title: "Friend Groups",
                    description: "Organize different circles of friends",
                    backgroundColor: Color.green.opacity(0.1),
                    iconColor: Color.green
                )
                
                FeatureCard(
                    icon: "message.fill",
                    title: "Stay Updated",
                    description: "Keep up with friends' latest moments",
                    backgroundColor: Color.purple.opacity(0.1),
                    iconColor: Color.purple
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let backgroundColor: Color
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

// MARK: - Collage Detail Page
struct CollageDetailPage: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("Keep Up")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            // Mock collage grid
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.3))
                        .frame(height: 80)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.3))
                        .frame(height: 80)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 80)
                        
                        Text("😊")
                            .font(.system(size: 30))
                    }
                }
                
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.3))
                            .frame(height: 60)
                        
                        Text("Let's go\nto the\nbeach!")
                            .font(.system(size: 10, weight: .semibold))
                            .multilineTextAlignment(.center)
                    }
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.3))
                        .frame(height: 60)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.3))
                        .frame(height: 60)
                }
            }
            .padding(.horizontal, 40)
            
            VStack(spacing: 16) {
                Text("keep up with friends by sending different media formats that self organize into a collage over time")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Profile Setup Page
struct ProfileSetupPage: View {
    @Binding var username: String
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var profileImage: Image?
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Create Your Profile")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            // Profile picture section
            VStack(spacing: 20) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    ZStack {
                        if let profileImage = profileImage {
                            profileImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        Circle()
                            .stroke(Color.orange, lineWidth: 3)
                            .frame(width: 124, height: 124)
                    }
                }
                .onChange(of: selectedItem) { oldItem, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                profileImage = Image(uiImage: uiImage)
                            }
                        }
                    }
                }
                
                Text("Add Profile Photo")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Username section
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                TextField("Enter username", text: $username)
                    .font(.system(size: 16))
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(username.count >= 3 ? Color.orange : Color.clear, lineWidth: 2)
                    )
                
                Text("Minimum 3 characters")
                    .font(.system(size: 12))
                    .foregroundColor(username.count >= 3 ? .green : .secondary)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Complete Page
struct CompletePage: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 16) {
                Text("You're All Set!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Start connecting with friends and\ncreating amazing memories together")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // Feature preview cards
            VStack(spacing: 12) {
                Text("Coming up next:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        Text("Add Friends")
                            .font(.system(size: 12, weight: .medium))
                    }
                    
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        Text("Share Moments")
                            .font(.system(size: 12, weight: .medium))
                    }
                    
                    VStack {
                        Image(systemName: "grid")
                            .font(.system(size: 24))
                            .foregroundColor(.purple)
                        Text("Create Collages")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .foregroundColor(.primary)
            }
            .padding(.bottom, 20)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    OnboardingView()
}
