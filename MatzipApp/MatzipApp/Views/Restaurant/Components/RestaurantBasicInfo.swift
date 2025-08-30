import SwiftUI

// MARK: - 기본 정보
struct RestaurantBasicInfo: View {
    let restaurant: Restaurant
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(restaurant.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(isFavorite ? .red : .gray)
                }
            }
            
            HStack {
                Image(systemName: restaurant.category.systemImage)
                    .foregroundColor(.orange)
                Text(restaurant.category.rawValue)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(restaurant.priceRange.displayText)
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
            }
            .font(.subheadline)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text("\(restaurant.rating, specifier: "%.1f")")
                    .fontWeight(.medium)
                
                Text("(\(restaurant.reviewCount)개 리뷰)")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .font(.subheadline)
            
            if !restaurant.description.isEmpty {
                Text(restaurant.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
        }
    }
}
