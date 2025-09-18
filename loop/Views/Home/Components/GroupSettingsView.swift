import SwiftUI

struct GroupSettingsView: View {
    let group: UserGroup
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    @State private var showingMemberList = false
    @State private var showingShareCode = false
    @State private var showingLeaveConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar for sheet
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            // Title
            Text("Group Settings")
                .font(BrandFont.title2)
                .foregroundColor(BrandColor.black)
                .padding(.bottom, BrandSpacing.lg)
            
            // Menu Options
            VStack(spacing: 0) {
                // Edit group profile picture
                GroupSettingsRow(
                    icon: "camera.fill",
                    title: "Edit group profile picture",
                    action: {
                        showingImagePicker = true
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Member list
                GroupSettingsRow(
                    icon: "person.2.fill",
                    title: "Member list",
                    action: {
                        showingMemberList = true
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Share group code
                GroupSettingsRow(
                    icon: "square.and.arrow.up.fill",
                    title: "Share group code",
                    action: {
                        showingShareCode = true
                    }
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Leave group
                GroupSettingsRow(
                    icon: "person.fill.xmark",
                    title: "Leave group",
                    iconColor: .red,
                    titleColor: .red,
                    action: {
                        showingLeaveConfirmation = true
                    }
                )
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                    .stroke(Color(.systemGray5), lineWidth: 0.5)
            )
            
            Spacer()
        }
        .padding(.horizontal, BrandSpacing.lg)
        .padding(.bottom, BrandSpacing.lg)
        .sheet(isPresented: $showingImagePicker) {
            // TODO: Implement image picker for group profile
            Text("Image Picker Coming Soon")
                .font(BrandFont.body)
                .foregroundColor(BrandColor.systemGray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BrandColor.cream)
        }
        .sheet(isPresented: $showingMemberList) {
            // TODO: Implement member list view
            Text("Member List Coming Soon")
                .font(BrandFont.body)
                .foregroundColor(BrandColor.systemGray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BrandColor.cream)
        }
        .sheet(isPresented: $showingShareCode) {
            ShareCodeView(group: group)
        }
        .alert("Leave Group", isPresented: $showingLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                // TODO: Implement leave group functionality
                print("User wants to leave group: \(group.name)")
                dismiss()
            }
        } message: {
            Text("Are you sure you want to leave \"\(group.name)\"? You'll need the group code to rejoin.")
        }
    }
}

private struct GroupSettingsRow: View {
    let icon: String
    let title: String
    var iconColor: Color = BrandColor.orange
    var titleColor: Color = BrandColor.black
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: BrandSpacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 20, height: 20)
                
                // Title
                Text(title)
                    .font(BrandFont.body)
                    .foregroundColor(titleColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(.horizontal, BrandSpacing.md)
            .padding(.vertical, BrandSpacing.md)
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)
    }
}

private struct ShareCodeView: View {
    let group: UserGroup
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: BrandSpacing.xl) {
                // Group info
                VStack(spacing: BrandSpacing.md) {
                    Text("Share Group Code")
                        .font(BrandFont.title1)
                        .foregroundColor(BrandColor.black)
                    
                    Text("Share this code with friends to let them join \"\(group.name)\"")
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.systemGray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, BrandSpacing.xl)
                
                // Group code display
                VStack(spacing: BrandSpacing.md) {
                    Text("Group Code")
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                        .textCase(.uppercase)
                        .tracking(1.0)
                    
                    Text(group.groupCode)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(BrandColor.orange)
                        .tracking(8.0)
                        .padding(.horizontal, BrandSpacing.lg)
                        .padding(.vertical, BrandSpacing.md)
                        .background(BrandColor.cream)
                        .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                }
                
                // Share button
                Button {
                    // Share the group code
                    let shareText = "Join my group \"\(group.name)\" on Loop! Use code: \(group.groupCode)"
                    let activityViewController = UIActivityViewController(
                        activityItems: [shareText],
                        applicationActivities: nil
                    )
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(activityViewController, animated: true)
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Share Code")
                            .font(BrandFont.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.md)
                    .background(BrandColor.orange)
                    .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                }
                .padding(.horizontal, BrandSpacing.lg)
                
                Spacer()
            }
            .padding(.horizontal, BrandSpacing.lg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(BrandColor.orange)
                }
            }
        }
    }
}

#Preview {
    let sampleGroup = UserGroup(
        id: 1,
        name: "jones 2025",
        groupCode: "ABC123",
        avatarURL: nil,
        createdBy: UUID(),
        createdAt: Date(),
        updatedAt: Date(),
        isActive: true,
        maxMembers: 10
    )
    
    return GroupSettingsView(group: sampleGroup)
}
