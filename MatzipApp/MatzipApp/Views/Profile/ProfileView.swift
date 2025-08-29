import SwiftUI
import Foundation

struct ProfileView: View {
    @State private var user = sampleUser
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeader(user: user, showingEditProfile: $showingEditProfile)
                    
                    ProfileStats(user: user)
                    
                    ProfileMenuSection(showingSettings: $showingSettings)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Button("설정") {
                    showingSettings = true
                }
            )
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(user: $user)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct ProfileHeader: View {
    let user: User
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Button("프로필 편집") {
                showingEditProfile = true
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(20)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

struct ProfileStats: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 40) {
            StatItem(title: "작성한 리뷰", value: "\(user.reviewCount)")
            StatItem(title: "평균 평점", value: String(format: "%.1f", user.averageRating))
            StatItem(title: "즐겨찾기", value: "12") // This would come from a different data source
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ProfileMenuSection: View {
    @Binding var showingSettings: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ProfileMenuItem(icon: "doc.text", title: "내 리뷰", action: {})
            ProfileMenuItem(icon: "heart", title: "즐겨찾기 맛집", action: {})
            ProfileMenuItem(icon: "bell", title: "알림 설정", action: {})
            ProfileMenuItem(icon: "questionmark.circle", title: "도움말", action: {})
            ProfileMenuItem(icon: "gear", title: "설정", action: { showingSettings = true })
        }
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct EditProfileView: View {
    @Binding var user: User
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var email: String
    
    init(user: Binding<User>) {
        self._user = user
        self._name = State(initialValue: user.wrappedValue.name)
        self._email = State(initialValue: user.wrappedValue.email)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color(.systemGray5))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        Spacer()
                    }
                    
                    Button("사진 변경") {
                        // Photo picker
                    }
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section("개인정보") {
                    TextField("이름", text: $name)
                    TextField("이메일", text: $email)
                }
            }
            .navigationTitle("프로필 편집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") { dismiss() },
                trailing: Button("저장") {
                    // Save changes
                    dismiss()
                }
                .foregroundColor(.orange)
            )
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("일반") {
                    SettingsItem(icon: "bell", title: "알림", action: {})
                    SettingsItem(icon: "moon", title: "다크 모드", action: {})
                    SettingsItem(icon: "location", title: "위치 서비스", action: {})
                }
                
                Section("지원") {
                    SettingsItem(icon: "questionmark.circle", title: "도움말", action: {})
                    SettingsItem(icon: "envelope", title: "문의하기", action: {})
                    SettingsItem(icon: "star", title: "앱 평가하기", action: {})
                }
                
                Section("정보") {
                    SettingsItem(icon: "doc.text", title: "이용약관", action: {})
                    SettingsItem(icon: "hand.raised", title: "개인정보 처리방침", action: {})
                    SettingsItem(icon: "info.circle", title: "앱 버전", subtitle: "1.0.0", action: {})
                }
                
                Section {
                    Button("로그아웃") {
                        // Logout
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("완료") { dismiss() })
        }
    }
}

struct SettingsItem: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// Sample user data
let sampleUser = User(
    id: "1",
    name: "홍길동",
    email: "hong@example.com",
    profileImageURL: nil,
    reviewCount: 15,
    averageRating: 4.2,
    createdAt: Date()
)

#Preview {
    ProfileView()
}