import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    CategoryScrollView(
                        selectedCategory: viewModel.selectedCategory,
                        onCategorySelected: viewModel.selectCategory
                    )
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemBackground))
                    } else {
                        FeaturedSection(title: "추천 맛집", restaurants: viewModel.recommendedRestaurants)
                        
                        FeaturedSection(title: "인기 맛집", restaurants: viewModel.popularRestaurants)
                        
                        FeaturedSection(title: "내 주변 맛집", restaurants: viewModel.nearbyRestaurants)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("맛집 탐험")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.refreshData()
            }
        }
        .onAppear {
            if viewModel.recommendedRestaurants.isEmpty {
                viewModel.loadInitialData()
            }
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
    let selectedCategory: RestaurantCategory?
    let onCategorySelected: (RestaurantCategory?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                // "전체" 버튼 추가
                CategoryCard(
                    category: nil,
                    isSelected: selectedCategory == nil,
                    onTap: { onCategorySelected(nil) }
                )
                
                ForEach(categories, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: { onCategorySelected(category) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryCard: View {
    let category: RestaurantCategory?
    let isSelected: Bool
    let onTap: () -> Void
    
    init(category: RestaurantCategory? = nil, isSelected: Bool = false, onTap: @escaping () -> Void) {
        self.category = category
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: category?.systemImage ?? "list.bullet")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .orange)
                
                Text(category?.rawValue ?? "전체")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
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
        coordinate: Coordinate(latitude: 37.5665, longitude: 126.9780),
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
        coordinate: Coordinate(latitude: 37.5013, longitude: 127.0269),
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