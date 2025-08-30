import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showingRestaurantDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 지도
                Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.restaurants) { restaurant in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: restaurant.coordinate.latitude,
                        longitude: restaurant.coordinate.longitude
                    )) {
                        RestaurantMapPin(
                            restaurant: restaurant,
                            isSelected: viewModel.selectedRestaurant?.id == restaurant.id,
                            onTap: {
                                viewModel.selectRestaurant(restaurant)
                            }
                        )
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    // 상단 필터 바
                    MapFilterBar(
                        selectedCategory: viewModel.selectedCategory,
                        onCategoryChange: viewModel.filterRestaurants
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // 하단 선택된 맛집 카드
                    if let selectedRestaurant = viewModel.selectedRestaurant {
                        SelectedRestaurantCard(
                            restaurant: selectedRestaurant,
                            onDetailTap: {
                                showingRestaurantDetail = true
                            },
                            onClose: {
                                viewModel.selectedRestaurant = nil
                            }
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: viewModel.selectedRestaurant)
                    }
                }
                
                // 현재 위치 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: viewModel.moveToCurrentLocation) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, viewModel.selectedRestaurant != nil ? 180 : 100)
                    }
                }
            }
            .navigationTitle("맛집 지도")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.loadRestaurants()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $showingRestaurantDetail) {
            if let restaurant = viewModel.selectedRestaurant {
                RestaurantDetailView(restaurant: restaurant)
            }
        }
        .onAppear {
            if viewModel.restaurants.isEmpty {
                viewModel.loadRestaurants()
            }
        }
    }
}

struct RestaurantMapPin: View {
    let restaurant: Restaurant
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // 핀 아이콘
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange : Color.white)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.orange, lineWidth: 3)
                        )
                    
                    Image(systemName: restaurant.category.systemImage)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .orange)
                }
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.spring(), value: isSelected)
                
                // 맛집 이름 (선택된 경우만)
                if isSelected {
                    Text(restaurant.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(radius: 2)
                        )
                        .lineLimit(1)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MapFilterBar: View {
    let selectedCategory: RestaurantCategory
    let onCategoryChange: (RestaurantCategory) -> Void
    
    let categories: [RestaurantCategory] = [.all, .korean, .italian, .japanese, .chinese, .mexican]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    FilterChip(
                        title: category.displayName,
                        isSelected: selectedCategory == category,
                        onTap: {
                            onCategoryChange(category)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.orange : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectedRestaurantCard: View {
    let restaurant: Restaurant
    let onDetailTap: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 맛집 이미지 또는 카테고리 아이콘
            if let imageURL = restaurant.imageURLs.first {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    categoryIconView
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                categoryIconView
            }
            
            // 맛집 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(restaurant.category.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(restaurant.rating, specifier: "%.1f")")
                            .font(.caption)
                    }
                    
                    Text(restaurant.priceRange.displayText)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                Button(action: onDetailTap) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var categoryIconView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange.opacity(0.1))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: restaurant.category.systemImage)
                    .foregroundColor(.orange)
                    .font(.title2)
            )
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}