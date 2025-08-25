import SwiftUI

struct GroupOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    var onJoinGroup: () -> Void
    var onCreateGroup: () -> Void
    
    var body: some View {
        VStack(spacing: BrandSpacing.xl) {
            // Header
            VStack(spacing: BrandSpacing.md) {
                Text("Join or Create a Group")
                    .font(BrandFont.title1)
                    .foregroundColor(BrandColor.black)
                    .padding(.top, BrandSpacing.xl)
                    .padding(.top, BrandSpacing.xl)
                
                Text("Would you like to join an existing group or create a new one?")
                    .font(BrandFont.body)
                    .foregroundColor(BrandColor.lightBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.lg)
            }
            .padding(.top, BrandSpacing.xl)
            
            // Options
            VStack(spacing: BrandSpacing.lg) {
                // Join Group Option
                Button {
                    onJoinGroup()
                } label: {
                    HStack(spacing: BrandSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(BrandColor.cream)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 24))
                                .foregroundColor(BrandColor.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                            Text("Join a Group")
                                .font(BrandFont.title2)
                                .foregroundColor(BrandColor.black)
                            
                            Text("Enter a group code to join an existing group")
                                .font(BrandFont.body)
                                .foregroundColor(BrandColor.lightBrown)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(BrandColor.lightBrown)
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColor.white)
                    .cardStyle()
                }
                .buttonStyle(.plain)
                
                // Create Group Option
                Button {
                    onCreateGroup()
                } label: {
                    HStack(spacing: BrandSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(BrandColor.cream)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24))
                                .foregroundColor(BrandColor.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                            Text("Create a Group")
                                .font(BrandFont.title2)
                                .foregroundColor(BrandColor.black)
                            
                            Text("Start a new group and invite your friends")
                                .font(BrandFont.body)
                                .foregroundColor(BrandColor.lightBrown)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(BrandColor.lightBrown)
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColor.white)
                    .cardStyle()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BrandSpacing.lg)
            
            Spacer()
            
            // Cancel Button
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(BrandFont.headline)
                    .foregroundColor(BrandColor.lightBrown)
            }
            .buttonStyle(.plain)
            .padding(.bottom, BrandSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    GroupOptionsView(
        onJoinGroup: { print("Join group tapped") },
        onCreateGroup: { print("Create group tapped") }
    )
}
