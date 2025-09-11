import SwiftUI

struct DebugUploadView: View {
    let selectedGroup: UserGroup?
    let mediaType: GroupMediaType
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Debug Info")
                .font(.title)
                .padding()
            
            Text("selectedGroupForUpload: \(selectedGroup?.name ?? "nil")")
                .foregroundColor(.red)
            
            Text("selectedMediaType: \(mediaType.rawValue)")
                .foregroundColor(.blue)
            
            if let group = selectedGroup {
                VStack {
                    Text("Group Details:")
                    Text("ID: \(group.id)")
                    Text("Name: \(group.name)")
                    Text("Code: \(group.groupCode)")
                    Text("Max Members: \(group.maxMembers)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button("Test Photo Upload") {
                    print("🎯 Test button tapped with group: \(group.name)")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("No group selected - this is the problem!")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            
            Button("Close") {
                onClose()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            print("🎯 DebugUploadView appeared")
            print("🎯 selectedGroup: \(selectedGroup?.name ?? "nil")")
        }
    }
}

#Preview {
    DebugUploadView(
        selectedGroup: UserGroup(
            id: 1,
            name: "Test Group",
            groupCode: "1234",
            avatarURL: nil,
            createdBy: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true,
            maxMembers: 10
        ),
        mediaType: .image,
        onClose: { print("Close tapped") }
    )
}
