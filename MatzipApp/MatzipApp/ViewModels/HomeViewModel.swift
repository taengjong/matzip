import Foundation
import SwiftUI
import CoreLocation
import Combine

class HomeViewModel: ObservableObject {
    @Published var recommendedRestaurants: [Restaurant] = []
    @Published var popularRestaurants: [Restaurant] = []
    @Published var nearbyRestaurants: [Restaurant] = []
    @Published var selectedCategory: RestaurantCategory?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var allRestaurants: [Restaurant] = []
    private let coreDataService = CoreDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Core Data 초기화 시 샘플 데이터 마이그레이션
        coreDataService.initializeWithSampleData()
        loadInitialData()
    }
    
    func loadInitialData() {
        isLoading = true
        
        coreDataService.fetchRestaurants()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to load restaurants: \(error)")
                        self.error = error
                        // 실패 시 샘플 데이터로 폴백
                        self.loadSampleDataFallback()
                    }
                    self.isLoading = false
                },
                receiveValue: { restaurants in
                    self.allRestaurants = restaurants
                    self.updateRestaurantCategories()
                    self.error = nil
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadSampleDataFallback() {
        self.allRestaurants = self.generateSampleRestaurants()
        self.updateRestaurantCategories()
    }
    
    func refreshData() {
        loadInitialData()
    }
    
    func selectCategory(_ category: RestaurantCategory?) {
        selectedCategory = category
        updateRestaurantCategories()
    }
    
    private func updateRestaurantCategories() {
        let filteredRestaurants = selectedCategory == nil ? 
            allRestaurants : 
            allRestaurants.filter { $0.category == selectedCategory }
        
        // 카테고리별로 맛집을 분류
        recommendedRestaurants = Array(filteredRestaurants.filter { $0.rating >= 4.5 }.prefix(10))
        popularRestaurants = Array(filteredRestaurants.sorted { $0.reviewCount > $1.reviewCount }.prefix(10))
        nearbyRestaurants = Array(filteredRestaurants.shuffled().prefix(10)) // 실제로는 위치 기반 정렬
    }
    
    private func generateSampleRestaurants() -> [Restaurant] {
        let categories = RestaurantCategory.allCases
        let names = [
            "맛있는집", "행복한식당", "즐거운카페", "멋진레스토랑", "따뜻한밥집",
            "신선한초밥집", "달콤한디저트", "향긋한커피", "푸짐한한정식", "특별한양식당",
            "전통찻집", "모던비스트로", "아늑한술집", "건강한샐러드", "정성스런국밥집"
        ]
        let addresses = [
            "서울시 강남구 테헤란로 123", "서울시 홍대입구역 근처", "서울시 명동 중심가",
            "서울시 이태원동 234-56", "서울시 신촌역 2번출구", "서울시 건대입구역 근처",
            "서울시 종로구 인사동길", "서울시 마포구 홍익로", "서울시 용산구 이태원로"
        ]
        
        return (0..<50).map { index in
            let category = categories.randomElement()!
            let name = names.randomElement()! + " \(index + 1)"
            let address = addresses.randomElement()!
            let rating = Double.random(in: 3.5...5.0)
            let reviewCount = Int.random(in: 10...500)
            let priceRange = PriceRange.allCases.randomElement()!
            
            return Restaurant(
                id: "restaurant_\(index)",
                name: name,
                category: category,
                address: address,
                coordinate: Coordinate(
                    latitude: 37.5665 + Double.random(in: -0.1...0.1),
                    longitude: 126.9780 + Double.random(in: -0.1...0.1)
                ),
                phoneNumber: "02-1234-567\(index % 10)",
                rating: rating,
                reviewCount: reviewCount,
                priceRange: priceRange,
                openingHours: nil,
                description: "\(category.rawValue) 전문점입니다. 신선한 재료로 맛있는 음식을 제공합니다.",
                imageURLs: [],
                isFavorite: Bool.random()
            )
        }
    }
}