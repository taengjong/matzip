import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Restaurant] = []
    @Published var userSearchResults: [User] = []
    @Published var selectedSearchType: SearchType = .restaurant
    @Published var selectedCategory: RestaurantCategory?
    @Published var selectedPriceRange: PriceRange?
    @Published var isLoading = false
    @Published var hasSearched = false
    
    private var allRestaurants: [Restaurant] = []
    private var allUsers: [User] = []
    
    enum SearchType: String, CaseIterable {
        case restaurant = "맛집"
        case user = "사용자"
        
        var systemImage: String {
            switch self {
            case .restaurant: return "fork.knife"
            case .user: return "person.2"
            }
        }
    }
    
    init() {
        loadInitialData()
    }
    
    func search() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            clearResults()
            return
        }
        
        isLoading = true
        hasSearched = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch self.selectedSearchType {
            case .restaurant:
                self.searchRestaurants()
            case .user:
                self.searchUsers()
            }
            self.isLoading = false
        }
    }
    
    func clearSearch() {
        searchText = ""
        clearResults()
    }
    
    func selectSearchType(_ type: SearchType) {
        selectedSearchType = type
        if hasSearched {
            search()
        }
    }
    
    func applyFilters() {
        if hasSearched && selectedSearchType == .restaurant {
            search()
        }
    }
    
    func clearFilters() {
        selectedCategory = nil
        selectedPriceRange = nil
        applyFilters()
    }
    
    private func searchRestaurants() {
        var results = allRestaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(searchText) ||
            restaurant.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
            restaurant.address.localizedCaseInsensitiveContains(searchText)
        }
        
        // 카테고리 필터 적용
        if let category = selectedCategory {
            results = results.filter { $0.category == category }
        }
        
        // 가격대 필터 적용
        if let priceRange = selectedPriceRange {
            results = results.filter { $0.priceRange == priceRange }
        }
        
        // 평점순으로 정렬
        results.sort { $0.rating > $1.rating }
        
        searchResults = results
    }
    
    private func searchUsers() {
        let results = allUsers.filter { user in
            user.name.localizedCaseInsensitiveContains(searchText) ||
            (user.bio?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        
        // 팔로워 수순으로 정렬
        userSearchResults = results.sorted { $0.followersCount > $1.followersCount }
    }
    
    private func clearResults() {
        searchResults = []
        userSearchResults = []
        hasSearched = false
    }
    
    private func loadInitialData() {
        // 샘플 데이터 로드
        allRestaurants = generateSampleRestaurants()
        allUsers = SampleData.sampleFollowers + SampleData.sampleFollowing + SampleData.sampleSuggestedUsers
    }
    
    private func generateSampleRestaurants() -> [Restaurant] {
        let categories = RestaurantCategory.allCases
        let names = [
            "강남맛집", "홍대핫플", "명동맛집", "이태원레스토랑", "신촌카페",
            "건대맛집", "인사동전통집", "마포갈비", "용산스시", "종로냉면",
            "압구정파스타", "청담디저트", "서초비빔밥", "잠실치킨", "송파족발"
        ]
        
        return (0..<100).map { index in
            let category = categories.randomElement()!
            let baseName = names.randomElement()!
            let name = "\(baseName) \(index + 1)호점"
            
            return Restaurant(
                id: "search_restaurant_\(index)",
                name: name,
                category: category,
                address: "서울시 강남구 테헤란로 \(index + 100)",
                coordinate: CLLocationCoordinate2D(
                    latitude: 37.5665 + Double.random(in: -0.05...0.05),
                    longitude: 126.9780 + Double.random(in: -0.05...0.05)
                ),
                phoneNumber: "02-\(1000 + index)-\(String(format: "%04d", index))",
                rating: Double.random(in: 3.0...5.0),
                reviewCount: Int.random(in: 5...300),
                priceRange: PriceRange.allCases.randomElement()!,
                openingHours: nil,
                description: "\(category.rawValue) 전문점입니다.",
                imageURLs: [],
                isFavorite: Bool.random()
            )
        }
    }
}