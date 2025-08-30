import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword, name
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // 로고 및 타이틀
                    headerSection
                    
                    // 입력 폼
                    formSection
                    
                    // 액션 버튼들
                    actionButtonsSection
                    
                    // 모드 전환
                    modeToggleSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .alert("오류", isPresented: $viewModel.showingAlert) {
            Button("확인") {
                viewModel.showingAlert = false
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 로고
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            // 타이틀
            Text("Matzip")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 서브타이틀
            Text(viewModel.isLoginMode ? "맛집을 발견하고 공유해보세요" : "새로운 맛집 여행을 시작해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 20) {
            // 이름 (회원가입시만)
            if !viewModel.isLoginMode {
                CustomTextField(
                    title: "이름",
                    text: $viewModel.name,
                    placeholder: "이름을 입력하세요",
                    keyboardType: .default,
                    validationMessage: viewModel.nameValidationMessage
                )
                .focused($focusedField, equals: .name)
            }
            
            // 이메일
            CustomTextField(
                title: "이메일",
                text: $viewModel.email,
                placeholder: "이메일을 입력하세요",
                keyboardType: .emailAddress,
                validationMessage: viewModel.emailValidationMessage
            )
            .focused($focusedField, equals: .email)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            
            // 비밀번호
            CustomSecureField(
                title: "비밀번호",
                text: $viewModel.password,
                placeholder: "비밀번호를 입력하세요",
                validationMessage: viewModel.passwordValidationMessage
            )
            .focused($focusedField, equals: .password)
            
            // 비밀번호 확인 (회원가입시만)
            if !viewModel.isLoginMode {
                CustomSecureField(
                    title: "비밀번호 확인",
                    text: $viewModel.confirmPassword,
                    placeholder: "비밀번호를 다시 입력하세요",
                    validationMessage: viewModel.confirmPasswordValidationMessage
                )
                .focused($focusedField, equals: .confirmPassword)
            }
        }
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // 메인 액션 버튼
            Button(action: {
                if viewModel.isLoginMode {
                    viewModel.login()
                } else {
                    viewModel.register()
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Text(viewModel.isLoginMode ? "로그인" : "회원가입")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    viewModel.isLoginMode ? 
                    (viewModel.canLogin ? Color.orange : Color.gray) :
                    (viewModel.canRegister ? Color.orange : Color.gray)
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoginMode ? !viewModel.canLogin : !viewModel.canRegister)
            
            // 테스트 계정 버튼 (개발용)
            if viewModel.isLoginMode {
                Button("테스트 계정으로 로그인") {
                    viewModel.fillTestCredentials()
                }
                .font(.footnote)
                .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Mode Toggle Section
    
    private var modeToggleSection: some View {
        HStack(spacing: 4) {
            Text(viewModel.isLoginMode ? "계정이 없으신가요?" : "이미 계정이 있으신가요?")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button(viewModel.isLoginMode ? "회원가입" : "로그인") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.toggleMode()
                }
            }
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundColor(.orange)
        }
    }
}

// MARK: - Custom Text Field

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let validationMessage: String?
    
    init(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default, validationMessage: String? = nil) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.validationMessage = validationMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(validationMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                )
            
            if let validationMessage = validationMessage {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Custom Secure Field

struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let validationMessage: String?
    @State private var isSecured = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                if isSecured {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
                
                Button(action: {
                    isSecured.toggle()
                }) {
                    Image(systemName: isSecured ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(validationMessage != nil ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if let validationMessage = validationMessage {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    AuthenticationView()
}