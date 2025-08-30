import Foundation

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
    
    var publicListsText: String {
        return "\(publicListsCount)"
    }
    
    var averageRatingText: String {
        return String(format: "%.1f", averageRating)
    }
}