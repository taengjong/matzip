import CoreData
import Foundation

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let managedObjectModel = CoreDataStack.createManagedObjectModel()
        let container = NSPersistentContainer(name: "MatzipDataModel", managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // 개발 중에는 데이터 모델 변경이 자주 일어나므로 
                // 에러 발생 시 스토어를 삭제하고 새로 생성
                print("Core Data error: \(error), \(error.userInfo)")
                
                #if DEBUG
                self.resetPersistentStore(container: container)
                #else
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #endif
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Background Context
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Save Context
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data saved successfully")
            } catch {
                print("❌ Core Data save error: \(error)")
            }
        }
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Background context saved successfully")
            } catch {
                print("❌ Background context save error: \(error)")
            }
        }
    }
    
    // MARK: - Development Helper
    
    #if DEBUG
    private func resetPersistentStore(container: NSPersistentContainer) {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            print("❌ Could not find store URL")
            return
        }
        
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(
                at: storeURL, 
                ofType: NSSQLiteStoreType, 
                options: nil
            )
            
            // 새로운 스토어 생성
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to recreate store: \(error)")
                }
                print("✅ Core Data store reset and recreated")
            }
        } catch {
            fatalError("Failed to destroy store: \(error)")
        }
    }
    
    // 개발용: 모든 데이터 삭제
    func deleteAllData() {
        let entities = ["CDRestaurant", "CDReview", "CDUserRestaurantList", "CDUserFollow"]
        
        entities.forEach { entityName in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try viewContext.execute(deleteRequest)
                print("✅ Deleted all data from \(entityName)")
            } catch {
                print("❌ Failed to delete data from \(entityName): \(error)")
            }
        }
        
        save()
    }
    #endif
}