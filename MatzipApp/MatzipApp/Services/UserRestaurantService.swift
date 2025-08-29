import Foundation
import Combine

class UserRestaurantService: ObservableObject {
    @Published var userRestaurantLists: [UserRestaurantList] = []
    @Published var userFavorites: [UserFavorite] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let currentUserId: String
    
    init(userId: String) {
        self.currentUserId = userId
    }
    
    func loadUserRestaurantLists() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.userRestaurantLists = []
            self.isLoading = false
        }
    }
    
    func createRestaurantList(name: String, description: String?, isPublic: Bool = false) {
        let newList = UserRestaurantList(
            userId: currentUserId,
            name: name,
            description: description,
            isPublic: isPublic
        )
        
        userRestaurantLists.append(newList)
    }
    
    func addRestaurantToList(restaurantId: String, listId: String) {
        guard let index = userRestaurantLists.firstIndex(where: { $0.id == listId }) else { return }
        
        var updatedList = userRestaurantLists[index]
        var restaurantIds = updatedList.restaurantIds
        
        if !restaurantIds.contains(restaurantId) {
            restaurantIds.append(restaurantId)
            
            userRestaurantLists[index] = UserRestaurantList(
                id: updatedList.id,
                userId: updatedList.userId,
                name: updatedList.name,
                description: updatedList.description,
                restaurantIds: restaurantIds,
                isPublic: updatedList.isPublic
            )
        }
    }
    
    func removeRestaurantFromList(restaurantId: String, listId: String) {
        guard let index = userRestaurantLists.firstIndex(where: { $0.id == listId }) else { return }
        
        var updatedList = userRestaurantLists[index]
        var restaurantIds = updatedList.restaurantIds
        restaurantIds.removeAll { $0 == restaurantId }
        
        userRestaurantLists[index] = UserRestaurantList(
            id: updatedList.id,
            userId: updatedList.userId,
            name: updatedList.name,
            description: updatedList.description,
            restaurantIds: restaurantIds,
            isPublic: updatedList.isPublic
        )
    }
    
    func deleteRestaurantList(listId: String) {
        userRestaurantLists.removeAll { $0.id == listId }
    }
    
    func addToFavorites(restaurantId: String) {
        let favorite = UserFavorite(userId: currentUserId, restaurantId: restaurantId)
        
        if !userFavorites.contains(where: { $0.restaurantId == restaurantId }) {
            userFavorites.append(favorite)
        }
    }
    
    func removeFromFavorites(restaurantId: String) {
        userFavorites.removeAll { $0.restaurantId == restaurantId }
    }
    
    func isFavorite(restaurantId: String) -> Bool {
        userFavorites.contains { $0.restaurantId == restaurantId }
    }
    
    func loadPublicRestaurantLists() -> [UserRestaurantList] {
        return userRestaurantLists.filter { $0.isPublic }
    }
    
    func loadFollowingRestaurantLists(followingUserIds: [String]) -> [UserRestaurantList] {
        return userRestaurantLists.filter { list in
            followingUserIds.contains(list.userId) && list.isPublic
        }
    }
    
    func loadUserRestaurantLists(userId: String) -> [UserRestaurantList] {
        return userRestaurantLists.filter { $0.userId == userId && $0.isPublic }
    }
    
    func getRestaurantListsForFeed(followingUserIds: [String]) -> [RestaurantListFeedItem] {
        return SampleData.sampleRestaurantListFeedItems.sorted { $0.createdAt > $1.createdAt }
    }
}

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
        case .newList: return "님이 새 맛집 리스트를 만들었습니다"
        case .addedRestaurant: return "님이 맛집을 추가했습니다"
        case .newReview: return "님이 리뷰를 작성했습니다"
        }
    }
    
    var systemImage: String {
        switch self {
        case .newList: return "list.bullet"
        case .addedRestaurant: return "plus.circle"
        case .newReview: return "star.fill"
        }
    }
}