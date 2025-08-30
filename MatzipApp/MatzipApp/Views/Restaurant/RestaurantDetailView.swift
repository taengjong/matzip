import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    @StateObject private var viewModel: RestaurantDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(restaurant: Restaurant) {
        self._viewModel = StateObject(wrappedValue: RestaurantDetailViewModel(restaurant: restaurant))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 상단 이미지
                    RestaurantImageHeader(restaurant: viewModel.restaurant)
                    
                    VStack(spacing: 20) {
                        // 기본 정보
                        RestaurantBasicInfo(
                            restaurant: viewModel.restaurant,
                            isFavorite: viewModel.isFavorite,
                            onFavoriteToggle: viewModel.toggleFavorite
                        )
                        
                        // 액션 버튼들
                        RestaurantActionButtons(
                            restaurant: viewModel.restaurant,
                            onCall: viewModel.callRestaurant,
                            onMap: viewModel.openInMaps,
                            onShare: viewModel.shareRestaurant
                        )
                        
                        Divider()
                        
                        // 상세 정보
                        RestaurantDetailInfo(restaurant: viewModel.restaurant)
                        
                        Divider()
                        
                        // 리뷰 섹션
                        RestaurantReviewSection(
                            restaurant: viewModel.restaurant,
                            reviews: viewModel.reviews,
                            isLoading: viewModel.isLoading,
                            onWriteReview: viewModel.showReviewForm
                        )
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingReviewForm) {
            ReviewWriteView(
                restaurant: viewModel.restaurant,
                onSubmit: viewModel.addReview
            )
        }
    }
}

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

// MARK: - 액션 버튼들
struct RestaurantActionButtons: View {
    let restaurant: Restaurant
    let onCall: () -> Void
    let onMap: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            if restaurant.phoneNumber != nil {
                ActionButton(
                    icon: "phone.fill",
                    title: "전화",
                    color: .green,
                    action: onCall
                )
            }
            
            ActionButton(
                icon: "map.fill",
                title: "지도",
                color: .blue,
                action: onMap
            )
            
            ActionButton(
                icon: "square.and.arrow.up",
                title: "공유",
                color: .orange,
                action: onShare
            )
            
            Spacer()
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - 상세 정보
struct RestaurantDetailInfo: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("상세 정보")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "location.fill",
                    title: "주소",
                    content: restaurant.address
                )
                
                if let phoneNumber = restaurant.phoneNumber {
                    InfoRow(
                        icon: "phone.fill",
                        title: "전화번호",
                        content: phoneNumber
                    )
                }
                
                if let openingHours = restaurant.openingHours {
                    InfoRow(
                        icon: "clock.fill",
                        title: "운영시간",
                        content: todayOpeningHours(openingHours)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func todayOpeningHours(_ hours: OpeningHours) -> String {
        guard let todayHours = hours.todayHours() else {
            return "운영시간 정보 없음"
        }
        
        if todayHours.isOpen {
            return "\(todayHours.open) - \(todayHours.close)"
        } else {
            return "휴무"
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

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

// MARK: - 리뷰 작성 화면
struct ReviewWriteView: View {
    let restaurant: Restaurant
    let onSubmit: (Double, String, [String]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Double = 5.0
    @State private var content = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 맛집 정보
                HStack {
                    VStack(alignment: .leading) {
                        Text(restaurant.name)
                            .font(.headline)
                        Text(restaurant.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(12)
                
                // 별점 선택
                VStack(alignment: .leading, spacing: 12) {
                    Text("별점")
                        .font(.headline)
                    
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Button {
                                rating = Double(index)
                            } label: {
                                Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                // 리뷰 내용
                VStack(alignment: .leading, spacing: 12) {
                    Text("리뷰")
                        .font(.headline)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6).opacity(0.3))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("리뷰 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        onSubmit(rating, content, [])
                        dismiss()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant(
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
        ))
    }
}