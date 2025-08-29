import SwiftUI

struct FeedView: View {
    @StateObject private var followService = UserFollowService(userId: "current_user")
    @StateObject private var restaurantService = UserRestaurantService(userId: "current_user")
    @State private var feedItems: [RestaurantListFeedItem] = []
    @State private var isLoading = true
    @State private var showingUserSearch = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if isLoading {
                        LoadingFeedView()
                    } else if feedItems.isEmpty {
                        EmptyFeedView(showingUserSearch: $showingUserSearch)
                    } else {
                        ForEach(feedItems) { item in
                            FeedItemView(
                                item: item,
                                followService: followService,
                                restaurantService: restaurantService
                            )
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.top)
            }
            .refreshable {
                await loadFeed()
            }
            .navigationTitle("피드")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button {
                    showingUserSearch = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.orange)
                }
            )
        }
        .sheet(isPresented: $showingUserSearch) {
            UserSearchView()
        }
        .onAppear {
            Task {
                await loadFeed()
            }
        }
    }
    
    @MainActor
    private func loadFeed() async {
        isLoading = true
        
        followService.loadFollowing()
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let followingUserIds = followService.following.map { $0.id }
        feedItems = restaurantService.getRestaurantListsForFeed(followingUserIds: followingUserIds)
        
        isLoading = false
    }
}

struct FeedItemView: View {
    let item: RestaurantListFeedItem
    let followService: UserFollowService
    let restaurantService: UserRestaurantService
    @State private var showingListDetail = false
    @State private var showingUserProfile = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeedItemHeader(
                item: item,
                showingUserProfile: $showingUserProfile
            )
            
            FeedItemContent(
                item: item,
                showingListDetail: $showingListDetail
            )
            
            FeedItemActions(item: item)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingListDetail) {
            RestaurantListDetailView(list: item.list)
        }
        .sheet(isPresented: $showingUserProfile) {
            UserProfileView(userId: item.list.userId)
        }
    }
}

struct FeedItemHeader: View {
    let item: RestaurantListFeedItem
    @Binding var showingUserProfile: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                showingUserProfile = true
            } label: {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: item.user?.profileImageURL ?? "")) { image in
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
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.user?.name ?? "알 수 없는 사용자")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: item.activityType.systemImage)
                                .font(.caption)
                            Text(item.activityType.displayText)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct FeedItemContent: View {
    let item: RestaurantListFeedItem
    @Binding var showingListDetail: Bool
    
    var body: some View {
        Button {
            showingListDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.list.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if item.list.isPublic {
                        Image(systemName: "globe")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Image(systemName: "lock")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                if let description = item.list.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "fork.knife")
                            .font(.caption)
                        Text("\(item.list.restaurantCount)개 맛집")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(item.list.formattedCreatedDate)
                            .font(.caption)
                    }
                    
                    Spacer()
                }
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(8)
    }
}

struct FeedItemActions: View {
    let item: RestaurantListFeedItem
    @State private var isBookmarked = false
    @State private var isLiked = false
    @State private var showingShareSheet = false
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                isLiked.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .secondary)
                    Text("좋아요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.secondary)
                    Text("댓글")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                isBookmarked.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .orange : .secondary)
                    Text("저장")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                showingShareSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                    Text("공유")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: ["맛집 리스트: \(item.list.name)"])
        }
    }
}

struct LoadingFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { _ in
                FeedItemSkeleton()
            }
        }
        .padding(.horizontal)
    }
}

struct FeedItemSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 120, height: 12)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 160, height: 10)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 200, height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 150, height: 12)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(8)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .redacted(reason: .placeholder)
    }
}

struct EmptyFeedView: View {
    @Binding var showingUserSearch: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.2.wave.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Text("아직 피드가 비어있습니다")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("관심 있는 사용자를 팔로우하고\n그들의 맛집 활동을 확인해보세요!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Button {
                showingUserSearch = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                    Text("사용자 찾기")
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

struct RestaurantListDetailView: View {
    let list: UserRestaurantList
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(list.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let description = list.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("맛집 \(list.restaurantCount)개")
                        Spacer()
                        Text(list.formattedCreatedDate)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                    
                    Text("아직 구현되지 않은 맛집 목록입니다")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("맛집 리스트")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("완료") { dismiss() })
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    FeedView()
}