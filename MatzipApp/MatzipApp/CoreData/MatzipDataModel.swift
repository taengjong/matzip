import Foundation
import CoreData

// MARK: - Programmatic Core Data Model Creation

extension CoreDataStack {
    
    static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create entities
        let restaurantEntity = createRestaurantEntity()
        let reviewEntity = createReviewEntity()
        let userRestaurantListEntity = createUserRestaurantListEntity()
        let userFollowEntity = createUserFollowEntity()
        
        // Set up relationships
        setupRelationships(
            restaurantEntity: restaurantEntity,
            reviewEntity: reviewEntity,
            userRestaurantListEntity: userRestaurantListEntity
        )
        
        // Add entities to model
        model.entities = [
            restaurantEntity,
            reviewEntity,
            userRestaurantListEntity,
            userFollowEntity
        ]
        
        return model
    }
    
    // MARK: - Entity Creation
    
    private static func createRestaurantEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDRestaurant"
        entity.managedObjectClassName = "CDRestaurant"
        
        // Attributes
        entity.properties = [
            createStringAttribute("id", isOptional: false),
            createStringAttribute("name", isOptional: false),
            createStringAttribute("categoryRawValue", isOptional: false),
            createStringAttribute("address", isOptional: false),
            createDoubleAttribute("latitude"),
            createDoubleAttribute("longitude"),
            createStringAttribute("phoneNumber", isOptional: true),
            createDoubleAttribute("rating"),
            createInteger32Attribute("reviewCount"),
            createInteger16Attribute("priceRangeRawValue"),
            createStringAttribute("restaurantDescription", isOptional: true),
            createBinaryDataAttribute("imageURLsData", isOptional: true),
            createBooleanAttribute("isFavorite"),
            createDateAttribute("createdAt", isOptional: true),
            createDateAttribute("updatedAt", isOptional: true)
        ]
        
        return entity
    }
    
    private static func createReviewEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDReview"
        entity.managedObjectClassName = "CDReview"
        
        entity.properties = [
            createStringAttribute("id", isOptional: false),
            createStringAttribute("restaurantId", isOptional: false),
            createStringAttribute("userId", isOptional: false),
            createStringAttribute("userName", isOptional: false),
            createStringAttribute("userProfileImageURL", isOptional: true),
            createDoubleAttribute("rating"),
            createStringAttribute("comment", isOptional: true),
            createBinaryDataAttribute("imageURLsData", isOptional: true),
            createDateAttribute("visitDate", isOptional: true),
            createDateAttribute("createdAt", isOptional: false),
            createDateAttribute("updatedAt", isOptional: true)
        ]
        
        return entity
    }
    
    private static func createUserRestaurantListEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDUserRestaurantList"
        entity.managedObjectClassName = "CDUserRestaurantList"
        
        entity.properties = [
            createStringAttribute("id", isOptional: false),
            createStringAttribute("userId", isOptional: false),
            createStringAttribute("name", isOptional: false),
            createStringAttribute("listDescription", isOptional: true),
            createBinaryDataAttribute("restaurantIdsData", isOptional: true),
            createBooleanAttribute("isPublic"),
            createDateAttribute("createdAt", isOptional: false),
            createDateAttribute("updatedAt", isOptional: true)
        ]
        
        return entity
    }
    
    private static func createUserFollowEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDUserFollow"
        entity.managedObjectClassName = "CDUserFollow"
        
        entity.properties = [
            createStringAttribute("id", isOptional: false),
            createStringAttribute("followerId", isOptional: false),
            createStringAttribute("followingId", isOptional: false),
            createDateAttribute("createdAt", isOptional: false),
            createDateAttribute("updatedAt", isOptional: true)
        ]
        
        return entity
    }
    
    // MARK: - Relationship Setup
    
    private static func setupRelationships(
        restaurantEntity: NSEntityDescription,
        reviewEntity: NSEntityDescription,
        userRestaurantListEntity: NSEntityDescription
    ) {
        // Restaurant -> Reviews (One to Many)
        let restaurantReviewsRelationship = NSRelationshipDescription()
        restaurantReviewsRelationship.name = "reviews"
        restaurantReviewsRelationship.destinationEntity = reviewEntity
        restaurantReviewsRelationship.isOptional = true
        restaurantReviewsRelationship.minCount = 0
        restaurantReviewsRelationship.maxCount = 0 // 0 means no limit
        restaurantReviewsRelationship.deleteRule = .cascadeDeleteRule
        
        // Review -> Restaurant (Many to One)
        let reviewRestaurantRelationship = NSRelationshipDescription()
        reviewRestaurantRelationship.name = "restaurant"
        reviewRestaurantRelationship.destinationEntity = restaurantEntity
        reviewRestaurantRelationship.isOptional = true
        reviewRestaurantRelationship.minCount = 0
        reviewRestaurantRelationship.maxCount = 1
        reviewRestaurantRelationship.deleteRule = .nullifyDeleteRule
        
        // Set inverse relationships
        restaurantReviewsRelationship.inverseRelationship = reviewRestaurantRelationship
        reviewRestaurantRelationship.inverseRelationship = restaurantReviewsRelationship
        
        // Add relationships to entities
        restaurantEntity.properties.append(restaurantReviewsRelationship)
        reviewEntity.properties.append(reviewRestaurantRelationship)
        
        // Restaurant -> RestaurantLists (Many to Many)
        let restaurantListsRelationship = NSRelationshipDescription()
        restaurantListsRelationship.name = "restaurantLists"
        restaurantListsRelationship.destinationEntity = userRestaurantListEntity
        restaurantListsRelationship.isOptional = true
        restaurantListsRelationship.minCount = 0
        restaurantListsRelationship.maxCount = 0
        restaurantListsRelationship.deleteRule = .nullifyDeleteRule
        
        // RestaurantList -> Restaurants (Many to Many)
        let listRestaurantsRelationship = NSRelationshipDescription()
        listRestaurantsRelationship.name = "restaurants"
        listRestaurantsRelationship.destinationEntity = restaurantEntity
        listRestaurantsRelationship.isOptional = true
        listRestaurantsRelationship.minCount = 0
        listRestaurantsRelationship.maxCount = 0
        listRestaurantsRelationship.deleteRule = .nullifyDeleteRule
        
        // Set inverse relationships
        restaurantListsRelationship.inverseRelationship = listRestaurantsRelationship
        listRestaurantsRelationship.inverseRelationship = restaurantListsRelationship
        
        // Add relationships to entities
        restaurantEntity.properties.append(restaurantListsRelationship)
        userRestaurantListEntity.properties.append(listRestaurantsRelationship)
    }
    
    // MARK: - Attribute Helpers
    
    private static func createStringAttribute(_ name: String, isOptional: Bool = true) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = isOptional
        return attribute
    }
    
    private static func createDoubleAttribute(_ name: String, isOptional: Bool = false) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .doubleAttributeType
        attribute.isOptional = isOptional
        attribute.defaultValue = 0.0
        return attribute
    }
    
    private static func createInteger32Attribute(_ name: String, isOptional: Bool = false) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .integer32AttributeType
        attribute.isOptional = isOptional
        attribute.defaultValue = 0
        return attribute
    }
    
    private static func createInteger16Attribute(_ name: String, isOptional: Bool = false) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .integer16AttributeType
        attribute.isOptional = isOptional
        attribute.defaultValue = 0
        return attribute
    }
    
    private static func createBooleanAttribute(_ name: String, isOptional: Bool = false) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .booleanAttributeType
        attribute.isOptional = isOptional
        attribute.defaultValue = false
        return attribute
    }
    
    private static func createDateAttribute(_ name: String, isOptional: Bool = true) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = isOptional
        return attribute
    }
    
    private static func createBinaryDataAttribute(_ name: String, isOptional: Bool = true) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .binaryDataAttributeType
        attribute.isOptional = isOptional
        attribute.allowsExternalBinaryDataStorage = true
        return attribute
    }
}