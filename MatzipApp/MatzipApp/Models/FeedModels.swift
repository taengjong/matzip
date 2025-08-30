import Foundation

struct RestaurantListFeedItem: Identifiable {
    let id = UUID()
    let list: UserRestaurantList
    let user: User?
    let createdAt: Date
    let activityType: FeedActivityType
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

enum FeedActivityType {
    case newList
    case addedRestaurant
    case newReview
    
    var displayText: String {
        switch self {
        case .newList:
            return "새 리스트 만들었어요"
        case .addedRestaurant:
            return "맛집을 추가했어요"
        case .newReview:
            return "새 리뷰를 작성했어요"
        }
    }
    
    var systemImage: String {
        switch self {
        case .newList:
            return "list.bullet"
        case .addedRestaurant:
            return "plus.circle"
        case .newReview:
            return "star.circle"
        }
    }
}