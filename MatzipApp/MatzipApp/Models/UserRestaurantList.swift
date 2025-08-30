import Foundation

struct UserRestaurantList: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let description: String?
    let restaurantIds: [String]
    let isPublic: Bool
    let createdAt: Date
    let updatedAt: Date?
    
    init(id: String = UUID().uuidString, 
         userId: String, 
         name: String, 
         description: String? = nil, 
         restaurantIds: [String] = [], 
         isPublic: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.restaurantIds = restaurantIds
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var restaurantCount: Int {
        restaurantIds.count
    }
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
}

struct UserFavorite: Identifiable, Codable {
    let id: String
    let userId: String
    let restaurantId: String
    let addedAt: Date
    
    init(id: String = UUID().uuidString, userId: String, restaurantId: String) {
        self.id = id
        self.userId = userId
        self.restaurantId = restaurantId
        self.addedAt = Date()
    }
}