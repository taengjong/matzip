import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    @StateObject private var viewModel: RestaurantDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(restaurant: Restaurant) {
        // TODO: Hardcoded user ID should be replaced with actual user session data
        let currentUserId = "current_user"
        let userRestaurantService = UserRestaurantService(userId: currentUserId)
        
        self._viewModel = StateObject(wrappedValue: RestaurantDetailViewModel(
            restaurant: restaurant,
            userId: currentUserId,
            userRestaurantService: userRestaurantService
        ))
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


struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRestaurant = Restaurant(
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
        )
        
        return RestaurantDetailView(restaurant: sampleRestaurant)
    }
}
