import Foundation
import Supabase

class ProfileService {
    static let shared = ProfileService()
    
    private init() {}
    
    /// Check if a profile exists for the given phone number
    /// Returns the profile if found, nil if not found
    func checkProfileExists(phoneNumber: String) async throws -> Profile? {
        // Clean phone number - remove any formatting and keep only digits
        let cleanPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        print("🔍 Checking if profile exists for phone: \(cleanPhoneNumber)")
        
        do {
            let response: [Profile] = try await supabase
                .from("profiles")
                .select()
                .eq("phone_number", value: cleanPhoneNumber)
                .execute()
                .value
            
            if let profile = response.first {
                print("✅ Profile found for phone: \(cleanPhoneNumber)")
                print("   - Name: \(profile.firstName ?? "N/A") \(profile.lastName ?? "N/A")")
                print("   - ID: \(profile.id)")
                return profile
            } else {
                print("❌ No profile found for phone: \(cleanPhoneNumber)")
                return nil
            }
        } catch {
            print("🚨 Error checking profile existence: \(error)")
            throw error
        }
    }
    
    /// Create a new profile with the given information
    func createProfile(
        userID: UUID,
        phoneNumber: String,
        firstName: String?,
        lastName: String?,
        username: String?,
        profileBio: String?,
        avatarURL: String? = nil
    ) async throws -> Profile {
        // Clean phone number - remove any formatting and keep only digits  
        let cleanPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        print("📝 Creating new profile for phone: \(cleanPhoneNumber)")
        
        let newProfile = Profile(
            id: userID, // Use the Supabase Auth user ID
            phoneNumber: cleanPhoneNumber,
            firstName: firstName,
            lastName: lastName,
            username: username,
            profileBio: profileBio,
            avatarURL: avatarURL,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            let response: [Profile] = try await supabase
                .from("profiles")
                .insert(newProfile)
                .select()
                .execute()
                .value
            
            guard let createdProfile = response.first else {
                throw ProfileServiceError.profileCreationFailed
            }
            
            print("✅ Profile created successfully with ID: \(createdProfile.id)")
            return createdProfile
        } catch {
            print("🚨 Error creating profile: \(error)")
            throw error
        }
    }
    
    /// Update an existing profile
    func updateProfile(_ profile: Profile) async throws -> Profile {
        print("📝 Updating profile with ID: \(profile.id)")
        
        do {
            let response: [Profile] = try await supabase
                .from("profiles")
                .update(profile)
                .eq("id", value: profile.id)
                .select()
                .execute()
                .value
            
            guard let updatedProfile = response.first else {
                throw ProfileServiceError.profileUpdateFailed
            }
            
            print("✅ Profile updated successfully")
            return updatedProfile
        } catch {
            print("🚨 Error updating profile: \(error)")
            throw error
        }
    }
    
    /// Get a profile by user ID
    func getProfile(userId: UUID) async throws -> Profile {
        print("🔍 Getting profile for user ID: \(userId)")
        
        let response: [Profile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value
        
        guard let profile = response.first else {
            print("❌ Profile not found for user ID: \(userId)")
            throw ProfileServiceError.profileNotFound
        }
        
        print("✅ Profile found for user ID: \(userId)")
        print("   - Name: \(profile.firstName ?? "N/A") \(profile.lastName ?? "N/A")")
        return profile
    }
}

enum ProfileServiceError: Error, LocalizedError {
    case profileCreationFailed
    case profileUpdateFailed
    case profileNotFound
    
    var errorDescription: String? {
        switch self {
        case .profileCreationFailed:
            return "Failed to create profile"
        case .profileUpdateFailed:
            return "Failed to update profile"
        case .profileNotFound:
            return "Profile not found"
        }
    }
}
