import Foundation
import Combine
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAlert = false
    
    @Published var isLoginMode = true
    
    private let userManager = UserManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Validation
    
    var isEmailValid: Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        return password.count >= 6
    }
    
    var isNameValid: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var passwordsMatch: Bool {
        return password == confirmPassword
    }
    
    var canLogin: Bool {
        return isEmailValid && isPasswordValid && !isLoading
    }
    
    var canRegister: Bool {
        return isEmailValid && isPasswordValid && isNameValid && passwordsMatch && !isLoading
    }
    
    // MARK: - Actions
    
    func login() {
        guard canLogin else { return }
        
        isLoading = true
        errorMessage = nil
        
        userManager.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] user in
                    print("✅ User logged in successfully: \(user.name)")
                    self?.clearForm()
                }
            )
            .store(in: &cancellables)
    }
    
    func register() {
        guard canRegister else { return }
        
        isLoading = true
        errorMessage = nil
        
        userManager.register(name: name, email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] user in
                    print("✅ User registered successfully: \(user.name)")
                    self?.clearForm()
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleMode() {
        isLoginMode.toggle()
        clearForm()
        clearError()
    }
    
    func fillTestCredentials() {
        email = "test@example.com"
        password = "password"
        if !isLoginMode {
            name = "테스트 사용자"
            confirmPassword = "password"
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: AuthError) {
        errorMessage = error.localizedDescription
        showingAlert = true
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        name = ""
    }
    
    private func clearError() {
        errorMessage = nil
        showingAlert = false
    }
    
    // MARK: - Validation Messages
    
    var emailValidationMessage: String? {
        if email.isEmpty {
            return nil
        }
        return isEmailValid ? nil : "올바른 이메일 형식을 입력해주세요"
    }
    
    var passwordValidationMessage: String? {
        if password.isEmpty {
            return nil
        }
        return isPasswordValid ? nil : "비밀번호는 최소 6자 이상이어야 합니다"
    }
    
    var confirmPasswordValidationMessage: String? {
        if confirmPassword.isEmpty || isLoginMode {
            return nil
        }
        return passwordsMatch ? nil : "비밀번호가 일치하지 않습니다"
    }
    
    var nameValidationMessage: String? {
        if name.isEmpty || isLoginMode {
            return nil
        }
        return isNameValid ? nil : "이름을 입력해주세요"
    }
}