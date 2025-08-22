import SwiftUI

struct GroupDetailView: View {
    let group: GroupModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and group name
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(BrandColor.black)
                    }
                    .buttonStyle(.plain)
                    
                    Text(group.name)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColor.black)
                    
                    Spacer()
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.top, BrandSpacing.md)
                .padding(.bottom, BrandSpacing.lg)
                
                // Week information section
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    HStack {
                        Text("This week's collage")
                            .font(BrandFont.headline)
                            .foregroundColor(BrandColor.black)
                        
                        Text("(7/28 - 8/3)")
                            .font(BrandFont.subheadline)
                            .foregroundColor(BrandColor.orange)
                    }
                    
                    Text(group.lastUpload)
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.bottom, BrandSpacing.xl)
                
                // Collage grid
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: BrandSpacing.sm) {
                        // Large horizontal rectangle at top
                        Rectangle()
                            .fill(BrandColor.systemGray5)
                            .aspectRatio(2.5, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                        
                        // Middle section with tall rectangle and two small ones
                        HStack(spacing: BrandSpacing.sm) {
                            // Tall vertical rectangle on left
                            Rectangle()
                                .fill(BrandColor.systemGray5)
                                .aspectRatio(0.6, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                            
                            // Two smaller horizontal rectangles on right
                            VStack(spacing: BrandSpacing.sm) {
                                Rectangle()
                                    .fill(BrandColor.systemGray5)
                                    .aspectRatio(1.5, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                                
                                Rectangle()
                                    .fill(BrandColor.systemGray5)
                                    .aspectRatio(1.5, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                            }
                        }
                        
                        // Two medium horizontal rectangles
                        HStack(spacing: BrandSpacing.sm) {
                            Rectangle()
                                .fill(BrandColor.systemGray5)
                                .aspectRatio(1.8, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                            
                            Rectangle()
                                .fill(BrandColor.systemGray5)
                                .aspectRatio(1.8, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                        }
                        
                        // Large horizontal rectangle at bottom
                        Rectangle()
                            .fill(BrandColor.systemGray5)
                            .aspectRatio(2.5, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                    }
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.bottom, 100) // Space for navigation bar
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    let sampleGroup = GroupModel(
        id: UUID(),
        name: "jones 2025",
        lastUpload: "Last upload by Sarah Luan on 7/30/2025 at 11:10 AM",
        previewImages: ["photo1", "photo2", "photo3", "photo4"]
    )
    
    return GroupDetailView(group: sampleGroup)
}
