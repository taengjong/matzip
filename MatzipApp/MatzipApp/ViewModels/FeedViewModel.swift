import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var feedItems: [RestaurantListFeedItem] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var error: Error?
    
    private let userRestaurantService: UserRestaurantService
    private let userFollowService: UserFollowService
    private let currentUserId = "current_user"
    
    init() {
        self.userRestaurantService = UserRestaurantService(userId: currentUserId)
        self.userFollowService = UserFollowService(userId: currentUserId)
        loadFeedData()
    }
    
    func loadFeedData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshFeedData()
            self.isLoading = false
        }
    }
    
    func refreshFeed() {
        isRefreshing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshFeedData()
            self.isRefreshing = false
        }
    }
    
    func loadMoreFeed() {
        // 페이징을 위한 추가 데이터 로드 (현재는 시뮬레이션)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let additionalItems = self.generateAdditionalFeedItems()
            self.feedItems.append(contentsOf: additionalItems)
        }
    }
    
    private func refreshFeedData() {
        // 팔로잉 사용자들의 ID 가져오기
        let followingUsers = userFollowService.getFollowing()
        let followingUserIds = followingUsers.map { $0.id }
        
        // 팔로잉 사용자들의 맛집 리스트 활동 가져오기
        let feedItems = userRestaurantService.getRestaurantListsForFeed(followingUserIds: followingUserIds)
        
        // 시간순으로 정렬 (최신순)
        self.feedItems = feedItems.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func generateAdditionalFeedItems() -> [RestaurantListFeedItem] {
        let additionalUsers = [
            User(
                id: "additional_user_1",
                name: "김요리",
                email: "cooking@example.com",
                profileImageURL: nil,
                reviewCount: 45,
                averageRating: 4.3,
                followersCount: 234,
                followingCount: 67,
                publicListsCount: 8,
                bio: "집밥 요리 전문가 👩‍🍳",
                createdAt: Date().addingTimeInterval(-86400 * 30)
            ),
            User(
                id: "additional_user_2",
                name: "박디저트",
                email: "dessert@example.com",
                profileImageURL: nil,
                reviewCount: 67,
                averageRating: 4.6,
                followersCount: 445,
                followingCount: 123,
                publicListsCount: 12,
                bio: "달콤한 디저트 큐레이터 🍰",
                createdAt: Date().addingTimeInterval(-86400 * 45)
            )
        ]
        
        let additionalLists = [
            UserRestaurantList(
                id: "additional_list_1",
                userId: "additional_user_1",
                name: "집밥 느낌 맛집",
                description: "엄마 손맛이 느껴지는 따뜻한 맛집들",
                restaurantIds: ["rest16", "rest17", "rest18"],
                isPublic: true,
                createdAt: Date().addingTimeInterval(-3600 * 18),
                updatedAt: nil
            ),
            UserRestaurantList(
                id: "additional_list_2",
                userId: "additional_user_2",
                name: "디저트 맛집 베스트",
                description: "달콤함이 가득한 디저트 명가들",
                restaurantIds: ["rest19", "rest20", "rest21", "rest22"],
                isPublic: true,
                createdAt: Date().addingTimeInterval(-3600 * 24),
                updatedAt: nil
            )
        ]
        
        return [
            RestaurantListFeedItem(
                list: additionalLists[0],
                user: additionalUsers[0],
                createdAt: Date().addingTimeInterval(-3600 * 18),
                activityType: .newList
            ),
            RestaurantListFeedItem(
                list: additionalLists[1],
                user: additionalUsers[1],
                createdAt: Date().addingTimeInterval(-3600 * 24),
                activityType: .newList
            )
        ]
    }
    
    func toggleLike(for item: RestaurantListFeedItem) {
        // 실제로는 서버에 좋아요 상태를 저장
        // 현재는 UI 업데이트만 시뮬레이션
        print("좋아요 토글: \(item.list.name)")
    }
    
    func shareList(_ list: UserRestaurantList) {
        // 맛집 리스트 공유 기능
        print("리스트 공유: \(list.name)")
    }
    
    func followUser(_ user: User) {
        userFollowService.followUser(user.id)
        // 피드 새로고침으로 변경사항 반영
        refreshFeedData()
    }
    
    func unfollowUser(_ user: User) {
        userFollowService.unfollowUser(user.id)
        // 피드 새로고침으로 변경사항 반영
        refreshFeedData()
    }
}