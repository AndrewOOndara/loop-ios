//
//  ProfileSetupView.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Profile setup screen for new users
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    var onComplete: (() -> Void)?
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, bio
    }
    
    private var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
                ZStack {
            BrandColor.cream.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Wordmark at the very top
                    LoopWordmark(fontSize: 64, color: BrandColor.orange)
                        .padding(.bottom, BrandSpacing.md)
                    
                    // Main content centered
                    VStack(spacing: BrandSpacing.lg) {
                        // Title
                        Text("Set up your profile!")
                            .font(BrandFont.headline)
                            .foregroundColor(BrandColor.black)
                            .padding(.bottom, BrandSpacing.md)
                    
                    // Profile Picture Section
                    VStack(spacing: BrandSpacing.sm) {
                        ZStack {
                            // Profile image or placeholder
                            if let profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                                        } else {
                                Circle()
                                    .fill(BrandColor.white)
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(BrandColor.lightBrown)
                                    )
                            }
                            
                            // Camera button
                            PhotosPicker(
                                selection: $selectedItem,
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
                        
                        Text("Add a profile picture")
                            .font(BrandFont.caption1)
                            .foregroundColor(BrandColor.lightBrown)
                    }
                    .padding(.bottom, BrandSpacing.lg)
                    
                    // Form Fields
                    VStack(spacing: BrandSpacing.md) {
                        // First Name
                        UnderlinedField(
                            title: "First Name",
                            text: $firstName,
                            isRequired: true
                        )
                        .focused($focusedField, equals: .firstName)
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                        
                        // Last Name
                        UnderlinedField(
                            title: "Last Name", 
                            text: $lastName,
                            isRequired: true
                        )
                        .focused($focusedField, equals: .lastName)
                        .textContentType(.familyName)
                        .autocapitalization(.words)
                        
                        // Bio (optional)
                        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                            HStack {
                                Text("Bio (optional)")
                                    .font(BrandFont.caption1)
                                    .foregroundColor(BrandColor.lightBrown)
                                
                                Spacer()
                                
                                Text("\(bio.count)/100")
                                    .font(BrandFont.caption2)
                                    .foregroundColor(bio.count > 100 ? BrandColor.error : BrandColor.lightBrown)
                            }
                            
                            TextField("", text: $bio, axis: .vertical)
                                .focused($focusedField, equals: .bio)
                                .foregroundColor(BrandColor.black)
                                .font(BrandFont.body)
                                .padding(.vertical, BrandSpacing.sm)
                                .onChange(of: bio) { oldValue, newValue in
                                    if newValue.count > 100 {
                                        bio = String(newValue.prefix(100))
                                    }
                                }
                            
                            Rectangle()
                                .fill(focusedField == .bio ? BrandColor.orange : BrandColor.lightBrown)
                                .frame(height: 1)
                                .animation(.easeInOut(duration: 0.2), value: focusedField == .bio)
                        }
                    }
                    .padding(.bottom, BrandSpacing.xl)
                    
                    // Error message
                    if let errorMessage {
                        Text(errorMessage)
                            .errorMessage()
                    }
                    
                    // Complete button
                    Button {
                        Task { await completeSetup() }
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("COMPLETE SETUP")
                                    .font(BrandFont.headline)
                            }
                        }
                    }
                    .primaryButton(isEnabled: isValid && !isLoading)
                    .disabled(!isValid || isLoading)
                    }
                    .padding(.horizontal, BrandSpacing.xxxl)
                }
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        profileImage = uiImage
                    }
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    
    // MARK: - Actions
    private func completeSetup() async {
        guard isValid, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Here you would typically save the profile data to your backend
        // For now, we'll just simulate a successful setup
        do {
            // Simulate API call
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // In a real app, you'd save to Supabase:
            // let profileData = [
            //     "first_name": firstName,
            //     "last_name": lastName,
            //     "bio": bio.isEmpty ? nil : bio,
            //     "avatar_url": profileImageUrl
            // ]
            // try await supabase.from("profiles").insert(profileData).execute()
            
            onComplete?()
        } catch {
            errorMessage = "Failed to set up profile. Please try again."
            #if DEBUG
            print("Profile setup error:", error.localizedDescription)
            #endif
        }
    }
}

// MARK: - UnderlinedField Component
struct UnderlinedField: View {
    let title: String
    @Binding var text: String
    let isRequired: Bool
    
    @FocusState private var isFocused: Bool
    
    init(title: String, text: Binding<String>, isRequired: Bool = false) {
        self.title = title
        self._text = text
        self.isRequired = isRequired
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
            HStack {
            Text(title)
                    .font(BrandFont.caption1)
                    .foregroundColor(BrandColor.lightBrown)
                
                if isRequired {
                    Text("*")
                        .font(BrandFont.caption1)
                        .foregroundColor(BrandColor.orange)
                }
            }
            
            TextField("", text: $text)
                .focused($isFocused)
                .foregroundColor(BrandColor.black)
                .font(BrandFont.body)
                .padding(.vertical, BrandSpacing.sm)

            Rectangle()
                .fill(isFocused ? BrandColor.orange : BrandColor.lightBrown)
                .frame(height: 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileSetupView(
        onComplete: { print("Profile setup completed") }
    )
}
