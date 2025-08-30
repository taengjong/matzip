import SwiftUI

// MARK: - 상단 이미지 헤더
struct RestaurantImageHeader: View {
    let restaurant: Restaurant
    
    var body: some View {
        if let imageURL = restaurant.imageURLs.first {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 250)
            .clipped()
        } else {
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 250)
                .overlay(
                    VStack {
                        Image(systemName: restaurant.category.systemImage)
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(restaurant.category.rawValue)
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                )
        }
    }
}
