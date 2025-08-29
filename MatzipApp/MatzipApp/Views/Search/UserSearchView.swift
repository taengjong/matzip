import SwiftUI

struct UserSearchView: View {
    @StateObject private var followService = UserFollowService(userId: "current_user")
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchSection(
                    searchText: $searchText,
                    isSearching: $isSearching,
                    onSearchChanged: performSearch
                )
                
                if searchText.isEmpty {
                    SuggestedUsersSection(followService: followService)
                } else {
                    SearchResultsSection(
                        searchResults: searchResults,
                        isSearching: isSearching,
                        followService: followService
                    )
                }
            }
            .navigationTitle("사용자 찾기")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            followService.loadSuggestedUsers()
        }
    }
    
    private func performSearch(_ query: String) {
        if query.isEmpty {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            searchResults = followService.searchUsers(query: query)
            isSearching = false
        }
    }
}

struct SearchSection: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let onSearchChanged: (String) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("사용자명 또는 이메일", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: searchText) { newValue in
                        onSearchChanged(newValue)
                    }
                
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !searchText.isEmpty {
                    Button("취소") {
                        searchText = ""
                        onSearchChanged("")
                    }
                    .foregroundColor(.orange)
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if !searchText.isEmpty && !isSearching {
                HStack {
                    Text("검색 결과")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct SuggestedUsersSection: View {
    let followService: UserFollowService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                HStack {
                    Text("추천 사용자")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                if followService.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("추천 사용자를 찾고 있습니다...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else if followService.suggestedUsers.isEmpty {
                    UserEmptySearchView(type: .suggested)
                } else {
                    ForEach(followService.suggestedUsers) { user in
                        SearchUserRowView(user: user, followService: followService)
                        
                        if user.id != followService.suggestedUsers.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top)
        }
    }
}

struct SearchResultsSection: View {
    let searchResults: [User]
    let isSearching: Bool
    let followService: UserFollowService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if isSearching {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("검색 중...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else if searchResults.isEmpty {
                    UserEmptySearchView(type: .noResults)
                } else {
                    ForEach(searchResults) { user in
                        SearchUserRowView(user: user, followService: followService)
                        
                        if user.id != searchResults.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top)
        }
    }
}

struct SearchUserRowView: View {
    let user: User
    let followService: UserFollowService
    @State private var showingUserProfile = false
    
    private var followStatus: FollowStatus {
        followService.getFollowStatus(for: user.id)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                showingUserProfile = true
            } label: {
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
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let bio = user.bio {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2")
                                    .font(.caption)
                                Text("\(user.followersText)")
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "list.bullet")
                                    .font(.caption)
                                Text("\(user.publicListsCount)")
                            }
                            
                            if followService.getMutualFollowersCount(with: user.id) > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .font(.caption)
                                    Text("공통 \(followService.getMutualFollowersCount(with: user.id))")
                                }
                                .foregroundColor(.orange)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if user.id != followService.currentUserId {
                FollowActionButton(
                    followStatus: followStatus,
                    action: {
                        toggleFollow()
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .sheet(isPresented: $showingUserProfile) {
            UserProfileView(userId: user.id)
        }
    }
    
    private func toggleFollow() {
        if followService.isFollowing(user.id) {
            followService.unfollowUser(user.id)
        } else {
            followService.followUser(user.id)
        }
    }
}

struct FollowActionButton: View {
    let followStatus: FollowStatus
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: followStatus.systemImage)
                    .font(.caption)
                Text(followStatus.displayText)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                followStatus == .none ? Color.orange : Color.clear
            )
            .foregroundColor(
                followStatus == .none ? .white : .orange
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange, lineWidth: 1.5)
            )
            .cornerRadius(20)
        }
    }
}

struct UserEmptySearchView: View {
    let type: EmptySearchType
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: type.iconName)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(type.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(type.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}

enum EmptySearchType {
    case suggested
    case noResults
    
    var iconName: String {
        switch self {
        case .suggested:
            return "person.3"
        case .noResults:
            return "magnifyingglass"
        }
    }
    
    var title: String {
        switch self {
        case .suggested:
            return "추천할 사용자가 없습니다"
        case .noResults:
            return "검색 결과가 없습니다"
        }
    }
    
    var message: String {
        switch self {
        case .suggested:
            return "나중에 다시 확인해보세요!"
        case .noResults:
            return "다른 검색어로 시도해보세요"
        }
    }
}

#Preview {
    UserSearchView()
}