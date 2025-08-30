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

