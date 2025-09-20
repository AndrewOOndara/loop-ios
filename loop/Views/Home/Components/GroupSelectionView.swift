import SwiftUI

struct GroupSelectionView: View {
    let onBack: () -> Void
    let onNext: (UserGroup) -> Void
    
    @State private var groups: [UserGroup] = []
    @State private var selectedGroup: Int? = nil
    @State private var isLoading = true
    @State private var searchText = ""
    
    private let groupService = GroupService()
    
    var filteredGroups: [UserGroup] {
        if searchText.isEmpty {
            return groups
        } else {
            return groups.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrandColor.black)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Add to group")
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
            
            VStack(spacing: BrandSpacing.lg) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(BrandColor.lightBrown)
                        .padding(.leading, BrandSpacing.md)
                    
                    TextField("Search groups...", text: $searchText)
                        .font(BrandFont.body)
                        .foregroundColor(BrandColor.black)
                        .padding(.vertical, BrandSpacing.md)
                        .padding(.trailing, BrandSpacing.md)
                }
                .background(
                    RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                        .fill(BrandColor.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                                .stroke(BrandColor.lightBrown, lineWidth: 1)
                        )
                )
                .padding(.horizontal, BrandSpacing.lg)
                
                // Groups list
                if isLoading {
                    VStack(spacing: BrandSpacing.lg) {
                        ProgressView()
                            .tint(BrandColor.orange)
                        Text("Loading groups...")
                            .font(BrandFont.body)
                            .foregroundColor(BrandColor.lightBrown)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else if filteredGroups.isEmpty {
                    VStack(spacing: BrandSpacing.lg) {
                        Image(systemName: "person.2.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(BrandColor.lightBrown)
                        
                        Text("No groups found")
                            .font(BrandFont.title3)
                            .foregroundColor(BrandColor.black)
                        
                        Text(searchText.isEmpty ? "You're not in any groups yet" : "No groups match your search")
                            .font(BrandFont.body)
                            .foregroundColor(BrandColor.lightBrown)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    ScrollView {
                        LazyVStack(spacing: BrandSpacing.sm) {
                            ForEach(filteredGroups) { group in
                                GroupSelectionRow(
                                    group: group,
                                    isSelected: selectedGroup == group.id,
                                    onTap: {
                                        print("🎯 GroupSelectionView: Group tapped: \(group.name) (ID: \(group.id))")
                                        selectedGroup = group.id
                                        print("🎯 GroupSelectionView: selectedGroup set to: \(selectedGroup ?? -1)")
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, BrandSpacing.lg)
                    }
                }
                
                Spacer()
            }
            
            // Next button
            Button {
                if let selectedId = selectedGroup,
                   let selected = groups.first(where: { $0.id == selectedId }) {
                    print("🎯 GroupSelectionView: Calling onNext with group: \(selected.name)")
                    onNext(selected)
                } else {
                    print("🚨 GroupSelectionView: No group selected or group not found!")
                    print("🚨 selectedGroup: \(selectedGroup ?? -1)")
                    print("🚨 groups count: \(groups.count)")
                }
            } label: {
                Text("Next")
                    .font(BrandFont.headline)
                    .foregroundColor(.white)
            }
            .primaryButton(isEnabled: selectedGroup != nil)
            .disabled(selectedGroup == nil)
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.bottom, BrandSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColor.cream)
        .onAppear {
            loadUserGroups()
        }
    }
    
    
    private func loadUserGroups() {
        guard let currentUser = supabase.auth.currentUser else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let userGroups = try await groupService.getUserGroups(userId: currentUser.id)
                await MainActor.run {
                    self.groups = userGroups
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Error loading groups: \(error)")
                }
            }
        }
    }
}

struct GroupSelectionRow: View {
    let group: UserGroup
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: BrandSpacing.md) {
                VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                    Text(group.name)
                        .font(BrandFont.headline)
                        .foregroundColor(BrandColor.black)
                    
                    Text("\(group.maxMembers) max members")
                        .font(BrandFont.caption1)
                        .foregroundColor(BrandColor.lightBrown)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(BrandColor.lightBrown, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(BrandColor.orange)
                            .frame(width: 16, height: 16)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.vertical, BrandSpacing.md)
            .padding(.horizontal, BrandSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: BrandUI.cornerRadius)
                    .fill(BrandColor.white)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GroupSelectionView(
        onBack: { print("Back tapped") },
        onNext: { group in
            print("Selected group: \(group.name)")
        }
    )
}
