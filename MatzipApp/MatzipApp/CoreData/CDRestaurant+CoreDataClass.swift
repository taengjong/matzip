import Foundation
import CoreData

@objc(CDRestaurant)
public class CDRestaurant: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    convenience init(context: NSManagedObjectContext, restaurant: Restaurant) {
        self.init(context: context)
        updateFromRestaurant(restaurant)
    }
    
    // MARK: - Update Methods
    
    func updateFromRestaurant(_ restaurant: Restaurant) {
        self.id = restaurant.id
        self.name = restaurant.name
        self.categoryRawValue = restaurant.category.rawValue
        self.address = restaurant.address
        self.latitude = restaurant.coordinate.latitude
        self.longitude = restaurant.coordinate.longitude
        self.phoneNumber = restaurant.phoneNumber
        self.rating = restaurant.rating
        self.reviewCount = Int32(restaurant.reviewCount)
        self.priceRangeRawValue = Int16(restaurant.priceRange.rawValue)
        self.restaurantDescription = restaurant.description
        self.imageURLsData = encodeImageURLs(restaurant.imageURLs)
        self.isFavorite = restaurant.isFavorite
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Convert to Domain Model
    
    func toRestaurant() -> Restaurant {
        return Restaurant(
            id: id ?? "",
            name: name ?? "",
            category: RestaurantCategory(rawValue: categoryRawValue ?? "") ?? .other,
            address: address ?? "",
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            phoneNumber: phoneNumber,
            rating: rating,
            reviewCount: Int(reviewCount),
            priceRange: PriceRange(rawValue: Int(priceRangeRawValue)) ?? .medium,
            openingHours: nil, // TODO: OpeningHours 구현 시 추가
            description: restaurantDescription ?? "",
            imageURLs: decodeImageURLs(imageURLsData),
            isFavorite: isFavorite
        )
    }
    
    // MARK: - Helper Methods
    
    private func encodeImageURLs(_ urls: [String]) -> Data? {
        try? JSONEncoder().encode(urls)
    }
    
    private func decodeImageURLs(_ data: Data?) -> [String] {
        guard let data = data else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}

// MARK: - Core Data Properties

extension CDRestaurant {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDRestaurant> {
        return NSFetchRequest<CDRestaurant>(entityName: "CDRestaurant")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var categoryRawValue: String?
    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var phoneNumber: String?
    @NSManaged public var rating: Double
    @NSManaged public var reviewCount: Int32
    @NSManaged public var priceRangeRawValue: Int16
    @NSManaged public var restaurantDescription: String?
    @NSManaged public var imageURLsData: Data?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
    // Relationships
    @NSManaged public var reviews: NSSet?
    @NSManaged public var restaurantLists: NSSet?
}

// MARK: - Generated accessors for reviews

extension CDRestaurant {
    
    @objc(addReviewsObject:)
    @NSManaged public func addToReviews(_ value: CDReview)
    
    @objc(removeReviewsObject:)
    @NSManaged public func removeFromReviews(_ value: CDReview)
    
    @objc(addReviews:)
    @NSManaged public func addToReviews(_ values: NSSet)
    
    @objc(removeReviews:)
    @NSManaged public func removeFromReviews(_ values: NSSet)
}

// MARK: - Generated accessors for restaurantLists

extension CDRestaurant {
    
    @objc(addRestaurantListsObject:)
    @NSManaged public func addToRestaurantLists(_ value: CDUserRestaurantList)
    
    @objc(removeRestaurantListsObject:)
    @NSManaged public func removeFromRestaurantLists(_ value: CDUserRestaurantList)
    
    @objc(addRestaurantLists:)
    @NSManaged public func addToRestaurantLists(_ values: NSSet)
    
    @objc(removeRestaurantLists:)
    @NSManaged public func removeFromRestaurantLists(_ values: NSSet)
}