import Foundation
import CoreData
import Combine

class CoreDataService: ObservableObject {
    private let coreDataStack = CoreDataStack.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Restaurant Operations
    
    func fetchRestaurants() -> AnyPublisher<[Restaurant], Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<CDRestaurant> = CDRestaurant.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CDRestaurant.name, ascending: true)]
            
            do {
                let cdRestaurants = try context.fetch(request)
                let restaurants = cdRestaurants.map { $0.toRestaurant() }
                promise(.success(restaurants))
            } catch {
                print("❌ Failed to fetch restaurants: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchRestaurant(by id: String) -> AnyPublisher<Restaurant?, Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<CDRestaurant> = CDRestaurant.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            
            do {
                let cdRestaurants = try context.fetch(request)
                let restaurant = cdRestaurants.first?.toRestaurant()
                promise(.success(restaurant))
            } catch {
                print("❌ Failed to fetch restaurant: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveRestaurant(_ restaurant: Restaurant) -> AnyPublisher<Restaurant, Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            
            // 기존 레스토랑이 있는지 확인
            let request: NSFetchRequest<CDRestaurant> = CDRestaurant.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", restaurant.id)
            request.fetchLimit = 1
            
            do {
                let existingRestaurants = try context.fetch(request)
                let cdRestaurant: CDRestaurant
                
                if let existing = existingRestaurants.first {
                    // 기존 레스토랑 업데이트
                    cdRestaurant = existing
                    cdRestaurant.updateFromRestaurant(restaurant)
                } else {
                    // 새 레스토랑 생성
                    cdRestaurant = CDRestaurant(context: context, restaurant: restaurant)
                }
                
                self.coreDataStack.save()
                promise(.success(cdRestaurant.toRestaurant()))
            } catch {
                print("❌ Failed to save restaurant: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteRestaurant(id: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<CDRestaurant> = CDRestaurant.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let restaurants = try context.fetch(request)
                restaurants.forEach { context.delete($0) }
                self.coreDataStack.save()
                promise(.success(()))
            } catch {
                print("❌ Failed to delete restaurant: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Review Operations
    
    func fetchReviews(for restaurantId: String) -> AnyPublisher<[Review], Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<CDReview> = CDReview.fetchRequest()
            request.predicate = NSPredicate(format: "restaurantId == %@", restaurantId)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CDReview.createdAt, ascending: false)]
            
            do {
                let cdReviews = try context.fetch(request)
                let reviews = cdReviews.map { $0.toReview() }
                promise(.success(reviews))
            } catch {
                print("❌ Failed to fetch reviews: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveReview(_ review: Review) -> AnyPublisher<Review, Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            
            // 기존 리뷰가 있는지 확인
            let request: NSFetchRequest<CDReview> = CDReview.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", review.id)
            request.fetchLimit = 1
            
            do {
                let existingReviews = try context.fetch(request)
                let cdReview: CDReview
                
                if let existing = existingReviews.first {
                    cdReview = existing
                    cdReview.updateFromReview(review)
                } else {
                    cdReview = CDReview(context: context, review: review)
                }
                
                self.coreDataStack.save()
                promise(.success(cdReview.toReview()))
            } catch {
                print("❌ Failed to save review: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - User Restaurant List Operations
    
    func fetchUserRestaurantLists(for userId: String) -> AnyPublisher<[UserRestaurantList], Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<CDUserRestaurantList> = CDUserRestaurantList.fetchRequest()
            request.predicate = NSPredicate(format: "userId == %@", userId)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CDUserRestaurantList.createdAt, ascending: false)]
            
            do {
                let cdLists = try context.fetch(request)
                let lists = cdLists.map { $0.toUserRestaurantList() }
                promise(.success(lists))
            } catch {
                print("❌ Failed to fetch user restaurant lists: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveUserRestaurantList(_ list: UserRestaurantList) -> AnyPublisher<UserRestaurantList, Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            
            let request: NSFetchRequest<CDUserRestaurantList> = CDUserRestaurantList.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", list.id)
            request.fetchLimit = 1
            
            do {
                let existingLists = try context.fetch(request)
                let cdList: CDUserRestaurantList
                
                if let existing = existingLists.first {
                    cdList = existing
                    cdList.updateFromUserRestaurantList(list)
                } else {
                    cdList = CDUserRestaurantList(context: context, list: list)
                }
                
                self.coreDataStack.save()
                promise(.success(cdList.toUserRestaurantList()))
            } catch {
                print("❌ Failed to save user restaurant list: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - User Follow Operations
    
    func fetchUserFollows(for userId: String) -> AnyPublisher<[UserFollow], Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<CDUserFollow> = CDUserFollow.fetchRequest()
            request.predicate = NSPredicate(format: "followerId == %@ OR followingId == %@", userId, userId)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CDUserFollow.createdAt, ascending: false)]
            
            do {
                let cdFollows = try context.fetch(request)
                let follows = cdFollows.map { $0.toUserFollow() }
                promise(.success(follows))
            } catch {
                print("❌ Failed to fetch user follows: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveUserFollow(_ follow: UserFollow) -> AnyPublisher<UserFollow, Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            
            let request: NSFetchRequest<CDUserFollow> = CDUserFollow.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", follow.id)
            request.fetchLimit = 1
            
            do {
                let existingFollows = try context.fetch(request)
                let cdFollow: CDUserFollow
                
                if let existing = existingFollows.first {
                    cdFollow = existing
                    cdFollow.updateFromUserFollow(follow)
                } else {
                    cdFollow = CDUserFollow(context: context, follow: follow)
                }
                
                self.coreDataStack.save()
                promise(.success(cdFollow.toUserFollow()))
            } catch {
                print("❌ Failed to save user follow: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteUserFollow(id: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<CDUserFollow> = CDUserFollow.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let follows = try context.fetch(request)
                follows.forEach { context.delete($0) }
                self.coreDataStack.save()
                promise(.success(()))
            } catch {
                print("❌ Failed to delete user follow: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Data Migration and Initialization
    
    func initializeWithSampleData() {
        // 이미 데이터가 있는지 확인
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<CDRestaurant> = CDRestaurant.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                print("🚀 Initializing Core Data with sample data...")
                migrateSampleDataToCoreData()
            } else {
                print("✅ Core Data already has data, skipping initialization")
            }
        } catch {
            print("❌ Failed to check existing data: \(error)")
        }
    }
    
    private func migrateSampleDataToCoreData() {
        let context = coreDataStack.newBackgroundContext()
        
        context.perform {
            // 샘플 레스토랑 데이터 생성
            let sampleRestaurants = self.createSampleRestaurants()
            
            sampleRestaurants.forEach { restaurant in
                _ = CDRestaurant(context: context, restaurant: restaurant)
            }
            
            self.coreDataStack.saveContext(context)
            print("✅ Sample data migration completed")
        }
    }
    
    private func createSampleRestaurants() -> [Restaurant] {
        return [
            Restaurant(
                id: "rest1",
                name: "명동교자",
                category: .korean,
                address: "서울특별시 중구 명동2가 25-2",
                coordinate: Coordinate(latitude: 37.5638, longitude: 126.9838),
                phoneNumber: "02-776-5348",
                rating: 4.2,
                reviewCount: 1245,
                priceRange: .low,
                openingHours: nil,
                description: "60년 전통의 명동 대표 만두집",
                imageURLs: [],
                isFavorite: false
            ),
            Restaurant(
                id: "rest2",
                name: "진미평양냉면",
                category: .korean,
                address: "서울특별시 중구 을지로3가 229",
                coordinate: Coordinate(latitude: 37.5668, longitude: 126.9918),
                phoneNumber: "02-2265-3629",
                rating: 4.4,
                reviewCount: 856,
                priceRange: .low,
                openingHours: nil,
                description: "을지로 숨은 평양냉면 맛집",
                imageURLs: [],
                isFavorite: false
            ),
            Restaurant(
                id: "rest3",
                name: "스시 조",
                category: .japanese,
                address: "서울특별시 강남구 신사동 549-7",
                coordinate: Coordinate(latitude: 37.5170, longitude: 127.0226),
                phoneNumber: "02-540-8884",
                rating: 4.7,
                reviewCount: 324,
                priceRange: .high,
                openingHours: nil,
                description: "신사동 프리미엄 스시 오마카세",
                imageURLs: [],
                isFavorite: true
            )
        ]
    }
}