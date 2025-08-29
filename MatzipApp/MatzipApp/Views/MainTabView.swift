import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("검색")
                }
                .tag(1)
            
            FeedView()
                .tabItem {
                    Image(systemName: "person.2.wave.2")
                    Text("피드")
                }
                .tag(2)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("즐겨찾기")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("프로필")
                }
                .tag(4)
        }
        .accentColor(.orange)
    }
}

#Preview {
    MainTabView()
}