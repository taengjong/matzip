import Foundation
import Combine

class UserFollowService: ObservableObject {
    @Published var followers: [User] = []
    @Published var following: [User] = []
    @Published var suggestedUsers: [User] = []
    @Published var followingSummaries: [FollowingSummary] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    let currentUserId: String
    private var follows: [UserFollow] = []
    
    init(userId: String) {
        self.currentUserId = userId
    }
    
    func loadFollowers() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.followers = SampleData.sampleFollowers
            self.isLoading = false
        }
    }
    
    func loadFollowing() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.following = SampleData.sampleFollowing
            self.isLoading = false
        }
    }
    
    func loadSuggestedUsers() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.suggestedUsers = SampleData.sampleSuggestedUsers
            self.isLoading = false
        }
    }
    
    func followUser(_ userId: String) {
        let follow = UserFollow(followerId: currentUserId, followingId: userId)
        follows.append(follow)
        
        objectWillChange.send()
    }
    
    func unfollowUser(_ userId: String) {
        follows.removeAll { $0.followerId == currentUserId && $0.followingId == userId }
        
        objectWillChange.send()
    }
    
    func isFollowing(_ userId: String) -> Bool {
        return follows.contains { $0.followerId == currentUserId && $0.followingId == userId }
    }
    
    func getFollowStatus(for userId: String) -> FollowStatus {
        let isFollowing = follows.contains { $0.followerId == currentUserId && $0.followingId == userId }
        let isFollowedBy = follows.contains { $0.followerId == userId && $0.followingId == currentUserId }
        
        switch (isFollowing, isFollowedBy) {
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
    
    func getFollowersCount(for userId: String) -> Int {
        return follows.filter { $0.followingId == userId }.count
    }
    
    func getFollowingCount(for userId: String) -> Int {
        return follows.filter { $0.followerId == userId }.count
    }
    
    func getMutualFollowersCount(with userId: String) -> Int {
        let myFollowing = Set(follows.filter { $0.followerId == currentUserId }.map { $0.followingId })
        let theirFollowing = Set(follows.filter { $0.followerId == userId }.map { $0.followingId })
        
        return myFollowing.intersection(theirFollowing).count
    }
    
    func searchUsers(query: String) -> [User] {
        let allUsers = SampleData.sampleFollowers + SampleData.sampleFollowing + SampleData.sampleSuggestedUsers
        return allUsers.filter { user in
            user.name.localizedCaseInsensitiveContains(query) ||
            user.email.localizedCaseInsensitiveContains(query) ||
            (user.bio?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    func reportUser(_ userId: String, reason: String) {
        
    }
    
    func blockUser(_ userId: String) {
        unfollowUser(userId)
    }
}