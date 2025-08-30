import Foundation
import CoreData

@objc(CDUserRestaurantList)
public class CDUserRestaurantList: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    convenience init(context: NSManagedObjectContext, list: UserRestaurantList) {
        self.init(context: context)
        updateFromUserRestaurantList(list)
    }
    
    // MARK: - Update Methods
    
    func updateFromUserRestaurantList(_ list: UserRestaurantList) {
        self.id = list.id
        self.userId = list.userId
        self.name = list.name
        self.listDescription = list.description
        self.restaurantIdsData = encodeRestaurantIds(list.restaurantIds)
        self.isPublic = list.isPublic
        self.createdAt = list.createdAt
        self.updatedAt = Date()
    }
    
    // MARK: - Convert to Domain Model
    
    func toUserRestaurantList() -> UserRestaurantList {
        return UserRestaurantList(
            id: id ?? "",
            userId: userId ?? "",
            name: name ?? "",
            description: listDescription,
            restaurantIds: decodeRestaurantIds(restaurantIdsData),
            isPublic: isPublic,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt
        )
    }
    
    // MARK: - Helper Methods
    
    private func encodeRestaurantIds(_ ids: [String]) -> Data? {
        try? JSONEncoder().encode(ids)
    }
    
    private func decodeRestaurantIds(_ data: Data?) -> [String] {
        guard let data = data else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
    
    // MARK: - Computed Properties
    
    var restaurantCount: Int {
        return decodeRestaurantIds(restaurantIdsData).count
    }
}

// MARK: - Core Data Properties

extension CDUserRestaurantList {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUserRestaurantList> {
        return NSFetchRequest<CDUserRestaurantList>(entityName: "CDUserRestaurantList")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var name: String?
    @NSManaged public var listDescription: String?
    @NSManaged public var restaurantIdsData: Data?
    @NSManaged public var isPublic: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
    // Relationships
    @NSManaged public var restaurants: NSSet?
}

// MARK: - Generated accessors for restaurants

extension CDUserRestaurantList {
    
    @objc(addRestaurantsObject:)
    @NSManaged public func addToRestaurants(_ value: CDRestaurant)
    
    @objc(removeRestaurantsObject:)
    @NSManaged public func removeFromRestaurants(_ value: CDRestaurant)
    
    @objc(addRestaurants:)
    @NSManaged public func addToRestaurants(_ values: NSSet)
    
    @objc(removeRestaurants:)
    @NSManaged public func removeFromRestaurants(_ values: NSSet)
}