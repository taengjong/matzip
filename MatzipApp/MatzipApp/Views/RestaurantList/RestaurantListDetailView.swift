import SwiftUI

struct RestaurantListDetailView: View {
    @StateObject private var viewModel: RestaurantListDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(list: UserRestaurantList) {
        self._viewModel = StateObject(wrappedValue: RestaurantListDetailViewModel(list: list))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 리스트 헤더 정보
                    RestaurantListHeader(
                        list: viewModel.list,
                        onVisibilityToggle: viewModel.toggleListVisibility,
                        onShare: viewModel.shareList
                    )
                    
                    // 맛집 목록
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if viewModel.restaurants.isEmpty {
                        EmptyRestaurantListContent(
                            onAddRestaurant: {
                                viewModel.showingAddRestaurant = true
                            }
                        )
                    } else {
                        RestaurantListContent(
                            restaurants: viewModel.restaurants,
                            onRemoveRestaurant: viewModel.removeRestaurant
                        )
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle(viewModel.list.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("완료") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddRestaurant = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddRestaurant) {
            RestaurantAddView(onAdd: viewModel.addRestaurant)
        }
    }
}

// MARK: - 리스트 헤더
struct RestaurantListHeader: View {
    let list: UserRestaurantList
    let onVisibilityToggle: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let description = list.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button(action: onVisibilityToggle) {
                        Image(systemName: list.isPublic ? "globe" : "lock")
                            .font(.title2)
                            .foregroundColor(list.isPublic ? .orange : .gray)
                    }
                    
                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // 리스트 통계
            HStack(spacing: 20) {
                StatBadge(
                    icon: "fork.knife",
                    title: "맛집",
                    value: "\(list.restaurantCount)개"
                )
                
                StatBadge(
                    icon: list.isPublic ? "globe" : "lock",
                    title: "공개",
                    value: list.isPublic ? "공개" : "비공개"
                )
                
                StatBadge(
                    icon: "calendar",
                    title: "생성일",
                    value: list.formattedCreatedDate
                )
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(16)
    }
}

struct StatBadge: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.orange)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 맛집 목록 콘텐츠
struct RestaurantListContent: View {
    let restaurants: [Restaurant]
    let onRemoveRestaurant: (Restaurant) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("맛집 목록 (\(restaurants.count)개)")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 12) {
                ForEach(restaurants) { restaurant in
                    NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                        RestaurantListItemCard(
                            restaurant: restaurant,
                            onRemove: { onRemoveRestaurant(restaurant) }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - 맛집 카드
struct RestaurantListItemCard: View {
    let restaurant: Restaurant
    let onRemove: () -> Void
    @State private var showingRemoveAlert = false
    
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
                
                Text(restaurant.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("\(restaurant.rating, specifier: "%.1f")")
                        .font(.caption)
                    
                    Text("(\(restaurant.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(restaurant.priceRange.displayText)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Text(restaurant.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 제거 버튼
            Button(action: { showingRemoveAlert = true }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .alert("맛집 제거", isPresented: $showingRemoveAlert) {
            Button("취소", role: .cancel) { }
            Button("제거", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("이 맛집을 리스트에서 제거하시겠습니까?")
        }
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

// MARK: - 빈 상태 뷰
struct EmptyRestaurantListContent: View {
    let onAddRestaurant: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("아직 추가된 맛집이 없습니다")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("첫 번째 맛집을 추가해보세요!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onAddRestaurant) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("맛집 추가하기")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - 맛집 추가 뷰 (간단한 버전)
struct RestaurantAddView: View {
    let onAdd: (Restaurant) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("맛집 추가 기능")
                    .font(.title2)
                    .padding()
                
                Text("실제로는 검색 기능이나 맛집 목록에서 선택하는 기능이 여기에 들어갑니다.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // 샘플 맛집 추가 버튼
                Button("샘플 맛집 추가") {
                    let sampleRestaurant = Restaurant(
                        id: "new_\(UUID().uuidString)",
                        name: "새로 추가된 맛집",
                        category: .korean,
                        address: "서울시 강남구 테헤란로 123",
                        coordinate: Coordinate(latitude: 37.5665, longitude: 126.9780),
                        phoneNumber: "02-1234-5678",
                        rating: 4.2,
                        reviewCount: 45,
                        priceRange: .medium,
                        openingHours: nil,
                        description: "새로 추가된 맛집입니다.",
                        imageURLs: [],
                        isFavorite: false
                    )
                    onAdd(sampleRestaurant)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
                
                Spacer()
            }
            .navigationTitle("맛집 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RestaurantListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantListDetailView(list: UserRestaurantList(
            id: "sample_list",
            userId: "current_user",
            name: "내가 좋아하는 한식집",
            description: "정말 맛있는 한식집들만 모아놨어요",
            restaurantIds: ["rest1", "rest2", "rest3"],
            isPublic: true
        ))
    }
}