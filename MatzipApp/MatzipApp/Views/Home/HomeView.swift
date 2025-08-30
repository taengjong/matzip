import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var showingMapView = false
    
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
                        PulsingLoadingView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .scaleTransition(isActive: true)
                    } else {
                        VStack(spacing: 20) {
                            FeaturedSection(title: "추천 맛집", restaurants: viewModel.recommendedRestaurants)
                                .fadeSlideTransition(isActive: true, offset: 30)
                            
                            FeaturedSection(title: "인기 맛집", restaurants: viewModel.popularRestaurants)
                                .fadeSlideTransition(isActive: true, offset: 40)
                            
                            FeaturedSection(title: "내 주변 맛집", restaurants: viewModel.nearbyRestaurants)
                                .fadeSlideTransition(isActive: true, offset: 50)
                            
                            // 지도에서 보기 버튼
                            MapViewButton(onTap: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                showingMapView = true
                            })
                            .padding(.horizontal)
                            .fadeSlideTransition(isActive: true, offset: 60)
                        }
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
        .sheet(isPresented: $showingMapView) {
            MapView()
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
                    ForEach(Array(restaurants.prefix(5).enumerated()), id: \.element.id) { index, restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                            AnimatedCard {
                                RestaurantCard(restaurant: restaurant)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .restaurantCardTransition(index: index)
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
        category: .italian,
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

struct MapViewButton: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("지도에서 보기")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("주변 맛집을 지도로 한눈에 확인하세요")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isPressed ? 5 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(color: .orange.opacity(isPressed ? 0.6 : 0.3), radius: isPressed ? 12 : 8, x: 0, y: isPressed ? 6 : 4)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    HomeView()
}