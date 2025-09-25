//
//  GroupService.swift
//  loop
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import Supabase

class GroupService {
    // Using the global supabase client from SupabaseClient.swift
    
    // MARK: - Join Group Functions
    
    /// Look up a group by its 4-digit code
    func findGroup(by code: String) async throws -> UserGroup? {
        print("[GroupService] Looking up group with code: '\(code)'")
        print("[GroupService] Code length: \(code.count)")
        
        // Debug current user
        if let currentUser = supabase.auth.currentUser {
            print("[GroupService] Current user ID: \(currentUser.id)")
        } else {
            print("[GroupService] ⚠️ No current user - not authenticated!")
        }
        
        do {
            let response: [UserGroup] = try await supabase
                .from("groups")
                .select()
                .eq("group_code", value: code)
                .eq("is_active", value: true)
                .execute()
                .value
            
            print("[GroupService] Query response count: \(response.count)")
            if let group = response.first {
                print("[GroupService] Found group: '\(group.name)' with code: '\(group.groupCode)'")
                return group
            } else {
                print("[GroupService] No groups found with code: '\(code)'")
                
                // Debug: Let's see all groups in the table
                let allGroups: [UserGroup] = try await supabase
                    .from("groups")
                    .select()
                    .execute()
                    .value
                
                print("[GroupService] DEBUG - All groups in database:")
                for group in allGroups {
                    print("  - '\(group.name)' with code: '\(group.groupCode)' (active: \(group.isActive))")
                }
                
                // DEBUG: Create a test group if none exist and we're looking for 1234
                if code == "1234" && allGroups.isEmpty {
                    print("[GroupService] 🚀 Creating test group with code 1234...")
                    if let currentUser = supabase.auth.currentUser {
                        do {
                            // Create test group directly with code 1234
                            let testGroup = try await createTestGroup(name: "Test Group", code: "1234", createdBy: currentUser.id)
                            print("[GroupService] ✅ Created test group: \(testGroup.name) with code: \(testGroup.groupCode)")
                            return testGroup
                        } catch {
                            print("[GroupService] ❌ Failed to create test group: \(error)")
                        }
                    }
                }
                
                return nil
            }
        } catch {
            print("[GroupService] ERROR looking up group: \(error)")
            throw error
        }
    }
    
    /// Check if user is already a member of the group
    func isUserMember(userId: UUID, groupId: Int) async throws -> Bool {
        print("[GroupService] Checking if user \(userId) is member of group \(groupId)")
        
        let response: [GroupMember] = try await supabase
            .from("group_members")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("group_id", value: groupId)
            .eq("is_active", value: true)
            .execute()
            .value
        
        let isMember = !response.isEmpty
        print("[GroupService] User is member: \(isMember)")
        return isMember
    }
    
    /// Get current member count for a group
    func getMemberCount(groupId: Int) async throws -> Int {
        let response: [GroupMember] = try await supabase
            .from("group_members")
            .select()
            .eq("group_id", value: groupId)
            .eq("is_active", value: true)
            .execute()
            .value
        
        return response.count
    }
    
    /// Get all members of a group with their profile information
    func getGroupMembers(groupId: Int) async throws -> [GroupMemberWithProfile] {
        print("[GroupService] Fetching members for group \(groupId)")
        
        do {
            // First, get the group members
            let memberResponse: [GroupMember] = try await supabase
                .from("group_members")
                .select()
                .eq("group_id", value: groupId)
                .eq("is_active", value: true)
                .order("joined_at", ascending: true)
                .execute()
                .value
            
            print("[GroupService] Found \(memberResponse.count) members, now fetching profiles...")
            
            // Then, fetch profiles for each member
            var membersWithProfiles: [GroupMemberWithProfile] = []
            
            for member in memberResponse {
                do {
                    let profile = try await getProfile(userId: member.userId)
                    
                    let memberWithProfile = GroupMemberWithProfile(
                        id: member.id,
                        groupId: member.groupId,
                        userId: member.userId,
                        role: member.role,
                        joinedAt: member.joinedAt,
                        isActive: member.isActive,
                        profiles: profile
                    )
                    
                    membersWithProfiles.append(memberWithProfile)
                    print("[GroupService] Loaded profile for: \(profile.firstName ?? "Unknown")")
                } catch {
                    print("[GroupService] ⚠️ Could not load profile for user \(member.userId): \(error)")
                    // Continue with other members even if one fails
                }
            }
            
            print("[GroupService] Successfully loaded \(membersWithProfiles.count) members with profiles")
            return membersWithProfiles
            
        } catch {
            print("[GroupService] ❌ Error fetching members: \(error)")
            throw error
        }
    }
    
    /// Get a user profile by user ID  
    private func getProfile(userId: UUID) async throws -> Profile {
        let response: [Profile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let profile = response.first else {
            throw GroupServiceError.userNotFound
        }
        
        return profile
    }
    
    /// Join a group (add user to group_members table)
    func joinGroup(groupId: Int, userId: UUID) async throws -> GroupMember {
        print("[GroupService] User \(userId) joining group \(groupId)")
        
        // Check if group exists and is active
        let groupResponse: [UserGroup] = try await supabase
            .from("groups")
            .select()
            .eq("id", value: groupId)
            .eq("is_active", value: true)
            .execute()
            .value
        
        guard let group = groupResponse.first else {
            throw GroupServiceError.groupNotFound
        }
        
        // Check if user is already a member
        let isAlreadyMember = try await isUserMember(userId: userId, groupId: groupId)
        if isAlreadyMember {
            throw GroupServiceError.alreadyMember
        }
        
        // Check if group is full
        let currentMemberCount = try await getMemberCount(groupId: groupId)
        if currentMemberCount >= group.maxMembers {
            throw GroupServiceError.groupFull
        }
        
        // Add user to group
        struct InsertableGroupMember: Codable {
            let groupId: Int
            let userId: String
            let role: String
            
            enum CodingKeys: String, CodingKey {
                case groupId = "group_id"
                case userId = "user_id"
                case role
            }
        }
        
        let newMember = InsertableGroupMember(
            groupId: groupId,
            userId: userId.uuidString,
            role: "member"
        )
        
        let response: [GroupMember] = try await supabase
            .from("group_members")
            .insert(newMember)
            .select()
            .execute()
            .value
        
        guard let groupMember = response.first else {
            throw GroupServiceError.joinFailed
        }
        
        print("[GroupService] Successfully joined group: \(group.name)")
        return groupMember
    }
    
    // MARK: - Create Group Functions
    
    /// Generate a unique 4-digit group code
    func generateUniqueGroupCode() async throws -> String {
        var attempts = 0
        let maxAttempts = 50
        
        while attempts < maxAttempts {
            let code = String(format: "%04d", Int.random(in: 1000...9999))
            
            // Check if code already exists
            let existing = try await findGroup(by: code)
            if existing == nil {
                return code
            }
            
            attempts += 1
        }
        
        throw GroupServiceError.codeGenerationFailed
    }
    
    /// Create a test group with specific code (for debugging)
    private func createTestGroup(name: String, code: String, createdBy: UUID, avatarURL: String? = nil) async throws -> UserGroup {
        print("[GroupService] Creating test group: \(name) with code: \(code)")
        
        // Create insertable group data
        struct InsertableGroup: Codable {
            let name: String
            let groupCode: String
            let avatarURL: String?
            let createdBy: String // UUID as string for Supabase
            let maxMembers: Int
            
            enum CodingKeys: String, CodingKey {
                case name
                case groupCode = "group_code"
                case avatarURL = "avatar_url"
                case createdBy = "created_by"
                case maxMembers = "max_members"
            }
        }
        
        let insertableGroup = InsertableGroup(
            name: name,
            groupCode: code,
            avatarURL: avatarURL,
            createdBy: createdBy.uuidString,
            maxMembers: 6
        )
        
        let response: [UserGroup] = try await supabase
            .from("groups")
            .insert(insertableGroup)
            .select()
            .execute()
            .value
        
        guard let group = response.first else {
            throw GroupServiceError.createFailed
        }
        
        // Add creator as admin
        _ = try await addUserToGroup(groupId: group.id, userId: createdBy, role: "admin")
        
        print("[GroupService] Successfully created test group: \(name) with code: \(code)")
        return group
    }
    
    /// Create a new group
    func createGroup(name: String, createdBy: UUID, avatarURL: String? = nil) async throws -> UserGroup {
        print("[GroupService] Creating group: \(name)")
        
        let groupCode = try await generateUniqueGroupCode()
        
        // Create insertable group data
        struct InsertableGroup: Codable {
            let name: String
            let groupCode: String
            let avatarURL: String?
            let createdBy: String // UUID as string for Supabase
            let maxMembers: Int
            
            enum CodingKeys: String, CodingKey {
                case name
                case groupCode = "group_code"
                case avatarURL = "avatar_url"
                case createdBy = "created_by"
                case maxMembers = "max_members"
            }
        }
        
        let insertableGroup = InsertableGroup(
            name: name,
            groupCode: groupCode,
            avatarURL: avatarURL,
            createdBy: createdBy.uuidString,
            maxMembers: 6
        )
        
        let response: [UserGroup] = try await supabase
            .from("groups")
            .insert(insertableGroup)
            .select()
            .execute()
            .value
        
        guard let group = response.first else {
            throw GroupServiceError.createFailed
        }
        
        // Add creator as admin
        _ = try await addUserToGroup(groupId: group.id, userId: createdBy, role: "admin")
        
        print("[GroupService] Successfully created group: \(name) with code: \(groupCode)")
        return group
    }
    
    /// Add user to group with specific role
    private func addUserToGroup(groupId: Int, userId: UUID, role: String) async throws -> GroupMember {
        struct InsertableGroupMember: Codable {
            let groupId: Int
            let userId: String
            let role: String
            
            enum CodingKeys: String, CodingKey {
                case groupId = "group_id"
                case userId = "user_id"
                case role
            }
        }
        
        let newMember = InsertableGroupMember(
            groupId: groupId,
            userId: userId.uuidString,
            role: role
        )
        
        let response: [GroupMember] = try await supabase
            .from("group_members")
            .insert(newMember)
            .select()
            .execute()
            .value
        
        guard let groupMember = response.first else {
            throw GroupServiceError.joinFailed
        }
        
        return groupMember
    }
    
    // MARK: - User Groups
    
    /// Get all groups that a user is a member of
    func getUserGroups(userId: UUID) async throws -> [UserGroup] {
        print("[GroupService] Getting groups for user: \(userId)")
        
        // Get group IDs where user is a member
        let memberResponse: [GroupMember] = try await supabase
            .from("group_members")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_active", value: true)
            .execute()
            .value
        
        let groupIds = memberResponse.map { $0.groupId }
        
        if groupIds.isEmpty {
            return []
        }
        
        // Get group details
        let groupResponse: [UserGroup] = try await supabase
            .from("groups")
            .select()
            .in("id", values: groupIds)
            .eq("is_active", value: true)
            .execute()
            .value
        
        print("[GroupService] Found \(groupResponse.count) groups for user")
        return groupResponse
    }
}

// MARK: - Error Types

enum GroupServiceError: LocalizedError {
    case groupNotFound
    case alreadyMember
    case groupFull
    case joinFailed
    case createFailed
    case codeGenerationFailed
    case userNotFound
    case notAuthenticated
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .groupNotFound:
            return "Group not found"
        case .alreadyMember:
            return "You're already a member of this group"
        case .groupFull:
            return "This group is full"
        case .joinFailed:
            return "Failed to join group"
        case .createFailed:
            return "Failed to create group"
        case .codeGenerationFailed:
            return "Unable to generate unique group code"
        case .userNotFound:
            return "User profile not found"
        case .notAuthenticated:
            return "User not authenticated"
        case .notAuthorized:
            return "Not authorized to perform this action"
        }
    }
}

// MARK: - Group Media API

extension GroupService {
    // MARK: - Group Profile Updates
    
    /// Update group name in the backend
    func updateGroupName(groupId: Int, newName: String) async throws {
        print("[GroupService] Updating group \(groupId) name to: '\(newName)'")
        
        try await supabase
            .from("groups")
            .update([
                "name": newName,
                "updated_at": Date().toISOString()
            ])
            .eq("id", value: groupId)
            .execute()
        
        print("[GroupService] ✅ Group name updated successfully")
    }
    
    /// Upload group avatar image and update group's avatar_url
    func updateGroupAvatar(groupId: Int, imageData: Data) async throws -> String {
        print("[GroupService] Uploading avatar for group \(groupId)")
        
        // Create unique filename for avatar
        let filename = "avatar_\(UUID().uuidString).jpeg"
        let storagePath = "groups/\(groupId)/\(filename)"
        
        // Upload image to storage
        try await supabase.storage
            .from("media")
            .upload(
                storagePath,
                data: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        // Update group's avatar_url in database
        try await supabase
            .from("groups")
            .update([
                "avatar_url": storagePath,
                "updated_at": Date().toISOString()
            ])
            .eq("id", value: groupId)
            .execute()
        
        print("[GroupService] ✅ Group avatar updated successfully")
        return storagePath
    }
    
    /// Update both group name and avatar (if provided)
    func updateGroupProfile(groupId: Int, newName: String, avatarImageData: Data? = nil) async throws -> String? {
        print("[GroupService] Updating group \(groupId) profile - Name: '\(newName)', Avatar: \(avatarImageData != nil ? "Yes" : "No")")
        
        var avatarURL: String? = nil
        
        // Upload avatar if provided
        if let imageData = avatarImageData {
            avatarURL = try await updateGroupAvatar(groupId: groupId, imageData: imageData)
        }
        
        // Update name (this will also update updated_at)
        try await updateGroupName(groupId: groupId, newName: newName)
        
        print("[GroupService] ✅ Group profile updated successfully")
        return avatarURL
    }
    
    /// Upload media (image or video) to storage and record in `group_media` table
    func uploadMedia(
        groupId: Int,
        userId: UUID,
        data: Data,
        fileExtension: String,
        mediaType: GroupMediaType,
        thumbnailData: Data? = nil
    ) async throws -> GroupMedia {
        // Build paths
        let filename = "\(UUID().uuidString).\(fileExtension)"
        let storagePath = "groups/\(groupId)/\(filename)"
        var thumbPath: String? = nil
        
        // Upload primary media
        try await supabase.storage
            .from("media")
            .upload(
                storagePath,
                data: data,
                options: FileOptions(contentType: contentType(for: fileExtension))
            )
        
        // Upload thumbnail if provided
        if let thumbnailData {
            let thumbName = "thumb_\(UUID().uuidString).jpeg"
            let thumbStoragePath = "groups/\(groupId)/\(thumbName)"
            try await supabase.storage
                .from("media")
                .upload(
                    thumbStoragePath,
                    data: thumbnailData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            thumbPath = thumbStoragePath
        }
        
        // Insert DB row
        struct InsertableGroupMedia: Codable {
            let groupId: Int
            let userId: String
            let storagePath: String
            let mediaType: String
            let thumbnailPath: String?
            
            enum CodingKeys: String, CodingKey {
                case groupId = "group_id"
                case userId = "user_id"
                case storagePath = "storage_path"
                case mediaType = "media_type"
                case thumbnailPath = "thumbnail_path"
            }
        }
        
        let row = InsertableGroupMedia(
            groupId: groupId,
            userId: userId.uuidString,
            storagePath: storagePath,
            mediaType: mediaType.rawValue,
            thumbnailPath: thumbPath
        )
        
        let inserted: [GroupMedia] = try await supabase
            .from("group_media")
            .insert(row)
            .select()
            .execute()
            .value
        
        guard let media = inserted.first else {
            throw GroupServiceError.createFailed
        }
        return media
    }
    
    /// Fetch recent media for a group
    func fetchGroupMedia(groupId: Int, limit: Int = 50) async throws -> [GroupMedia] {
        let media: [GroupMedia] = try await supabase
            .from("group_media")
            .select()
            .eq("group_id", value: groupId)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return media
    }
    
    /// Get a public URL for a path from storage bucket `media`
    func getPublicURL(for path: String) throws -> URL? {
        try supabase.storage
            .from("media")
            .getPublicURL(path: path)
    }
    
    private func contentType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        default: return "application/octet-stream"
        }
    }
    
    // MARK: - Delete Group Function
    
    /// Delete a group permanently (admin only)
    func deleteGroup(groupId: Int) async throws {
        print("[GroupService] Deleting group with ID: \(groupId)")
        
        // Verify current user
        guard let currentUser = supabase.auth.currentUser else {
            print("[GroupService] ❌ No current user - not authenticated!")
            throw GroupServiceError.notAuthenticated
        }
        
        // First, verify the user is the admin/creator of the group
        let groups: [UserGroup] = try await supabase
            .from("groups")
            .select()
            .eq("id", value: groupId)
            .eq("created_by", value: currentUser.id.uuidString)
            .execute()
            .value
        
        guard !groups.isEmpty else {
            print("[GroupService] ❌ User is not authorized to delete this group")
            throw GroupServiceError.notAuthorized
        }
        
        // Delete the group (this should cascade delete members and media via database constraints)
        try await supabase
            .from("groups")
            .delete()
            .eq("id", value: groupId)
            .execute()
        
        print("[GroupService] ✅ Group deleted successfully")
    }
}

// MARK: - Date Extension
extension Date {
    func toISOString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
