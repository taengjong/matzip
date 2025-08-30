import Foundation
import SwiftUI

class RestaurantListDetailViewModel: ObservableObject {
    @Published var list: UserRestaurantList
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var showingAddRestaurant = false
    @Published var error: Error?
    
    private let userRestaurantService: UserRestaurantService
    private let currentUserId = "current_user"
    
    init(list: UserRestaurantList) {
        self.list = list
        self.userRestaurantService = UserRestaurantService(userId: currentUserId)
        loadRestaurants()
    }
    
    func loadRestaurants() {
        isLoading = true
        
        // 실제로는 서버에서 맛집 정보들을 가져옴
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.restaurants = self.generateSampleRestaurants()
            self.isLoading = false
        }
    }
    
    func addRestaurant(_ restaurant: Restaurant) {
        // 이미 리스트에 있는지 확인
        guard !list.restaurantIds.contains(restaurant.id) else { return }
        
        // 리스트에 추가
        userRestaurantService.addRestaurantToList(
            restaurantId: restaurant.id,
            listId: list.id
        )
        
        // UI 업데이트
        restaurants.append(restaurant)
        updateList()
        showingAddRestaurant = false
    }
    
    func removeRestaurant(_ restaurant: Restaurant) {
        userRestaurantService.removeRestaurantFromList(
            restaurantId: restaurant.id,
            listId: list.id
        )
        
        restaurants.removeAll { $0.id == restaurant.id }
        updateList()
    }
    
    func toggleListVisibility() {
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
        
        self.list = updatedList
    }
    
    func shareList() {
        // 리스트 공유 기능
        print("리스트 공유: \(list.name)")
    }
    
    // MARK: - Private Methods
    
    private func updateList() {
        list = UserRestaurantList(
            id: list.id,
            userId: list.userId,
            name: list.name,
            description: list.description,
            restaurantIds: restaurants.map { $0.id },
            isPublic: list.isPublic,
            createdAt: list.createdAt,
            updatedAt: Date()
        )
    }
    
    private func generateSampleRestaurants() -> [Restaurant] {
        // 리스트에 포함된 맛집들의 상세 정보를 시뮬레이션
        let sampleRestaurants = [
            Restaurant(
                id: "rest1",
                name: "전통 한정식 맛집",
                category: .korean,
                address: "서울시 종로구 인사동길 12",
                coordinate: Coordinate(latitude: 37.5735, longitude: 126.9854),
                phoneNumber: "02-1234-5678",
                rating: 4.6,
                reviewCount: 89,
                priceRange: .high,
                openingHours: nil,
                description: "3대째 이어온 전통 한정식집. 정성스러운 상차림과 깊은 맛이 일품입니다.",
                imageURLs: [],
                isFavorite: true
            ),
            Restaurant(
                id: "rest2",
                name: "소문난 삼계탕",
                category: .korean,
                address: "서울시 중구 명동 2가 54-2",
                coordinate: Coordinate(latitude: 37.5636, longitude: 126.9822),
                phoneNumber: "02-2345-6789",
                rating: 4.4,
                reviewCount: 156,
                priceRange: .medium,
                openingHours: nil,
                description: "신선한 재료로 끓인 진한 국물의 삼계탕 전문점입니다.",
                imageURLs: [],
                isFavorite: false
            ),
            Restaurant(
                id: "rest3",
                name: "한옥 비빔밥집",
                category: .korean,
                address: "서울시 강남구 신사동 542-3",
                coordinate: Coordinate(latitude: 37.5200, longitude: 127.0230),
                phoneNumber: "02-3456-7890",
                rating: 4.3,
                reviewCount: 203,
                priceRange: .medium,
                openingHours: nil,
                description: "전통 한옥에서 즐기는 건강한 비빔밥과 나물 반찬들.",
                imageURLs: [],
                isFavorite: false
            ),
            Restaurant(
                id: "rest4",
                name: "궁중떡볶이",
                category: .korean,
                address: "서울시 마포구 홍대입구역 2번 출구",
                coordinate: Coordinate(latitude: 37.5563, longitude: 126.9236),
                phoneNumber: "02-4567-8901",
                rating: 4.1,
                reviewCount: 78,
                priceRange: .low,
                openingHours: nil,
                description: "매콤달콤한 궁중떡볶이와 다양한 분식 메뉴.",
                imageURLs: [],
                isFavorite: true
            )
        ]
        
        // 리스트의 restaurantIds와 매칭되는 맛집들만 반환
        return sampleRestaurants.filter { restaurant in
            list.restaurantIds.contains(restaurant.id)
        }
    }
}