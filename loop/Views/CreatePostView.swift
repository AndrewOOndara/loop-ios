import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(BrandColor.orange)
                    
                    Spacer()
                    
                    Text("Create Post")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Share") {
                        sharePost()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                    .disabled(postText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(.separator)),
                    alignment: .bottom
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Text input section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Add a note")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            TextField("What's happening?", text: $postText, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .lineLimit(5...10)
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func sharePost() {
        // Handle posting logic here
        print("Sharing post with text: \(postText)")
        dismiss()
    }
}

#Preview {
    CreatePostView()
}
