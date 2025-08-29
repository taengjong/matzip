import SwiftUI
import CoreLocation

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: RestaurantCategory?
    @State private var selectedPriceRange: PriceRange?
    @State private var showFilters = false
    
    var filteredRestaurants: [Restaurant] {
        var filtered = sampleRestaurants
        
        if !searchText.isEmpty {
            filtered = filtered.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let priceRange = selectedPriceRange {
            filtered = filtered.filter { $0.priceRange == priceRange }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding()
                
                FilterBar(
                    selectedCategory: $selectedCategory,
                    selectedPriceRange: $selectedPriceRange,
                    showFilters: $showFilters,
                    resultCount: filteredRestaurants.count
                )
                
                if filteredRestaurants.isEmpty {
                    EmptySearchView()
                } else {
                    RestaurantList(restaurants: filteredRestaurants)
                }
                
                Spacer()
            }
            .navigationTitle("맛집 검색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FilterBar: View {
    @Binding var selectedCategory: RestaurantCategory?
    @Binding var selectedPriceRange: PriceRange?
    @Binding var showFilters: Bool
    let resultCount: Int
    
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
                selectedPriceRange: $selectedPriceRange
            )
        }
    }
}

struct FilterSheet: View {
    @Binding var selectedCategory: RestaurantCategory?
    @Binding var selectedPriceRange: PriceRange?
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
            .navigationBarItems(trailing: Button("완료") { dismiss() })
        }
    }
}

struct RestaurantList: View {
    let restaurants: [Restaurant]
    
    var body: some View {
        List(restaurants) { restaurant in
            RestaurantListItem(restaurant: restaurant)
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

#Preview {
    SearchView()
}