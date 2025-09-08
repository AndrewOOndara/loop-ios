import SwiftUI

struct GroupModel: Identifiable, Hashable {
    let id: UUID
    let backendId: Int
    let name: String
    let lastUpload: String
    let previewImages: [String] // For now, these will be placeholder image names
}

struct GroupCard: View {
    let group: GroupModel
    var onGroupTap: () -> Void
    var onMenuTap: () -> Void
    @State private var isPressed: Bool = false
    private let groupService = GroupService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            // Group Header
            HStack {
                // Group Name with Arrow
                Button {
                    // Temporary highlight then navigate
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isPressed = false
                        onGroupTap()
                    }
                } label: {
                    HStack(spacing: BrandSpacing.xs) {
                        Text(group.name)
                            .font(BrandFont.title2)
                            .foregroundColor(isPressed ? BrandColor.orange : BrandColor.black)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isPressed ? BrandColor.orange : BrandColor.black)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Three Dots Menu
                Button {
                    onMenuTap()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(BrandColor.systemGray)
                        .rotationEffect(.degrees(90))
                }
                .buttonStyle(.plain)
            }
            
            // Last Upload Info
            Text(group.lastUpload)
                .font(BrandFont.footnote)
                .foregroundColor(BrandColor.systemGray)
            
            // Preview Images Grid (2x2)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: BrandSpacing.sm), count: 2),
                spacing: BrandSpacing.sm
            ) {
                ForEach(0..<4, id: \.self) { index in
                    if index < group.previewImages.count, let url = try? groupService.getPublicURL(for: group.previewImages[index]) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color(UIColor.systemGray5)
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Color(UIColor.systemGray5)
                            @unknown default:
                                Color(UIColor.systemGray5)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                .stroke(BrandColor.systemGray6, lineWidth: 0.5)
                        )
                    } else {
                        Rectangle()
                            .fill(BrandColor.systemGray5)
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                    .stroke(BrandColor.systemGray6, lineWidth: 0.5)
                            )
                    }
                }
            }
        }
        .padding(BrandSpacing.md)
        .cardStyle() // Apply card styling from our design system
    }
}

#Preview {
    let sampleGroup = GroupModel(
        id: UUID(),
        backendId: 1,
        name: "jones 2025",
        lastUpload: "Last upload by Sarah Luan on 7/30/2025 at 11:10 AM",
        previewImages: []
    )
    
    return GroupCard(
        group: sampleGroup,
        onGroupTap: { print("Group tapped: \(sampleGroup.name)") },
        onMenuTap: { print("Menu tapped for: \(sampleGroup.name)") }
    )
    .padding()
    .background(BrandColor.cream)
}
