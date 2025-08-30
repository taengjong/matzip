import SwiftUI

// MARK: - 리뷰 카드
struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(review.userName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.orange)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.userName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Text(review.relativeDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Text(review.content)
                .font(.body)
                .lineLimit(nil)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}
