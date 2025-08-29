import SwiftUI
import CoreLocation

struct HomeView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    CategoryScrollView()
                    
                    FeaturedSection(title: "인기 맛집", restaurants: sampleRestaurants)
                    
                    FeaturedSection(title: "새로 오픈한 맛집", restaurants: sampleRestaurants)
                    
                    FeaturedSection(title: "내 주변 맛집", restaurants: sampleRestaurants)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("맛집 탐험")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("맛집, 음식 종류를 검색해보세요", text: $text)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct CategoryScrollView: View {
    let categories = RestaurantCategory.allCases
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(categories, id: \.self) { category in
                    CategoryCard(category: category)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryCard: View {
    let category: RestaurantCategory
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.systemImage)
                .font(.system(size: 24))
                .foregroundColor(.orange)
            
            Text(category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(width: 70, height: 70)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FeaturedSection: View {
    let title: String
    let restaurants: [Restaurant]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                Spacer()
                
                Button("더보기") {
                    // Navigate to full list
                }
                .foregroundColor(.orange)
                .padding(.trailing)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(restaurants.prefix(5)) { restaurant in
                        RestaurantCard(restaurant: restaurant)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct RestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: restaurant.imageURLs.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 200, height: 120)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("\(restaurant.rating, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("(\(restaurant.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(restaurant.priceRange.displayText)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Text(restaurant.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 200)
    }
}

// Sample data for preview
let sampleRestaurants = [
    Restaurant(
        id: "1",
        name: "맛있는 한식당",
        category: .korean,
        address: "서울시 강남구 테헤란로 123",
        coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        phoneNumber: "02-1234-5678",
        rating: 4.5,
        reviewCount: 128,
        priceRange: .medium,
        openingHours: nil,
        description: "전통 한식을 현대적으로 재해석한 맛집",
        imageURLs: [],
        isFavorite: false
    ),
    Restaurant(
        id: "2",
        name: "이탈리안 레스토랑",
        category: .western,
        address: "서울시 서초구 반포대로 456",
        coordinate: CLLocationCoordinate2D(latitude: 37.5013, longitude: 127.0269),
        phoneNumber: "02-9876-5432",
        rating: 4.8,
        reviewCount: 89,
        priceRange: .high,
        openingHours: nil,
        description: "정통 이탈리안 요리를 맛볼 수 있는 곳",
        imageURLs: [],
        isFavorite: true
    )
]

#Preview {
    HomeView()
}