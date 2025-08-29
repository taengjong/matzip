import Foundation
import CoreLocation

struct SampleData {
    
    static let sampleFollowers: [User] = [
        User(
            id: "follower1",
            name: "김맛집",
            email: "matzip@example.com",
            profileImageURL: nil,
            reviewCount: 23,
            averageRating: 4.5,
            followersCount: 89,
            followingCount: 34,
            publicListsCount: 5,
            bio: "서울 맛집 전문가 🍽️",
            createdAt: Date().addingTimeInterval(-86400 * 30)
        ),
        User(
            id: "follower2",
            name: "박푸드",
            email: "food.lover@example.com",
            profileImageURL: nil,
            reviewCount: 45,
            averageRating: 4.2,
            followersCount: 156,
            followingCount: 78,
            publicListsCount: 12,
            bio: "맛있는 음식을 찾아 다니는 푸디 👨‍🍳",
            createdAt: Date().addingTimeInterval(-86400 * 45)
        ),
        User(
            id: "follower3",
            name: "이미식가",
            email: "gourmet@example.com",
            profileImageURL: nil,
            reviewCount: 67,
            averageRating: 4.7,
            followersCount: 234,
            followingCount: 123,
            publicListsCount: 18,
            bio: "미식의 세계를 탐험합니다 🌟",
            createdAt: Date().addingTimeInterval(-86400 * 60)
        )
    ]
    
    static let sampleFollowing: [User] = [
        User(
            id: "following1",
            name: "최요리사",
            email: "chef.choi@example.com",
            profileImageURL: nil,
            reviewCount: 89,
            averageRating: 4.8,
            followersCount: 1200,
            followingCount: 234,
            publicListsCount: 25,
            bio: "요리사가 추천하는 진짜 맛집 🍳",
            createdAt: Date().addingTimeInterval(-86400 * 120)
        ),
        User(
            id: "following2",
            name: "정미식",
            email: "food.critic@example.com",
            profileImageURL: nil,
            reviewCount: 156,
            averageRating: 4.6,
            followersCount: 856,
            followingCount: 167,
            publicListsCount: 32,
            bio: "음식 칼럼니스트 | 맛집 리뷰어 📝",
            createdAt: Date().addingTimeInterval(-86400 * 90)
        ),
        User(
            id: "following3",
            name: "한식당",
            email: "korean.restaurant@example.com",
            profileImageURL: nil,
            reviewCount: 234,
            averageRating: 4.9,
            followersCount: 2340,
            followingCount: 98,
            publicListsCount: 45,
            bio: "전통 한식의 참맛을 전합니다 🥢",
            createdAt: Date().addingTimeInterval(-86400 * 180)
        )
    ]
    
    static let sampleSuggestedUsers: [User] = [
        User(
            id: "suggested1",
            name: "송브런치",
            email: "brunch.lover@example.com",
            profileImageURL: nil,
            reviewCount: 34,
            averageRating: 4.3,
            followersCount: 423,
            followingCount: 156,
            publicListsCount: 8,
            bio: "브런치 맛집만 골라서 🥞☕️",
            createdAt: Date().addingTimeInterval(-86400 * 25)
        ),
        User(
            id: "suggested2",
            name: "윤디저트",
            email: "dessert.queen@example.com",
            profileImageURL: nil,
            reviewCount: 78,
            averageRating: 4.4,
            followersCount: 567,
            followingCount: 234,
            publicListsCount: 15,
            bio: "달콤한 디저트 세상 🧁🍰",
            createdAt: Date().addingTimeInterval(-86400 * 40)
        ),
        User(
            id: "suggested3",
            name: "강스시",
            email: "sushi.master@example.com",
            profileImageURL: nil,
            reviewCount: 123,
            averageRating: 4.7,
            followersCount: 890,
            followingCount: 67,
            publicListsCount: 22,
            bio: "스시 장인이 인정하는 맛집들 🍣",
            createdAt: Date().addingTimeInterval(-86400 * 75)
        )
    ]
    
    static let sampleUserRestaurantLists: [UserRestaurantList] = [
        UserRestaurantList(
            id: "list1",
            userId: "following1",
            name: "요리사가 추천하는 한식당",
            description: "전문 요리사 입장에서 정말 맛있는 한식당들만 모았습니다. 재료부터 조리법까지 완벽한 곳들이에요.",
            restaurantIds: ["rest1", "rest2", "rest3", "rest4", "rest5"],
            isPublic: true
        ),
        UserRestaurantList(
            id: "list2", 
            userId: "following2",
            name: "홍대 숨은 맛집",
            description: "홍대에서 현지인만 아는 진짜 맛집들. 관광객들은 모르는 로컬 맛집들을 소개합니다.",
            restaurantIds: ["rest6", "rest7", "rest8"],
            isPublic: true
        ),
        UserRestaurantList(
            id: "list3",
            userId: "following3", 
            name: "전통 한정식 명가",
            description: "3대째 이어온 전통 한정식집들. 한국의 참맛을 느낄 수 있는 곳들입니다.",
            restaurantIds: ["rest9", "rest10", "rest11", "rest12"],
            isPublic: true
        ),
        UserRestaurantList(
            id: "list4",
            userId: "suggested1",
            name: "최고의 브런치 카페",
            description: "주말 브런치를 위한 완벽한 선택지들. 인테리어부터 맛까지 모든 게 완벽한 카페들이에요.",
            restaurantIds: ["rest13", "rest14", "rest15"],
            isPublic: true
        )
    ]
    
    static let sampleRestaurantListFeedItems: [RestaurantListFeedItem] = [
        RestaurantListFeedItem(
            list: sampleUserRestaurantLists[0],
            user: sampleFollowing[0],
            createdAt: Date().addingTimeInterval(-3600 * 2),
            activityType: .newList
        ),
        RestaurantListFeedItem(
            list: sampleUserRestaurantLists[1],
            user: sampleFollowing[1],
            createdAt: Date().addingTimeInterval(-3600 * 6),
            activityType: .newList
        ),
        RestaurantListFeedItem(
            list: sampleUserRestaurantLists[2],
            user: sampleFollowing[2],
            createdAt: Date().addingTimeInterval(-3600 * 12),
            activityType: .newList
        ),
        RestaurantListFeedItem(
            list: sampleUserRestaurantLists[3],
            user: sampleSuggestedUsers[0],
            createdAt: Date().addingTimeInterval(-86400),
            activityType: .newList
        )
    ]
}