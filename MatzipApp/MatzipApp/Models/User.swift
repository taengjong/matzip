import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var profileImageURL: String?
    var reviewCount: Int
    var averageRating: Double
    var followersCount: Int
    var followingCount: Int
    var publicListsCount: Int
    var bio: String
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