import Foundation
import CoreData

@objc(CDReview)
public class CDReview: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    convenience init(context: NSManagedObjectContext, review: Review) {
        self.init(context: context)
        updateFromReview(review)
    }
    
    // MARK: - Update Methods
    
    func updateFromReview(_ review: Review) {
        self.id = review.id
        self.restaurantId = review.restaurantId
        self.userId = review.userId
        self.userName = review.userName
        self.userProfileImageURL = review.userProfileImage
        self.rating = review.rating
        self.comment = review.content
        self.imageURLsData = encodeImageURLs(review.imageURLs)
        self.visitDate = review.createdAt // visitDate를 createdAt으로 사용
        self.createdAt = review.createdAt
        self.updatedAt = Date()
    }
    
    // MARK: - Convert to Domain Model
    
    func toReview() -> Review {
        return Review(
            id: id ?? "",
            restaurantId: restaurantId ?? "",
            userId: userId ?? "",
            userName: userName ?? "",
            userProfileImage: userProfileImageURL,
            rating: rating,
            content: comment ?? "",
            imageURLs: decodeImageURLs(imageURLsData),
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt
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

extension CDReview {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDReview> {
        return NSFetchRequest<CDReview>(entityName: "CDReview")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var restaurantId: String?
    @NSManaged public var userId: String?
    @NSManaged public var userName: String?
    @NSManaged public var userProfileImageURL: String?
    @NSManaged public var rating: Double
    @NSManaged public var comment: String?
    @NSManaged public var imageURLsData: Data?
    @NSManaged public var visitDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
    // Relationships
    @NSManaged public var restaurant: CDRestaurant?
}