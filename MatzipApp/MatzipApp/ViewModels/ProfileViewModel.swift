import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var currentUser: User
    @Published var followers: [User] = []
    @Published var following: [User] = []
    @Published var userRestaurantLists: [UserRestaurantList] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showingEditProfile = false
    @Published var showingFollowersList = false
    @Published var showingFollowingList = false
    
    private let userFollowService: UserFollowService
    private let userRestaurantService: UserRestaurantService
    private let currentUserId = "current_user"
    
    init() {
        // 현재 사용자 정보 초기화 (실제로는 인증 서비스에서 가져옴)
        self.currentUser = User(
            id: currentUserId,
            name: "윤종희",
            email: "jongheeyun@example.com",
            profileImageURL: nil,
            reviewCount: 42,
            averageRating: 4.3,
            followersCount: 128,
            followingCount: 89,
            publicListsCount: 6,
            bio: "맛있는 음식을 찾아 다니는 개발자 👨‍💻🍽️",
            createdAt: Date().addingTimeInterval(-86400 * 365) // 1년 전 가입
        )
        
        self.userFollowService = UserFollowService(userId: currentUserId)
        self.userRestaurantService = UserRestaurantService(userId: currentUserId)
        
        loadProfileData()
    }
    
    func loadProfileData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadFollowData()
            self.loadUserLists()
            self.updateUserStats()
            self.isLoading = false
        }
    }
    
    func refreshProfile() {
        loadProfileData()
    }
    
    // MARK: - 프로필 편집
    
    func updateProfile(name: String, email: String, bio: String) {
        currentUser = User(
            id: currentUser.id,
            name: name,
            email: email,
            profileImageURL: currentUser.profileImageURL,
            reviewCount: currentUser.reviewCount,
            averageRating: currentUser.averageRating,
            followersCount: currentUser.followersCount,
            followingCount: currentUser.followingCount,
            publicListsCount: currentUser.publicListsCount,
            bio: bio,
            createdAt: currentUser.createdAt
        )
        showingEditProfile = false
    }
    
    // MARK: - 팔로우 관리
    
    func showFollowers() {
        showingFollowersList = true
    }
    
    func showFollowing() {
        showingFollowingList = true
    }
    
    func unfollowUser(_ user: User) {
        userFollowService.unfollowUser(user.id)
        following.removeAll { $0.id == user.id }
        updateUserStats()
    }
    
    func removeFollower(_ user: User) {
        // 팔로워 제거 기능 (실제로는 서버에서 처리)
        followers.removeAll { $0.id == user.id }
        updateUserStats()
    }
    
    // MARK: - 설정
    
    func logout() {
        // 로그아웃 처리 (실제로는 인증 토큰 삭제 등)
        print("로그아웃 처리")
    }
    
    func deleteAccount() {
        // 회원탈퇴 처리 (실제로는 서버와 통신)
        print("회원탈퇴 처리")
    }
    
    // MARK: - 통계 정보
    
    var joinedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: currentUser.createdAt)
    }
    
    var averageRatingText: String {
        return String(format: "%.1f", currentUser.averageRating)
    }
    
    var publicListsText: String {
        return "\(userRestaurantLists.filter { $0.isPublic }.count)개"
    }
    
    // MARK: - Private Methods
    
    private func loadFollowData() {
        followers = userFollowService.getFollowers()
        following = userFollowService.getFollowing()
    }
    
    private func loadUserLists() {
        userRestaurantLists = userRestaurantService.userRestaurantLists
    }
    
    private func updateUserStats() {
        currentUser = User(
            id: currentUser.id,
            name: currentUser.name,
            email: currentUser.email,
            profileImageURL: currentUser.profileImageURL,
            reviewCount: currentUser.reviewCount,
            averageRating: currentUser.averageRating,
            followersCount: followers.count,
            followingCount: following.count,
            publicListsCount: userRestaurantLists.filter { $0.isPublic }.count,
            bio: currentUser.bio,
            createdAt: currentUser.createdAt
        )
    }
}

// MARK: - 설정 항목 모델

extension ProfileViewModel {
    struct SettingItem: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        let action: () -> Void
        let isDestructive: Bool
        
        init(title: String, systemImage: String, isDestructive: Bool = false, action: @escaping () -> Void) {
            self.title = title
            self.systemImage = systemImage
            self.isDestructive = isDestructive
            self.action = action
        }
    }
    
    var settingItems: [SettingItem] {
        [
            SettingItem(title: "알림 설정", systemImage: "bell") {
                // 알림 설정 화면으로 이동
                print("알림 설정")
            },
            SettingItem(title: "개인정보 보호", systemImage: "lock") {
                // 개인정보 설정 화면으로 이동
                print("개인정보 보호 설정")
            },
            SettingItem(title: "앱 정보", systemImage: "info.circle") {
                // 앱 정보 화면으로 이동
                print("앱 정보")
            },
            SettingItem(title: "고객 지원", systemImage: "questionmark.circle") {
                // 고객 지원 화면으로 이동
                print("고객 지원")
            },
            SettingItem(title: "로그아웃", systemImage: "rectangle.portrait.and.arrow.right") {
                self.logout()
            },
            SettingItem(title: "회원탈퇴", systemImage: "trash", isDestructive: true) {
                self.deleteAccount()
            }
        ]
    }
}