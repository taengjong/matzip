import Foundation
import SwiftUI
import Combine

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
    @Published var showingSettings = false
    
    private let userManager = UserManager.shared
    private var userFollowService: UserFollowService?
    private var userRestaurantService: UserRestaurantService?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // UserManager에서 현재 사용자 정보 가져오기
        if let user = userManager.currentUser {
            self.currentUser = user
        } else {
            self.currentUser = User(
                id: "guest",
                name: "게스트 사용자",
                email: "guest@example.com",
                profileImageURL: nil,
                reviewCount: 0,
                averageRating: 0.0,
                followersCount: 0,
                followingCount: 0,
                publicListsCount: 0,
                bio: "",
                createdAt: Date()
            )
        }
        
        setupServices()
        setupUserManagerObserver()
        loadProfileData()
    }
    
    private func createGuestUser() -> User {
        return User(
            id: "guest",
            name: "게스트 사용자",
            email: "guest@example.com",
            profileImageURL: nil,
            reviewCount: 0,
            averageRating: 0.0,
            followersCount: 0,
            followingCount: 0,
            publicListsCount: 0,
            bio: "",
            createdAt: Date()
        )
    }
    
    private func setupServices() {
        guard let userId = userManager.getCurrentUserId() else { return }
        userFollowService = UserFollowService(userId: userId)
        userRestaurantService = UserRestaurantService(userId: userId)
    }
    
    private func setupUserManagerObserver() {
        userManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let user = user {
                    self?.currentUser = user
                    self?.setupServices()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadProfileData() {
        isLoading = true
        error = nil
        
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
        userManager.updateUserProfile(name: name, email: email, bio: bio)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] updatedUser in
                    self?.currentUser = updatedUser
                    self?.showingEditProfile = false
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - 팔로우 관리
    
    func showFollowers() {
        showingFollowersList = true
    }
    
    func showFollowing() {
        showingFollowingList = true
    }
    
    func unfollowUser(_ user: User) {
        userFollowService?.unfollowUser(user.id)
        following.removeAll { $0.id == user.id }
        currentUser.followingCount = max(0, currentUser.followingCount - 1)
    }
    
    func removeFollower(_ user: User) {
        followers.removeAll { $0.id == user.id }
        currentUser.followersCount = max(0, currentUser.followersCount - 1)
    }
    
    // MARK: - Private Methods
    
    private func loadFollowData() {
        guard let service = userFollowService else { return }
        
        followers = service.followers
        following = service.following
    }
    
    private func loadUserLists() {
        guard let service = userRestaurantService else { return }
        
        userRestaurantLists = service.userRestaurantLists
        currentUser.publicListsCount = userRestaurantLists.filter { $0.isPublic }.count
    }
    
    private func updateUserStats() {
        // 실제 환경에서는 CoreData나 API에서 통계 데이터를 가져올 것
        // 현재는 샘플 데이터로 대체
        if currentUser.id != "guest" {
            currentUser.reviewCount = Int.random(in: 10...100)
            currentUser.averageRating = Double.random(in: 3.0...5.0)
            currentUser.followersCount = followers.count
            currentUser.followingCount = following.count
        }
    }
    
    // MARK: - Computed Properties for UI
    
    var publicListsText: String {
        return "\(currentUser.publicListsCount)"
    }
    
    var joinedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        return formatter.string(from: currentUser.createdAt) + " 가입"
    }
    
    var settingItems: [SettingItem] {
        return [
            SettingItem(id: "edit", title: "프로필 편집", systemImage: "pencil", action: { self.showingEditProfile = true }),
            SettingItem(id: "settings", title: "설정", systemImage: "gearshape", action: { self.showingSettings = true })
        ]
    }
}

struct SettingItem: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let action: () -> Void
}