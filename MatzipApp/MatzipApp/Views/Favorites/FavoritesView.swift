import SwiftUI
import CoreLocation

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 탭 선택기
                FavoritesTabSelector(
                    selectedTab: viewModel.selectedTab,
                    onTabSelected: viewModel.selectTab
                )
                .padding(.horizontal)
                .padding(.bottom)
                
                // 선택된 탭에 따른 콘텐츠
                if viewModel.selectedTab == .favorites {
                    FavoritesContent(viewModel: viewModel)
                } else {
                    RestaurantListsContent(viewModel: viewModel)
                }
            }
            .navigationTitle(viewModel.selectedTab.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: viewModel.selectedTab == .lists ?
                Button("추가") {
                    viewModel.showingCreateListSheet = true
                } : nil
            )
            .sheet(isPresented: $viewModel.showingCreateListSheet) {
                CreateRestaurantListView(viewModel: viewModel)
            }
            .refreshable {
                viewModel.refreshData()
            }
        }
        .onAppear {
            if viewModel.favoriteRestaurants.isEmpty {
                viewModel.loadFavoritesData()
            }
        }
    }
}

struct FavoritesTabSelector: View {
    let selectedTab: FavoritesViewModel.FavoritesTab
    let onTabSelected: (FavoritesViewModel.FavoritesTab) -> Void
    
    var body: some View {
        HStack {
            ForEach(FavoritesViewModel.FavoritesTab.allCases, id: \.self) { tab in
                Button(action: { onTabSelected(tab) }) {
                    HStack {
                        Image(systemName: tab.systemImage)
                        Text(tab.rawValue)
                    }
                    .font(.subheadline)
                    .fontWeight(selectedTab == tab ? .semibold : .regular)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedTab == tab ? Color.orange : Color(.systemGray6))
                    .foregroundColor(selectedTab == tab ? .white : .primary)
                    .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
    }
}

struct FavoritesContent: View {
    @ObservedObject var viewModel: FavoritesViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.favoriteRestaurants.isEmpty {
                EmptyFavoritesView()
            } else {
                FavoritesList(restaurants: viewModel.favoriteRestaurants, viewModel: viewModel)
            }
        }
    }
}

struct RestaurantListsContent: View {
    @ObservedObject var viewModel: FavoritesViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.userRestaurantLists.isEmpty {
                EmptyRestaurantListsView()
            } else {
                RestaurantListsList(lists: viewModel.userRestaurantLists, viewModel: viewModel)
            }
        }
    }
}

struct FavoritesList: View {
    let restaurants: [Restaurant]
    let viewModel: FavoritesViewModel
    
    var body: some View {
        List(restaurants) { restaurant in
            FavoriteRestaurantCard(restaurant: restaurant, viewModel: viewModel)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
    }
}

struct FavoriteRestaurantCard: View {
    let restaurant: Restaurant
    let viewModel: FavoritesViewModel
    
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
                        viewModel.toggleFavorite(restaurant: restaurant)
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

struct RestaurantListsList: View {
    let lists: [UserRestaurantList]
    let viewModel: FavoritesViewModel
    
    var body: some View {
        List(lists) { list in
            RestaurantListCard(list: list, viewModel: viewModel)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
    }
}

struct RestaurantListCard: View {
    let list: UserRestaurantList
    let viewModel: FavoritesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(list.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleListVisibility(list: list)
                }) {
                    Image(systemName: list.isPublic ? "globe" : "lock")
                        .foregroundColor(list.isPublic ? .orange : .gray)
                }
            }
            
            if let description = list.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .font(.caption)
                    Text("\(list.restaurantCount)개 맛집")
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(list.formattedCreatedDate)
                        .font(.caption)
                }
                
                Spacer()
                
                Button("삭제") {
                    viewModel.deleteRestaurantList(list: list)
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

struct EmptyRestaurantListsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("맛집 리스트가 없습니다")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text("나만의 맛집 컬렉션을\n만들어보세요!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CreateRestaurantListView: View {
    let viewModel: FavoritesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var isPublic = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("기본 정보") {
                    TextField("리스트 이름", text: $name)
                    TextField("설명 (선택사항)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("공개 설정") {
                    Toggle("공개 리스트로 만들기", isOn: $isPublic)
                }
            }
            .navigationTitle("새 맛집 리스트")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") { dismiss() },
                trailing: Button("만들기") {
                    viewModel.createRestaurantList(
                        name: name,
                        description: description.isEmpty ? nil : description,
                        isPublic: isPublic
                    )
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

#Preview("With Favorites") {
    FavoritesView()
}

#Preview("Empty") {
    FavoritesView()
}