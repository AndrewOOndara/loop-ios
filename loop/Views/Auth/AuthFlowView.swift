//
//  AuthFlowView.swift
//  loop
//
//  Created by Sarah Luan on 8/12/25.
//
//  Auth flow - login and verification
//

import SwiftUI

enum AuthRoute: Hashable {
    case verify(phone: String)
    case profileSetup
    case home
    case groupDetail(group: GroupModel)
    case notifications
    case joinGroup
    case joinGroupConfirm(group: UserGroup)
    case joinGroupSuccess
    case createGroup
    case createGroupCode(group: UserGroup, groupImage: UIImage?)
    case createGroupPending(group: UserGroup, groupImage: UIImage?)
}

struct AuthFlowView: View {
    @State private var path: [AuthRoute] = []
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationStack(path: $path) {
            AuthView(onSubmit: { phone in
                path.append(.verify(phone: phone))
            })
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .verify(let phone):
                    VerificationView(
                        phone: phone,
                        onSuccess: {
                            path.append(.profileSetup)
                        },
                        onExistingUser: {
                            path.append(.home)
                        },
                        onBack: {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .profileSetup:
                    ProfileSetupView(
                        onComplete: {
                            path.append(.home)
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .home:
                    HomeView(navigationPath: $path)
                        .navigationBarBackButtonHidden(true)
                case .groupDetail(let group):
                    GroupDetailView(group: group)
                        .navigationBarBackButtonHidden(true)
                case .notifications:
                    NotificationView()
                        .navigationBarBackButtonHidden(true)
                case .joinGroup:
                    JoinGroupView(
                        onNext: { group in
                            path.append(.joinGroupConfirm(group: group))
                        },
                        onBack: {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .joinGroupConfirm(let group):
                    JoinGroupConfirmView(
                        group: group,
                        onConfirm: {
                            path.append(.joinGroupSuccess)
                        },
                        onCancel: {
                            // Go back to join group code entry
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .joinGroupSuccess:
                    JoinGroupSuccessView {
                        // Go back to home (clear all group-related navigation)
                        path.removeAll { route in
                            switch route {
                            case .joinGroup, .joinGroupConfirm, .joinGroupSuccess:
                                return true
                            default:
                                return false
                            }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                case .createGroup:
                    CreateGroupView(
                        onNext: { group, groupImage in
                            path.append(.createGroupCode(group: group, groupImage: groupImage))
                        },
                        onBack: {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .createGroupCode(let group, let groupImage):
                    CreateGroupCodeView(
                        group: group,
                        groupImage: groupImage,
                        onNext: {
                            path.append(.createGroupPending(group: group, groupImage: groupImage))
                        },
                        onBack: {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .createGroupPending(let group, let groupImage):
                    CreateGroupPendingView(
                        group: group,
                        groupImage: groupImage,
                        onDone: {
                            // Go back to home (clear all group-related navigation)
                            path.removeAll { route in
                                switch route {
                                case .createGroup, .createGroupCode, .createGroupPending:
                                    return true
                                default:
                                    return false
                                }
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}
