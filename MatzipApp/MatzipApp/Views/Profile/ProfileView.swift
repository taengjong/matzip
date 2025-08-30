import SwiftUI
import Foundation

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var userManager: UserManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ProfileHeader(
                            user: viewModel.currentUser, 
                            showingEditProfile: $viewModel.showingEditProfile
                        )
                        
                        ProfileStats(
                            user: viewModel.currentUser,
                            viewModel: viewModel
                        )
                        
                        ProfileMenuSection(viewModel: viewModel)
                        
                        Spacer()
                    }
                }
                .padding()
            }
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(viewModel.settingItems) { item in
                            Button {
                                item.action()
                            } label: {
                                Label(item.title, systemImage: item.systemImage)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingFollowersList) {
            FollowListView(listType: .followers, userId: viewModel.currentUser.id)
        }
        .sheet(isPresented: $viewModel.showingFollowingList) {
            FollowListView(listType: .following, userId: viewModel.currentUser.id)
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsView()
        }
        .refreshable {
            viewModel.refreshProfile()
        }
        .onAppear {
            if viewModel.followers.isEmpty {
                viewModel.loadProfileData()
            }
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
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
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
    let viewModel: ProfileViewModel
    
    var body: some View {
        HStack(spacing: 30) {
            Button {
                viewModel.showFollowers()
            } label: {
                StatItem(title: "팔로워", value: "\(user.followersCount)")
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                viewModel.showFollowing()
            } label: {
                StatItem(title: "팔로잉", value: "\(user.followingCount)")
            }
            .buttonStyle(PlainButtonStyle())
            
            StatItem(title: "맛집 리스트", value: viewModel.publicListsText)
            StatItem(title: "리뷰", value: "\(user.reviewCount)")
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
    let viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ProfileMenuItem(icon: "doc.text", title: "내 리뷰", action: {})
            ProfileMenuItem(icon: "heart", title: "즐겨찾기 맛집", action: {})
            ProfileMenuItem(icon: "list.bullet", title: "내 맛집 리스트", action: {})
            ProfileMenuItem(icon: "calendar", title: "가입일", 
                          subtitle: viewModel.joinedDateText, action: {})
        }
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

struct ProfileMenuItem: View {
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
            .padding()
        }
    }
}

struct EditProfileView: View {
    let viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var email: String
    @State private var bio: String
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        self._name = State(initialValue: viewModel.currentUser.name)
        self._email = State(initialValue: viewModel.currentUser.email)
        self._bio = State(initialValue: viewModel.currentUser.bio)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        AsyncImage(url: URL(string: viewModel.currentUser.profileImageURL ?? "")) { image in
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
                    TextField("자기소개", text: $bio, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("프로필 편집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") { dismiss() },
                trailing: Button("저장") {
                    viewModel.updateProfile(name: name, email: email, bio: bio)
                    dismiss()
                }
                .foregroundColor(.orange)
            )
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: UserManager
    
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
                        userManager.logout()
                        dismiss()
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
    followersCount: 128,
    followingCount: 64,
    publicListsCount: 8,
    bio: "맛집 탐험가 🍽️ 서울 곳곳의 숨은 맛집을 찾아다닙니다",
    createdAt: Date()
)

#Preview {
    ProfileView()
}