import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("홈")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    Text("검색")
                }
                .tag(1)
            
            MapView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "map.fill" : "map")
                    Text("지도")
                }
                .tag(2)
            
            FeedView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.2.wave.2.fill" : "person.2.wave.2")
                    Text("피드")
                }
                .tag(3)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "heart.fill" : "heart")
                    Text("즐겨찾기")
                }
                .tag(4)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 5 ? "person.fill" : "person")
                    Text("프로필")
                }
                .tag(5)
        }
        .accentColor(.orange)
        .onChange(of: selectedTab) { newValue in
            // 탭 전환 시 햅틱 피드백
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            
            previousTab = newValue
        }
    }
}

#Preview {
    MainTabView()
}