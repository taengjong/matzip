import Foundation
import SwiftUI
import CoreLocation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favoriteRestaurants: [Restaurant] = []
    @Published var userRestaurantLists: [UserRestaurantList] = []
    @Published var selectedTab: FavoritesTab = .favorites
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showingCreateListSheet = false
    
    private let coreDataService = CoreDataService()
    private let userManager = UserManager.shared
    private var userRestaurantService: UserRestaurantService?
    private var cancellables = Set<AnyCancellable>()
    
    enum FavoritesTab: String, CaseIterable {
        case favorites = "즐겨찾기"
        case lists = "내 리스트"
        
        var systemImage: String {
            switch self {
            case .favorites: return "heart.fill"
            case .lists: return "list.bullet"
            }
        }
    }
    
    init() {
        setupUserService()
        loadFavoritesData()
    }
    
    private func setupUserService() {
        guard let userId = userManager.getCurrentUserId() else { return }
        userRestaurantService = UserRestaurantService(userId: userId)
    }
    
    func loadFavoritesData() {
        isLoading = true
        error = nil
        
        // Core Data에서 즐겨찾기 레스토랑 로드
        coreDataService.fetchFavoriteRestaurants()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to load favorite restaurants: \(error)")
                        self.error = error
                    }
                    self.isLoading = false
                },
                receiveValue: { restaurants in
                    self.favoriteRestaurants = restaurants
                }
            )
            .store(in: &cancellables)
        
        // 사용자 리스트도 로드
        loadUserRestaurantLists()
    }
    
    func refreshData() {
        loadFavoritesData()
    }
    
    func selectTab(_ tab: FavoritesTab) {
        selectedTab = tab
    }
    
    // MARK: - 즐겨찾기 관리
    
    func toggleFavorite(restaurant: Restaurant) {
        coreDataService.toggleRestaurantFavorite(restaurant.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to toggle favorite: \(error)")
                        self.error = error
                    }
                },
                receiveValue: { isFavorite in
                    if isFavorite {
                        // 즐겨찾기에 추가됨
                        if !self.favoriteRestaurants.contains(where: { $0.id == restaurant.id }) {
                            var updatedRestaurant = restaurant
                            updatedRestaurant.isFavorite = true
                            self.favoriteRestaurants.append(updatedRestaurant)
                        }
                    } else {
                        // 즐겨찾기에서 제거됨
                        self.favoriteRestaurants.removeAll { $0.id == restaurant.id }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func removeFavorite(restaurant: Restaurant) {
        coreDataService.toggleRestaurantFavorite(restaurant.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to remove favorite: \(error)")
                        self.error = error
                    }
                },
                receiveValue: { _ in
                    self.favoriteRestaurants.removeAll { $0.id == restaurant.id }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - 맛집 리스트 관리
    
    func createRestaurantList(name: String, description: String?, isPublic: Bool) {
        userRestaurantService?.createRestaurantList(
            name: name,
            description: description,
            isPublic: isPublic
        )
        loadUserRestaurantLists()
        showingCreateListSheet = false
    }
    
    func deleteRestaurantList(list: UserRestaurantList) {
        userRestaurantService?.deleteRestaurantList(listId: list.id)
        userRestaurantLists.removeAll { $0.id == list.id }
    }
    
    func addRestaurantToList(restaurant: Restaurant, list: UserRestaurantList) {
        userRestaurantService?.addRestaurantToList(
            restaurantId: restaurant.id,
            listId: list.id
        )
        loadUserRestaurantLists()
    }
    
    func removeRestaurantFromList(restaurant: Restaurant, list: UserRestaurantList) {
        userRestaurantService?.removeRestaurantFromList(
            restaurantId: restaurant.id,
            listId: list.id
        )
        loadUserRestaurantLists()
    }
    
    func toggleListVisibility(list: UserRestaurantList) {
        // 리스트 공개/비공개 토글
        let updatedList = UserRestaurantList(
            id: list.id,
            userId: list.userId,
            name: list.name,
            description: list.description,
            restaurantIds: list.restaurantIds,
            isPublic: !list.isPublic,
            createdAt: list.createdAt,
            updatedAt: Date()
        )
        
        // 실제로는 서비스에서 업데이트 메서드를 호출
        if let index = userRestaurantLists.firstIndex(where: { $0.id == list.id }) {
            userRestaurantLists[index] = updatedList
        }
    }
    
    // MARK: - Private Methods
    
    private func loadFavoriteRestaurants() {
        // 실제로는 즐겨찾기한 맛집 ID들을 기반으로 맛집 정보를 가져옴
        favoriteRestaurants = generateSampleFavoriteRestaurants()
    }
    
    private func loadUserRestaurantLists() {
        userRestaurantLists = userRestaurantService?.userRestaurantLists ?? []
    }
    
    private func generateSampleFavoriteRestaurants() -> [Restaurant] {
        return [
            Restaurant(
                id: "favorite_1",
                name: "내가 좋아하는 맛집",
                category: .korean,
                address: "서울시 강남구 테헤란로 123",
                coordinate: Coordinate(latitude: 37.5665, longitude: 126.9780),
                phoneNumber: "02-1234-5678",
                rating: 4.8,
                reviewCount: 156,
                priceRange: .medium,
                openingHours: nil,
                description: "정말 맛있는 한식집입니다.",
                imageURLs: [],
                isFavorite: true
            ),
            Restaurant(
                id: "favorite_2",
                name: "즐겨 가는 카페",
                category: .cafe,
                address: "서울시 홍대입구역 근처",
                coordinate: Coordinate(latitude: 37.5563, longitude: 126.9236),
                phoneNumber: "02-2345-6789",
                rating: 4.6,
                reviewCount: 89,
                priceRange: .low,
                openingHours: nil,
                description: "분위기 좋은 카페입니다.",
                imageURLs: [],
                isFavorite: true
            ),
            Restaurant(
                id: "favorite_3",
                name: "단골 초밥집",
                category: .japanese,
                address: "서울시 명동 중심가",
                coordinate: Coordinate(latitude: 37.5636, longitude: 126.9822),
                phoneNumber: "02-3456-7890",
                rating: 4.9,
                reviewCount: 234,
                priceRange: .high,
                openingHours: nil,
                description: "신선한 초밥을 즐길 수 있습니다.",
                imageURLs: [],
                isFavorite: true
            )
        ]
    }
}