import SwiftUI

struct JoinGroupConfirmView: View {
    let groupCode: String
    @State private var isLoading: Bool = false
    
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    // Demo group data - in real app this would come from backend
    private let demoGroup = (
        name: "test group 1",
        founder: "Sarah Luan",
        memberCount: 3
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    onCancel()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrandColor.black)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Join a Group")
                    .font(BrandFont.title2)
                    .foregroundColor(BrandColor.black)
                
                Spacer()
                
                // Invisible spacer for balance
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .opacity(0)
            }
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.top, BrandSpacing.md)
            .padding(.bottom, BrandSpacing.lg)
            
            VStack(spacing: BrandSpacing.xl) {
                // Question
                Text("Is this the group you would like to join?")
                    .font(BrandFont.title3)
                    .foregroundColor(BrandColor.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.lg)
                    .padding(.top, BrandSpacing.xl)
                
                // Group Preview Card
                VStack(spacing: BrandSpacing.lg) {
                    // Group Icon
                    ZStack {
                        Circle()
                            .fill(BrandColor.cream)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 32))
                            .foregroundColor(BrandColor.orange)
                    }
                    
                    // Group Info
                    VStack(spacing: BrandSpacing.sm) {
                        Text(demoGroup.name)
                            .font(BrandFont.title2)
                            .foregroundColor(BrandColor.black)
                        
                        Text("Founded by \(demoGroup.founder)")
                            .font(BrandFont.body)
                            .foregroundColor(BrandColor.lightBrown)
                        
                        Text("\(demoGroup.memberCount) members")
                            .font(BrandFont.caption1)
                            .foregroundColor(BrandColor.lightBrown)
                    }
                }
                .padding(BrandSpacing.xl)
                .background(BrandColor.white)
                .cardStyle()
                .padding(.horizontal, BrandSpacing.lg)
                
                // Action Buttons - positioned closer to content
                HStack(spacing: BrandSpacing.md) {
                    // No Button
                    Button {
                        onCancel()
                    } label: {
                        Text("No")
                            .font(BrandFont.headline)
                            .foregroundColor(BrandColor.lightBrown)
                    }
                    .secondaryButton(isEnabled: !isLoading)
                    .disabled(isLoading)
                    
                    // Yes Button
                    Button {
                        joinGroup()
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Yes")
                                    .font(BrandFont.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .primaryButton(isEnabled: !isLoading)
                    .disabled(isLoading)
                }
                .padding(.horizontal, BrandSpacing.lg)
                
                Spacer() // Pushes content to top 3/4
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
    }
    
    private func joinGroup() {
        isLoading = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            onConfirm()
        }
    }
}

#Preview {
    JoinGroupConfirmView(
        groupCode: "1234",
        onConfirm: { print("Group joined!") },
        onCancel: { print("Cancelled") }
    )
}
