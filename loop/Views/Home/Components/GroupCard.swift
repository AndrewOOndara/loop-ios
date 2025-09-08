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
            
            // Subtitle: show lastUpload if provided; otherwise show empty-state only when no previews
            Group {
                if !group.lastUpload.isEmpty {
                    Text(group.lastUpload)
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                } else if group.previewImages.isEmpty {
                    Text("No uploads yet")
                        .font(BrandFont.footnote)
                        .foregroundColor(BrandColor.systemGray)
                }
            }
            
            // Preview Images Grid (2x2)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: BrandSpacing.sm), count: 2),
                spacing: BrandSpacing.sm
            ) {
                ForEach(0..<4, id: \.self) { index in
                    if index < group.previewImages.count, let url = try? groupService.getPublicURL(for: group.previewImages[index]) {
                        PreviewTile(url: url)
                    } else {
                        PreviewTile(url: nil)
                    }
                }
            }
        }
        .padding(BrandSpacing.md)
        .cardStyle() // Apply card styling from our design system
    }
}

private struct PreviewTile: View {
    let url: URL?
    
    var body: some View {
        ZStack {
            // Persistent placeholder to avoid height collapse
            Rectangle()
                .fill(BrandColor.systemGray5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.clear
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    case .failure:
                        Color.clear
                    @unknown default:
                        Color.clear
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: BrandUI.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                .stroke(BrandColor.systemGray6, lineWidth: 0.5)
        )
    }
}

#Preview {
    let sampleGroup = GroupModel(
        id: UUID(),
        backendId: 1,
        name: "jones 2025",
        lastUpload: "",
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
