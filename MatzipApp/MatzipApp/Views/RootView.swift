import SwiftUI

struct RootView: View {
    @EnvironmentObject private var userManager: UserManager
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                LaunchScreenView()
            } else if userManager.isAuthenticated {
                MainTabView()
                    .transition(.opacity)
            } else {
                AuthenticationView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // 앱 시작 시 잠깐 로딩 화면 표시
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isLoading = false
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: userManager.isAuthenticated)
    }
}

// MARK: - Launch Screen View

struct LaunchScreenView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.2), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 로고 아이콘
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.orange)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // 앱 이름
                Text("Matzip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(opacity)
                
                // 로딩 인디케이터
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.orange)
                    .opacity(opacity)
                
                // 슬로건
                Text("맛집을 발견하고 공유하는 즐거움")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                scale = 1.1
                opacity = 1.0
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(UserManager.shared)
}