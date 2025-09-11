//
//  MainContentView.swift
//  loop
//
//  Created by Andrew Ondara on 8/26/25.
//

import SwiftUI

struct MainContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var navigationPath: [AuthRoute] = []
    
    var body: some View {
        Group {
            if authManager.isLoading {
                LoadingView()
            } else if authManager.isAuthenticated {
                NavigationStack(path: $navigationPath) {
                    HomeView(navigationPath: $navigationPath)
                        .navigationDestination(for: AuthRoute.self) { route in
                            switch route {
                            case .groupDetail(let group):
                                GroupDetailView(group: group)
                            case .notifications:
                                NotificationView()
                            case .joinGroup:
                                JoinGroupView(
                                    onNext: { group in
                                        navigationPath.append(.joinGroupConfirm(group: group))
                                    },
                                    onBack: {
                                        if !navigationPath.isEmpty {
                                            navigationPath.removeLast()
                                        }
                                    }
                                )
                            case .joinGroupConfirm(let group):
                                JoinGroupConfirmView(
                                    group: group,
                                    onConfirm: {
                                        navigationPath.append(.joinGroupSuccess)
                                    },
                                    onCancel: {
                                        if !navigationPath.isEmpty {
                                            navigationPath.removeLast()
                                        }
                                    }
                                )
                            case .joinGroupSuccess:
                                JoinGroupSuccessView {
                                    // Go back to home (clear all group-related navigation)
                                    navigationPath.removeAll { route in
                                        switch route {
                                        case .joinGroup, .joinGroupConfirm, .joinGroupSuccess:
                                            return true
                                        default:
                                            return false
                                        }
                                    }
                                }
                            case .createGroup:
                                CreateGroupView(
                                    onNext: { group, image in
                                        navigationPath.append(.createGroupCode(group: group, groupImage: image))
                                    },
                                    onBack: {
                                        if !navigationPath.isEmpty {
                                            navigationPath.removeLast()
                                        }
                                    }
                                )
                            case .createGroupCode(let group, let image):
                                CreateGroupCodeView(
                                    group: group,
                                    groupImage: image,
                                    onNext: {
                                        navigationPath.append(.createGroupPending(group: group, groupImage: image))
                                    },
                                    onBack: {
                                        if !navigationPath.isEmpty {
                                            navigationPath.removeLast()
                                        }
                                    }
                                )
                            case .createGroupPending(let group, let image):
                                CreateGroupPendingView(
                                    group: group,
                                    groupImage: image,
                                    onDone: {
                                        // Go back to home (clear all group-related navigation)
                                        navigationPath.removeAll { route in
                                            switch route {
                                            case .createGroup, .createGroupCode, .createGroupPending:
                                                return true
                                            default:
                                                return false
                                            }
                                        }
                                    }
                                )
                            default:
                                Text("Unknown authenticated route: \(String(describing: route))")
                            }
                        }
                }
            } else {
                AuthFlowView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authManager.isAuthenticated)
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            print("🟢 MainContentView: Auth state changed from \(oldValue) to \(newValue)")
            print("🟢 MainContentView: Will show: \(newValue ? "HomeView" : "AuthFlowView")")
            
            // Clear navigation path when authentication state changes
            if !newValue {
                navigationPath.removeAll()
                print("🔄 Cleared navigation path on logout")
            }
        }
        .onAppear {
            print("🟢 MainContentView appeared - Auth state: \(authManager.isAuthenticated)")
        }
        .onAppear {
            authManager.startAuthStateListener()
        }
        .onOpenURL { url in
            Task {
                try await supabase.auth.session(from: url)
            }
        }
    }
}

#Preview {
    MainContentView()
} 
