import SwiftUI

// MARK: - 리뷰 섹션
struct RestaurantReviewSection: View {
    let restaurant: Restaurant
    let reviews: [Review]
    let isLoading: Bool
    let onWriteReview: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("리뷰")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("리뷰 쓰기") {
                    onWriteReview()
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
            
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if reviews.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("아직 리뷰가 없습니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("첫 번째 리뷰를 작성해보세요!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(reviews) { review in
                        ReviewCard(review: review)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
