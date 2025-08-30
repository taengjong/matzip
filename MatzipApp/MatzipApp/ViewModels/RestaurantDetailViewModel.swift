import Foundation
import SwiftUI
import CoreLocation
import Combine

class RestaurantDetailViewModel: ObservableObject {
    @Published var restaurant: Restaurant
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var showingReviewForm = false
    @Published var showingPhotos = false
    @Published var showingMap = false
    @Published var error: Error?
    
    var isFavorite: Bool {
        restaurant.isFavorite
    }
    
    private let userRestaurantService: UserRestaurantService
    private let coreDataService = CoreDataService()
    private let currentUserId: String
    private var cancellables = Set<AnyCancellable>()
    
    init(restaurant: Restaurant, userId: String, userRestaurantService: UserRestaurantService) {
        self.restaurant = restaurant
        self.currentUserId = userId
        self.userRestaurantService = userRestaurantService
        loadRestaurantDetails()
    }
    
    func loadRestaurantDetails() {
        isLoading = true
        
        // Core Data에서 최신 맛집 정보 로드
        coreDataService.fetchRestaurant(by: restaurant.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to load restaurant details: \(error)")
                        self.error = error
                    }
                },
                receiveValue: { restaurant in
                    if let updatedRestaurant = restaurant {
                        self.restaurant = updatedRestaurant
                    }
                    self.loadReviews()
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadReviews() {
        coreDataService.fetchReviews(for: restaurant.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to load reviews: \(error)")
                        // 실패 시 샘플 리뷰로 폴백
                        self.reviews = self.generateSampleReviews()
                    }
                    self.isLoading = false
                },
                receiveValue: { reviews in
                    if reviews.isEmpty {
                        // 리뷰가 없으면 샘플 리뷰 사용
                        self.reviews = self.generateSampleReviews()
                    } else {
                        self.reviews = reviews
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleFavorite() {
        restaurant.isFavorite.toggle()
        
        // Core Data에 변경사항 저장
        coreDataService.saveRestaurant(restaurant)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to update favorite status: \(error)")
                        // 실패 시 상태 되돌리기
                        self.restaurant.isFavorite.toggle()
                    }
                },
                receiveValue: { updatedRestaurant in
                    self.restaurant = updatedRestaurant
                    print("✅ Favorite status updated successfully")
                }
            )
            .store(in: &cancellables)
        
        // 기존 UserRestaurantService도 업데이트
        if restaurant.isFavorite {
            userRestaurantService.addToFavorites(restaurantId: restaurant.id)
        } else {
            userRestaurantService.removeFromFavorites(restaurantId: restaurant.id)
        }
    }
    
    func callRestaurant() {
        guard let phoneNumber = restaurant.phoneNumber else { return }
        
        if let url = URL(string: "tel://\(phoneNumber.replacingOccurrences(of: "-", with: ""))") {
            UIApplication.shared.open(url)
        }
    }
    
    func openInMaps() {
        let coordinate = restaurant.clLocationCoordinate
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    func shareRestaurant() {
        // 공유 기능 - 실제로는 공유 시트 표시
        print("맛집 공유: \(restaurant.name)")
    }
    
    func showReviewForm() {
        showingReviewForm = true
    }
    
    func addReview(rating: Double, content: String, imageURLs: [String] = []) {
        let newReview = Review(
            id: UUID().uuidString,
            restaurantId: restaurant.id,
            userId: currentUserId,
            userName: "현재 사용자",
            userProfileImage: nil,
            rating: rating,
            content: content,
            imageURLs: imageURLs,
            createdAt: Date(),
            updatedAt: nil
        )
        
        // Core Data에 리뷰 저장
        coreDataService.saveReview(newReview)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to save review: \(error)")
                        self.error = error
                    }
                },
                receiveValue: { savedReview in
                    self.reviews.insert(savedReview, at: 0)
                    self.updateRestaurantRating()
                    print("✅ Review saved successfully")
                }
            )
            .store(in: &cancellables)
        
        showingReviewForm = false
    }
    
    // MARK: - Private Methods
    
    
    private func checkFavoriteStatus() {
        restaurant.isFavorite = userRestaurantService.isFavorite(restaurantId: restaurant.id)
    }
    
    private func updateRestaurantRating() {
        let totalRating = reviews.reduce(0) { $0 + $1.rating }
        let newRating = totalRating / Double(reviews.count)
        
        restaurant.rating = newRating
        restaurant.reviewCount = reviews.count
        
        // Core Data에 업데이트된 맛집 정보 저장
        coreDataService.saveRestaurant(restaurant)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to update restaurant rating: \(error)")
                    }
                },
                receiveValue: { updatedRestaurant in
                    self.restaurant = updatedRestaurant
                    print("✅ Restaurant rating updated successfully")
                }
            )
            .store(in: &cancellables)
    }
    
    private func generateSampleReviews() -> [Review] {
        [
            Review(
                id: "review1",
                restaurantId: restaurant.id,
                userId: "user1",
                userName: "김맛집",
                userProfileImage: nil,
                rating: 4.5,
                content: "정말 맛있었어요! 분위기도 좋고 서비스도 친절합니다. 다음에 또 오고 싶은 곳이에요.",
                imageURLs: [],
                createdAt: Date().addingTimeInterval(-86400 * 2),
                updatedAt: nil
            ),
            Review(
                id: "review2",
                restaurantId: restaurant.id,
                userId: "user2",
                userName: "박푸드",
                userProfileImage: nil,
                rating: 5.0,
                content: "최고의 맛집입니다! 재료가 신선하고 요리사님의 정성이 느껴져요. 강력 추천!",
                imageURLs: [],
                createdAt: Date().addingTimeInterval(-86400 * 5),
                updatedAt: nil
            ),
            Review(
                id: "review3",
                restaurantId: restaurant.id,
                userId: "user3",
                userName: "이미식가",
                userProfileImage: nil,
                rating: 4.0,
                content: "가성비 좋은 맛집이네요. 양도 많고 맛도 괜찮습니다. 주차가 조금 불편해요.",
                imageURLs: [],
                createdAt: Date().addingTimeInterval(-86400 * 7),
                updatedAt: nil
            )
        ]
    }
}

// MARK: - Import MapKit
import MapKit