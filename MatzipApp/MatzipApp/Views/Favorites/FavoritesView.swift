import SwiftUI
import CoreLocation

struct FavoritesView: View {
    @State private var favoriteRestaurants = sampleRestaurants.filter { $0.isFavorite }
    
    var body: some View {
        NavigationView {
            Group {
                if favoriteRestaurants.isEmpty {
                    EmptyFavoritesView()
                } else {
                    FavoritesList(restaurants: favoriteRestaurants)
                }
            }
            .navigationTitle("즐겨찾기")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FavoritesList: View {
    let restaurants: [Restaurant]
    
    var body: some View {
        List(restaurants) { restaurant in
            FavoriteRestaurantCard(restaurant: restaurant)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
    }
}

struct FavoriteRestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(spacing: 12) {
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
            .frame(height: 150)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        // Toggle favorite
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
                
                HStack {
                    Image(systemName: restaurant.category.systemImage)
                        .foregroundColor(.orange)
                    Text(restaurant.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(restaurant.priceRange.displayText)
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("\(restaurant.rating, specifier: "%.1f")")
                        .font(.caption)
                    
                    Text("(\(restaurant.reviewCount)개 리뷰)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Text(restaurant.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                if !restaurant.description.isEmpty {
                    Text(restaurant.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("즐겨찾기한 맛집이 없습니다")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text("마음에 드는 맛집을 찾아서\n하트를 눌러보세요!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Button(action: {
                // Navigate to search or home
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("맛집 찾아보기")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("With Favorites") {
    FavoritesView()
}

#Preview("Empty") {
    FavoritesView()
}