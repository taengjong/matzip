import Foundation

struct UserFollow: Identifiable, Codable {
    let id: String
    let followerId: String
    let followingId: String
    let createdAt: Date
    
    init(id: String = UUID().uuidString, followerId: String, followingId: String) {
        self.id = id
        self.followerId = followerId
        self.followingId = followingId
        self.createdAt = Date()
    }
}

struct FollowingSummary: Codable {
    let user: User
    let isFollowing: Bool
    let isFollowingBack: Bool
    let followedAt: Date?
    let mutualFollowersCount: Int
    
    var followStatus: FollowStatus {
        switch (isFollowing, isFollowingBack) {
        case (true, true):
            return .mutual
        case (true, false):
            return .following
        case (false, true):
            return .follower
        case (false, false):
            return .none
        }
    }
}

enum FollowStatus: String, CaseIterable {
    case none = "none"
    case following = "following"
    case follower = "follower" 
    case mutual = "mutual"
    
    var displayText: String {
        switch self {
        case .none: return "팔로우"
        case .following: return "팔로잉"
        case .follower: return "맞팔로우"
        case .mutual: return "서로팔로우"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none: return "person.badge.plus"
        case .following: return "person.badge.minus"
        case .follower: return "person.2"
        case .mutual: return "person.2.fill"
        }
    }
}