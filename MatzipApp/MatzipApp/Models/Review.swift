import Foundation

struct Review: Identifiable, Codable {
    let id: String
    let restaurantId: String
    let userId: String
    let userName: String
    let userProfileImage: String?
    let rating: Double
    let content: String
    let imageURLs: [String]
    let createdAt: Date
    let updatedAt: Date?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let profileImageURL: String?
    let reviewCount: Int
    let averageRating: Double
    let followersCount: Int
    let followingCount: Int
    let publicListsCount: Int
    let bio: String?
    let createdAt: Date
    
    var followersText: String {
        if followersCount >= 1000 {
            return String(format: "%.1fK", Double(followersCount) / 1000)
        }
        return "\(followersCount)"
    }
    
    var followingText: String {
        if followingCount >= 1000 {
            return String(format: "%.1fK", Double(followingCount) / 1000)
        }
        return "\(followingCount)"
    }
}