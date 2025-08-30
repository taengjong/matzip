import Foundation
import Combine
import SwiftUI

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "CurrentUser"
    private let isAuthenticatedKey = "IsAuthenticated"
    
    private init() {
        loadUserFromStorage()
    }
    
    // MARK: - Authentication
    
    func login(email: String, password: String) -> AnyPublisher<User, AuthError> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // 시뮬레이션: 실제로는 API 호출
                if self.validateCredentials(email: email, password: password) {
                    let user = self.createUserFromCredentials(email: email)
                    self.setCurrentUser(user)
                    promise(.success(user))
                } else {
                    promise(.failure(.invalidCredentials))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func register(name: String, email: String, password: String) -> AnyPublisher<User, AuthError> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // 시뮬레이션: 실제로는 API 호출
                if self.isValidEmail(email) && password.count >= 6 {
                    let user = User(
                        id: UUID().uuidString,
                        name: name,
                        email: email,
                        profileImageURL: nil,
                        reviewCount: 0,
                        averageRating: 0.0,
                        followersCount: 0,
                        followingCount: 0,
                        publicListsCount: 0,
                        bio: "",
                        createdAt: Date()
                    )
                    self.setCurrentUser(user)
                    promise(.success(user))
                } else {
                    promise(.failure(.invalidInput))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        clearUserFromStorage()
    }
    
    // MARK: - User Management
    
    func updateUserProfile(name: String, email: String, bio: String, profileImageURL: String? = nil) -> AnyPublisher<User, AuthError> {
        return Future { promise in
            guard var user = self.currentUser else {
                promise(.failure(.notAuthenticated))
                return
            }
            
            // 사용자 정보 업데이트
            user.name = name
            user.email = email
            user.bio = bio
            if let imageURL = profileImageURL {
                user.profileImageURL = imageURL
            }
            
            self.setCurrentUser(user)
            promise(.success(user))
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentUserId() -> String? {
        return currentUser?.id
    }
    
    // MARK: - Private Methods
    
    private func setCurrentUser(_ user: User) {
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.saveUserToStorage(user)
        }
    }
    
    private func validateCredentials(email: String, password: String) -> Bool {
        // 시뮬레이션: 실제로는 서버 검증
        // 개발용으로 몇 가지 테스트 계정 제공
        let testAccounts = [
            ("test@example.com", "password"),
            ("user@matzip.com", "123456"),
            ("demo@demo.com", "demo123")
        ]
        
        return testAccounts.contains { $0.0 == email && $0.1 == password }
    }
    
    private func createUserFromCredentials(email: String) -> User {
        // 시뮬레이션: 실제로는 서버에서 사용자 정보 가져옴
        return User(
            id: UUID().uuidString,
            name: extractNameFromEmail(email),
            email: email,
            profileImageURL: nil,
            reviewCount: Int.random(in: 5...50),
            averageRating: Double.random(in: 3.0...5.0),
            followersCount: Int.random(in: 10...100),
            followingCount: Int.random(in: 15...80),
            publicListsCount: Int.random(in: 2...10),
            bio: "안녕하세요! 맛집 탐험을 좋아합니다 🍽️",
            createdAt: Date()
        )
    }
    
    private func extractNameFromEmail(_ email: String) -> String {
        return String(email.prefix(while: { $0 != "@" })).capitalized
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Persistence
    
    private func saveUserToStorage(_ user: User) {
        do {
            let userData = try JSONEncoder().encode(user)
            userDefaults.set(userData, forKey: currentUserKey)
            userDefaults.set(true, forKey: isAuthenticatedKey)
        } catch {
            print("❌ Failed to save user to storage: \(error)")
        }
    }
    
    private func loadUserFromStorage() {
        guard let userData = userDefaults.data(forKey: currentUserKey),
              userDefaults.bool(forKey: isAuthenticatedKey) else {
            return
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: userData)
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            print("❌ Failed to load user from storage: \(error)")
            clearUserFromStorage()
        }
    }
    
    private func clearUserFromStorage() {
        userDefaults.removeObject(forKey: currentUserKey)
        userDefaults.removeObject(forKey: isAuthenticatedKey)
    }
}

// MARK: - Auth Error

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case invalidInput
    case notAuthenticated
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case .invalidInput:
            return "입력 정보를 확인해주세요."
        case .notAuthenticated:
            return "로그인이 필요합니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}