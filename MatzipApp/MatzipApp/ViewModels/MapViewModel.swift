import Foundation
import MapKit
import SwiftUI

class MapViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var selectedRestaurant: Restaurant?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // 서울 중심
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var isLoading = false
    @Published var selectedCategory: RestaurantCategory = .all
    
    private let locationManager = CLLocationManager()
    
    init() {
        loadRestaurants()
        setupLocationManager()
    }
    
    func loadRestaurants() {
        isLoading = true
        
        // 실제로는 서버에서 맛집 데이터를 가져옴
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.restaurants = self.generateSampleRestaurants()
            self.isLoading = false
        }
    }
    
    func filterRestaurants(by category: RestaurantCategory) {
        selectedCategory = category
        loadRestaurants() // 전체 데이터를 다시 로드한 후 필터링
        
        if category != .all {
            restaurants = restaurants.filter { $0.category == category }
        }
    }
    
    func selectRestaurant(_ restaurant: Restaurant) {
        selectedRestaurant = restaurant
        // 선택된 맛집 위치로 지도 중심 이동
        withAnimation {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: restaurant.coordinate.latitude,
                    longitude: restaurant.coordinate.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func moveToCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        if let location = locationManager.location {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Sample Data
    
    private func generateSampleRestaurants() -> [Restaurant] {
        return [
            Restaurant(
                id: "map_rest1",
                name: "경복궁 한정식",
                category: .korean,
                address: "서울시 종로구 사직로 161",
                coordinate: Coordinate(latitude: 37.5796, longitude: 126.9770),
                phoneNumber: "02-3700-3900",
                rating: 4.8,
                reviewCount: 234,
                priceRange: .high,
                openingHours: nil,
                description: "경복궁 근처의 전통 한정식 맛집",
                imageURLs: [],
                isFavorite: false
            ),
            Restaurant(
                id: "map_rest2",
                name: "명동 칼국수",
                category: .korean,
                address: "서울시 중구 명동길 74",
                coordinate: Coordinate(latitude: 37.5636, longitude: 126.9822),
                phoneNumber: "02-318-8292",
                rating: 4.5,
                reviewCount: 567,
                priceRange: .low,
                openingHours: nil,
                description: "명동의 유명한 칼국수 전문점",
                imageURLs: [],
                isFavorite: true
            ),
            Restaurant(
                id: "map_rest3",
                name: "강남 이탈리안",
                category: .italian,
                address: "서울시 강남구 테헤란로 152",
                coordinate: Coordinate(latitude: 37.5000, longitude: 127.0270),
                phoneNumber: "02-2187-3456",
                rating: 4.6,
                reviewCount: 189,
                priceRange: .medium,
                openingHours: nil,
                description: "정통 이탈리안 요리 전문점",
                imageURLs: [],
                isFavorite: false
            ),
            Restaurant(
                id: "map_rest4",
                name: "홍대 파스타",
                category: .italian,
                address: "서울시 마포구 와우산로 94",
                coordinate: Coordinate(latitude: 37.5563, longitude: 126.9236),
                phoneNumber: "02-324-7890",
                rating: 4.3,
                reviewCount: 298,
                priceRange: .medium,
                openingHours: nil,
                description: "홍대 젊은이들이 사랑하는 파스타 맛집",
                imageURLs: [],
                isFavorite: false
            ),
            Restaurant(
                id: "map_rest5",
                name: "신촌 일식",
                category: .japanese,
                address: "서울시 서대문구 신촌로 83",
                coordinate: Coordinate(latitude: 37.5551, longitude: 126.9366),
                phoneNumber: "02-393-2468",
                rating: 4.4,
                reviewCount: 156,
                priceRange: .medium,
                openingHours: nil,
                description: "신선한 회와 초밥을 제공하는 일식당",
                imageURLs: [],
                isFavorite: true
            ),
            Restaurant(
                id: "map_rest6",
                name: "이태원 멕시칸",
                category: .mexican,
                address: "서울시 용산구 이태원로 177",
                coordinate: Coordinate(latitude: 37.5349, longitude: 126.9945),
                phoneNumber: "02-797-1357",
                rating: 4.2,
                reviewCount: 134,
                priceRange: .medium,
                openingHours: nil,
                description: "정통 멕시칸 타코와 부리또",
                imageURLs: [],
                isFavorite: false
            )
        ]
    }
}