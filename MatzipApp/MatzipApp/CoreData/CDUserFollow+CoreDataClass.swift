import Foundation
import CoreData

@objc(CDUserFollow)
public class CDUserFollow: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    convenience init(context: NSManagedObjectContext, follow: UserFollow) {
        self.init(context: context)
        updateFromUserFollow(follow)
    }
    
    // MARK: - Update Methods
    
    func updateFromUserFollow(_ follow: UserFollow) {
        self.id = follow.id
        self.followerId = follow.followerId
        self.followingId = follow.followingId
        self.createdAt = follow.createdAt
        self.updatedAt = Date()
    }
    
    // MARK: - Convert to Domain Model
    
    func toUserFollow() -> UserFollow {
        return UserFollow(
            id: id ?? "",
            followerId: followerId ?? "",
            followingId: followingId ?? "",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt
        )
    }
}

// MARK: - Core Data Properties

extension CDUserFollow {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUserFollow> {
        return NSFetchRequest<CDUserFollow>(entityName: "CDUserFollow")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var followerId: String?
    @NSManaged public var followingId: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}