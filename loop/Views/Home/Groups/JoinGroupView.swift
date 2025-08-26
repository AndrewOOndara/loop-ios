import SwiftUI

struct JoinGroupView: View {
    @State private var groupCode: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @FocusState private var codeFieldFocused: Bool
    
    private let groupService = GroupService()
    
    var onNext: (UserGroup) -> Void // Changed to pass the found UserGroup
    var onBack: (() -> Void)? = nil
    
    private var isValidCode: Bool {
        groupCode.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    onBack?()
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
                // Main content - positioned in top 3/4 of screen
                VStack(spacing: BrandSpacing.xl) {
                    // Instruction
                    VStack(spacing: BrandSpacing.md) {
                        Text("Please enter the code for the group you would like to join:")
                            .font(BrandFont.title3)
                            .foregroundColor(BrandColor.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, BrandSpacing.lg)
                    }
                    .padding(.top, BrandSpacing.xl)
                    .padding(.bottom, BrandSpacing.xl)
                    
                    // Code Input Field
                    VStack(spacing: BrandSpacing.md) {
                        ZStack {
                            // Code input designed to look like your Figma
                            HStack(spacing: BrandSpacing.sm) {
                                ForEach(0..<4, id: \.self) { index in
                                    codeDigitBox(for: index)
                                }
                                .padding(.bottom, BrandSpacing.xl)
                            }
                            
                            // Hidden text field for input
                            TextField("", text: $groupCode)
                                .focused($codeFieldFocused)
                                .keyboardType(.numberPad)
                                .opacity(0)
                                .onChange(of: groupCode) { oldValue, newValue in
                                    handleCodeChange(newValue)
                                }
                        }
                        .onTapGesture {
                            codeFieldFocused = true
                        }
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .errorMessage()
                        }
                    }
                }
                .padding(.horizontal, BrandSpacing.xxxl)
                
                // Next Button - positioned closer to content
                Button {
                    verifyAndProceed()
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Next")
                                .font(BrandFont.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .primaryButton(isEnabled: isValidCode && !isLoading)
                .disabled(!isValidCode || isLoading)
                .padding(.horizontal, BrandSpacing.xxxl)
                
                Spacer() // Pushes content to top 3/4
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .onAppear {
            codeFieldFocused = true
        }
    }
    
    @ViewBuilder
    private func codeDigitBox(for index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: BrandUI.cornerRadiusLarge)
                .stroke(
                    (codeFieldFocused && index == groupCode.count) ? BrandColor.orange : BrandColor.lightBrown, 
                    lineWidth: 2
                )
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: BrandUI.cornerRadiusLarge)
                        .fill(BrandColor.white)
                )
            
            Text(getDigit(at: index))
                .font(BrandFont.title1)
                .foregroundColor(BrandColor.black)
        }
    }
    
    private func getDigit(at index: Int) -> String {
        if index < groupCode.count {
            let digitIndex = groupCode.index(groupCode.startIndex, offsetBy: index)
            return String(groupCode[digitIndex])
        }
        return ""
    }
    
    private func handleCodeChange(_ newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        if filtered.count <= 4 {
            groupCode = filtered
        } else {
            groupCode = String(filtered.prefix(4))
        }
    }
    
    private func verifyAndProceed() {
        guard isValidCode else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("[JoinGroup] Looking up group with code: \(groupCode)")
                
                // Look up the group by code
                guard let group = try await groupService.findGroup(by: groupCode) else {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Group not found. Please check the code and try again."
                    }
                    return
                }
                
                print("[JoinGroup] Found group: \(group.name)")
                
                await MainActor.run {
                    isLoading = false
                    onNext(group) // Pass the found group to confirmation screen
                }
                
            } catch {
                print("[JoinGroup] Error looking up group: \(error)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to look up group. Please try again."
                }
            }
        }
    }
}

#Preview {
    JoinGroupView(
        onNext: { group in
            print("Proceeding with group: \(group.name)")
        },
        onBack: {
            print("Back tapped")
        }
    )
}
