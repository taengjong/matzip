import SwiftUI

struct FollowListView: View {
    let listType: FollowListType
    let userId: String
    @StateObject private var followService = UserFollowService(userId: "current_user")
    @State private var searchText = ""
    
    var title: String {
        switch listType {
        case .followers:
            return "팔로워"
        case .following:
            return "팔로잉"
        }
    }
    
    var users: [User] {
        switch listType {
        case .followers:
            return followService.followers
        case .following:
            return followService.following
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                FollowSearchBar(text: $searchText)
                    .padding(.horizontal)
                
                if followService.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if users.isEmpty {
                    EmptyFollowListView(listType: listType)
                } else {
                    List(filteredUsers) { user in
                        UserRowView(user: user, followService: followService)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadData()
        }
    }
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func loadData() {
        switch listType {
        case .followers:
            followService.loadFollowers()
        case .following:
            followService.loadFollowing()
        }
    }
}

struct UserRowView: View {
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
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let bio = user.bio {
                            Text(bio)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 8) {
                            Text("팔로워 \(user.followersText)")
                            Text("·")
                            Text("리스트 \(user.publicListsCount)")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if user.id != followService.currentUserId {
                FollowButton(
                    followStatus: followStatus,
                    action: {
                        toggleFollow()
                    }
                )
            }
        }
        .padding(.vertical, 8)
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

struct FollowButton: View {
    let followStatus: FollowStatus
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: followStatus.systemImage)
                    .font(.caption)
                Text(followStatus.displayText)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                followStatus == .none ? Color.orange : Color.clear
            )
            .foregroundColor(
                followStatus == .none ? .white : .orange
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange, lineWidth: 1)
            )
            .cornerRadius(16)
        }
    }
}

struct FollowSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("사용자 검색", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button("취소") {
                    text = ""
                }
                .foregroundColor(.orange)
                .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EmptyFollowListView: View {
    let listType: FollowListType
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: listType == .followers ? "person.2" : "person.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(listType == .followers ? "팔로워가 없습니다" : "팔로잉 중인 사용자가 없습니다")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(listType == .followers ? 
                     "다른 사용자들과 맛집을 공유해보세요!" : 
                     "관심 있는 사용자를 팔로우해보세요!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct UserProfileView: View {
    let userId: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("User Profile for \(userId)")
                .navigationTitle("프로필")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("완료") { dismiss() })
        }
    }
}

enum FollowListType {
    case followers
    case following
}

#Preview {
    FollowListView(listType: .followers, userId: "1")
}