import SwiftUI
import CoreLocation

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 검색 타입 선택
                SearchTypeSelector(
                    selectedType: viewModel.selectedSearchType,
                    onTypeSelected: viewModel.selectSearchType
                )
                
                EnhancedSearchBar(
                    text: $viewModel.searchText,
                    onSearchButtonClicked: viewModel.search
                )
                .padding()
                
                // 맛집 검색일 때만 필터 표시
                if viewModel.selectedSearchType == .restaurant {
                    FilterBar(
                        selectedCategory: $viewModel.selectedCategory,
                        selectedPriceRange: $viewModel.selectedPriceRange,
                        showFilters: $showFilters,
                        resultCount: viewModel.searchResults.count,
                        onFiltersApplied: viewModel.applyFilters,
                        onFiltersClear: viewModel.clearFilters
                    )
                }
                
                // 검색 결과 표시
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !viewModel.hasSearched {
                    InitialSearchView()
                } else {
                    SearchResultsView(viewModel: viewModel)
                }
                
                Spacer()
            }
            .navigationTitle("검색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SearchTypeSelector: View {
    let selectedType: SearchViewModel.SearchType
    let onTypeSelected: (SearchViewModel.SearchType) -> Void
    
    var body: some View {
        HStack {
            ForEach(SearchViewModel.SearchType.allCases, id: \.self) { type in
                Button(action: { onTypeSelected(type) }) {
                    HStack {
                        Image(systemName: type.systemImage)
                        Text(type.rawValue)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedType == type ? Color.orange : Color(.systemGray6))
                    .foregroundColor(selectedType == type ? .white : .primary)
                    .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct InitialSearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("검색어를 입력하세요")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("맛집 이름이나 사용자를 검색해보세요")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchResultsView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        if viewModel.selectedSearchType == .restaurant {
            if viewModel.searchResults.isEmpty {
                EmptySearchView()
            } else {
                RestaurantList(restaurants: viewModel.searchResults)
            }
        } else {
            if viewModel.userSearchResults.isEmpty {
                EmptyUserSearchView()
            } else {
                UserSearchList(users: viewModel.userSearchResults)
            }
        }
    }
}

struct EmptyUserSearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("사용자를 찾을 수 없습니다")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("다른 이름으로 검색해보세요")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UserSearchList: View {
    let users: [User]
    
    var body: some View {
        List(users) { user in
            UserSearchItem(user: user)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
    }
}

struct UserSearchItem: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("팔로워 \(user.followersCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("리뷰 \(user.reviewCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button("팔로우") {
                // 팔로우 액션
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .padding(.vertical, 4)
    }
}

struct FilterBar: View {
    @Binding var selectedCategory: RestaurantCategory?
    @Binding var selectedPriceRange: PriceRange?
    @Binding var showFilters: Bool
    let resultCount: Int
    let onFiltersApplied: () -> Void
    let onFiltersClear: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { showFilters.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                    Text("필터")
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
            .foregroundColor(.primary)
            
            if selectedCategory != nil || selectedPriceRange != nil {
                Button("초기화") {
                    selectedCategory = nil
                    selectedPriceRange = nil
                    onFiltersClear()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            Spacer()
            
            Text("\(resultCount)개 결과")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showFilters) {
            FilterSheet(
                selectedCategory: $selectedCategory,
                selectedPriceRange: $selectedPriceRange,
                onFiltersApplied: onFiltersApplied
            )
        }
    }
}

struct FilterSheet: View {
    @Binding var selectedCategory: RestaurantCategory?
    @Binding var selectedPriceRange: PriceRange?
    let onFiltersApplied: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("음식 종류") {
                    ForEach(RestaurantCategory.allCases, id: \.self) { category in
                        HStack {
                            Image(systemName: category.systemImage)
                                .foregroundColor(.orange)
                            Text(category.rawValue)
                            Spacer()
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
                
                Section("가격대") {
                    ForEach(PriceRange.allCases, id: \.self) { priceRange in
                        HStack {
                            Text(priceRange.displayText)
                                .foregroundColor(.orange)
                            Text(priceRange.description)
                            Spacer()
                            if selectedPriceRange == priceRange {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPriceRange = selectedPriceRange == priceRange ? nil : priceRange
                        }
                    }
                }
            }
            .navigationTitle("필터")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("완료") { 
                onFiltersApplied()
                dismiss() 
            })
        }
    }
}

struct RestaurantList: View {
    let restaurants: [Restaurant]
    
    var body: some View {
        List(restaurants) { restaurant in
            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                RestaurantListItem(restaurant: restaurant)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
    }
}

struct RestaurantListItem: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: restaurant.imageURLs.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(restaurant.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("\(restaurant.rating, specifier: "%.1f")")
                        .font(.caption)
                    
                    Text("(\(restaurant.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(restaurant.priceRange.displayText)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Text(restaurant.address)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {
                // Toggle favorite
            }) {
                Image(systemName: restaurant.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(restaurant.isFavorite ? .red : .gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("검색 결과가 없습니다")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("다른 키워드로 검색해보세요")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EnhancedSearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("맛집, 음식 종류를 검색해보세요", text: $text)
                .onSubmit {
                    onSearchButtonClicked()
                }
                .onChange(of: text) { _, newValue in
                    if !newValue.isEmpty {
                        onSearchButtonClicked()
                    }
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    SearchView()
}