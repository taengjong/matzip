# 프로젝트 아키텍처 문서

## 📐 아키텍처 개요

Matzip 앱은 **MVVM(Model-View-ViewModel)** 패턴을 기반으로 설계된 소셜 맛집 플랫폼입니다. SwiftUI의 특성을 살려 선언적 UI와 반응형 데이터 바인딩을 활용합니다.

### 핵심 설계 원칙
1. **관심사 분리**: UI, 비즈니스 로직, 데이터 계층의 명확한 분리
2. **재사용성**: 공통 컴포넌트와 서비스의 모듈화
3. **확장성**: 새로운 기능 추가 시 기존 코드 영향 최소화
4. **테스트 가능성**: 각 계층의 독립적 테스트 가능한 구조

## 🏗️ 계층별 구조

```
┌─────────────────────────────────────────────────────────────┐
│                        View Layer                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   SwiftUI   │ │   TabView   │ │    Navigation Views     │ │
│  │   Views     │ │    (Main)   │ │  (Home, Search, etc.)   │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     ViewModel Layer                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │          ObservableObject ViewModels                    │ │
│  │    (HomeViewModel, SearchViewModel, etc.)               │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Service Layer                           │
│  ┌─────────────────┐ ┌─────────────────┐ ┌───────────────┐   │
│  │ UserFollowService│ │UserRestaurantSvc│ │ LocationSvc   │   │
│  │                 │ │                 │ │   (예정)      │   │
│  └─────────────────┘ └─────────────────┘ └───────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   Models    │ │ Core Data   │ │      Network API        │ │
│  │ (Codable)   │ │   (예정)    │ │       (예정)           │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📱 View Layer 상세

### MainTabView
앱의 주 네비게이션을 담당하는 루트 뷰
```swift
TabView {
    HomeView()      // 홈 - 맛집 추천
    SearchView()    // 검색 - 맛집/사용자
    FeedView()      // 피드 - 소셜 활동
    FavoritesView() // 즐겨찾기 - 저장된 맛집
    ProfileView()   // 프로필 - 사용자 정보
}
```

### 화면별 역할

#### 🏠 HomeView
- **목적**: 맛집 발견 및 추천
- **구성요소**: 추천 섹션, 카테고리 선택, 인기 맛집
- **의존성**: RestaurantService (예정), LocationService (예정)

#### 🔍 SearchView
- **목적**: 맛집 및 사용자 통합 검색
- **구성요소**: 검색바, 필터, 결과 목록, 사용자 검색
- **의존성**: SearchService (예정), UserService (예정)

#### 👥 FeedView
- **목적**: 소셜 활동 피드
- **구성요소**: 팔로잉 사용자 활동, 맛집 리스트 공유 소식
- **의존성**: UserFollowService, UserRestaurantService

#### ❤️ FavoritesView
- **목적**: 개인 맛집 관리
- **구성요소**: 즐겨찾기 맛집, 맛집 리스트 컬렉션
- **의존성**: UserRestaurantService

#### 👤 ProfileView
- **목적**: 사용자 프로필 및 설정
- **구성요소**: 사용자 정보, 통계, 팔로우 관리, 설정
- **의존성**: UserService (예정), UserFollowService

### Common Views
재사용 가능한 공통 UI 컴포넌트들 (예정)
- RestaurantCard: 맛집 정보 카드
- UserCard: 사용자 정보 카드  
- EmptyState: 빈 상태 표시
- LoadingView: 로딩 인디케이터

## 🧠 ViewModel Layer ✅

각 View에 대응하는 ViewModel을 통해 UI 상태 관리 및 비즈니스 로직 처리

### 구현된 ViewModel들

#### HomeViewModel
홈화면의 맛집 추천 및 카테고리 관리
```swift
class HomeViewModel: ObservableObject {
    @Published var recommendedRestaurants: [Restaurant] = []
    @Published var popularRestaurants: [Restaurant] = []
    @Published var nearbyRestaurants: [Restaurant] = []
    @Published var selectedCategory: RestaurantCategory?
    @Published var isLoading = false
    
    func loadInitialData() { ... }
    func selectCategory(_ category: RestaurantCategory?) { ... }
    func refreshData() { ... }
}
```

#### SearchViewModel  
맛집 및 사용자 통합 검색 기능
```swift
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Restaurant] = []
    @Published var userSearchResults: [User] = []
    @Published var selectedSearchType: SearchType = .restaurant
    @Published var selectedCategory: RestaurantCategory?
    @Published var isLoading = false
    
    func search() { ... }
    func selectSearchType(_ type: SearchType) { ... }
    func applyFilters() { ... }
}
```

#### FeedViewModel
소셜 피드 및 팔로잉 사용자 활동 관리
```swift
class FeedViewModel: ObservableObject {
    @Published var feedItems: [RestaurantListFeedItem] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    
    private let userRestaurantService: UserRestaurantService
    private let userFollowService: UserFollowService
    
    func loadFeedData() { ... }
    func refreshFeed() { ... }
    func loadMoreFeed() { ... }
}
```

#### FavoritesViewModel
즐겨찾기 및 맛집 리스트 관리
```swift
class FavoritesViewModel: ObservableObject {
    @Published var favoriteRestaurants: [Restaurant] = []
    @Published var userRestaurantLists: [UserRestaurantList] = []
    @Published var selectedTab: FavoritesTab = .favorites
    @Published var showingCreateListSheet = false
    
    func toggleFavorite(restaurant: Restaurant) { ... }
    func createRestaurantList(name: String, description: String?, isPublic: Bool) { ... }
    func deleteRestaurantList(list: UserRestaurantList) { ... }
}
```

#### ProfileViewModel
사용자 프로필 및 설정 관리
```swift
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User
    @Published var followers: [User] = []
    @Published var following: [User] = []
    @Published var showingEditProfile = false
    
    func updateProfile(name: String, email: String, bio: String) { ... }
    func unfollowUser(_ user: User) { ... }
    func logout() { ... }
}
```

### ViewModel의 핵심 역할
- **상태 관리**: `@Published` 프로퍼티로 UI 상태 관리
- **사용자 액션 처리**: 버튼 탭, 검색, 필터링 등
- **Service 계층 연동**: 비즈니스 로직과 데이터 통신
- **UI 업데이트**: 데이터 변환 및 자동 UI 리렌더링

## ⚙️ Service Layer

### UserFollowService
사용자 팔로우 관계 관리

**주요 기능**:
- 팔로우/언팔로우 처리
- 팔로워/팔로잉 목록 관리
- 추천 사용자 제공
- 팔로우 상태 확인

**메서드**:
```swift
func followUser(userId: String)
func unfollowUser(userId: String)
func loadFollowers() -> [User]
func loadFollowing() -> [User] 
func loadSuggestedUsers() -> [User]
func isFollowing(userId: String) -> Bool
```

### UserRestaurantService
사용자 맛집 관리 서비스

**주요 기능**:
- 맛집 리스트 CRUD
- 즐겨찾기 관리
- 피드용 데이터 제공
- 공개/비공개 설정

**메서드**:
```swift
func createRestaurantList(name: String, description: String?, isPublic: Bool)
func addRestaurantToList(restaurantId: String, listId: String)
func removeRestaurantFromList(restaurantId: String, listId: String)
func addToFavorites(restaurantId: String)
func removeFromFavorites(restaurantId: String)
func getRestaurantListsForFeed(followingUserIds: [String]) -> [RestaurantListFeedItem]
```

### 예정 서비스들
- **RestaurantService**: 맛집 데이터 관리
- **LocationService**: 위치 기반 서비스  
- **ReviewService**: 리뷰 관리
- **ImageService**: 이미지 업로드/다운로드
- **NetworkService**: API 통신

## 📊 Data Layer

### Models

#### Restaurant
맛집 기본 정보 모델
```swift
struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let category: RestaurantCategory
    let coordinate: CLLocationCoordinate2D
    let rating: Double
    let priceRange: PriceRange
    let openingHours: OpeningHours?
    // ... 기타 속성
}
```

**특징**:
- CoreLocation 연동 (CLLocationCoordinate2D)
- 카테고리별 분류 지원
- 가격대별 필터링 지원
- 운영시간 관리

#### User & Social Models
```swift
struct User: Identifiable, Codable {
    let id: String
    let name: String
    let followersCount: Int
    let followingCount: Int
    let publicListsCount: Int
    // ... 소셜 관련 속성
}

struct UserFollow: Identifiable, Codable {
    let id: String  
    let followerId: String
    let followingId: String
    let createdAt: Date
}

struct UserRestaurantList: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let restaurantIds: [String]
    let isPublic: Bool
    // ... 리스트 관련 속성
}
```

### 데이터 흐름
1. **View**: 사용자 액션 발생
2. **ViewModel**: 액션 처리 및 Service 호출
3. **Service**: 비즈니스 로직 실행 및 데이터 처리  
4. **Data**: 로컬/원격 데이터 소스 접근
5. **Service**: 결과 데이터 반환
6. **ViewModel**: UI 상태 업데이트 (@Published)
7. **View**: 자동으로 UI 리렌더링

## 🔄 상태 관리

### SwiftUI의 상태 관리 활용
- **@State**: View 내부 상태
- **@StateObject**: ViewModel 인스턴스 생성
- **@ObservedObject**: ViewModel 관찰
- **@Published**: 자동 UI 업데이트 트리거
- **@EnvironmentObject**: 앱 전역 상태 공유

### 데이터 바인딩 패턴 (구현 완료)
```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    CategoryScrollView(
                        selectedCategory: viewModel.selectedCategory,
                        onCategorySelected: viewModel.selectCategory
                    )
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        FeaturedSection(title: "추천 맛집", restaurants: viewModel.recommendedRestaurants)
                        FeaturedSection(title: "인기 맛집", restaurants: viewModel.popularRestaurants)
                        FeaturedSection(title: "내 주변 맛집", restaurants: viewModel.nearbyRestaurants)
                    }
                }
            }
            .refreshable {
                viewModel.refreshData()
            }
        }
        .onAppear {
            if viewModel.recommendedRestaurants.isEmpty {
                viewModel.loadInitialData()
            }
        }
    }
}
```

### SearchView의 ViewModel 연동
```swift
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchTypeSelector(
                    selectedType: viewModel.selectedSearchType,
                    onTypeSelected: viewModel.selectSearchType
                )
                
                SearchBar(
                    text: $viewModel.searchText,
                    onSearchButtonClicked: viewModel.search
                )
                
                if viewModel.selectedSearchType == .restaurant {
                    FilterBar(
                        selectedCategory: $viewModel.selectedCategory,
                        selectedPriceRange: $viewModel.selectedPriceRange,
                        showFilters: $showFilters,
                        resultCount: viewModel.searchResults.count,
                        onFiltersApplied: viewModel.applyFilters,
                        onFiltersClear: viewModel.clearFilters
                    )
                }
                
                SearchResultsView(viewModel: viewModel)
            }
        }
    }
}
```

## 🚀 확장성 고려사항

### 1. 모듈화
- 각 기능별 독립적 모듈 구성
- 공통 컴포넌트의 재사용성 극대화
- 의존성 주입을 통한 결합도 감소

### 2. 성능 최적화
- 이미지 캐싱 (Kingfisher 도입 예정)
- 페이징을 통한 대용량 데이터 처리
- 지연 로딩 (Lazy Loading) 적용

### 3. 에러 핸들링
- 네트워크 오류 처리
- 사용자 친화적 오류 메시지
- 오프라인 상태 대응

### 4. 접근성
- VoiceOver 지원
- Dynamic Type 지원  
- 색상 대비 고려

## 🔧 개발 도구 및 패턴

### 사용 중인 패턴
- **MVVM**: 관심사 분리 및 테스트 용이성
- **Repository Pattern**: 데이터 소스 추상화 (예정)
- **Observer Pattern**: SwiftUI의 @Published/@ObservedObject

### 개발 도구
- **Xcode**: 통합 개발 환경
- **Swift Package Manager**: 의존성 관리 (예정)
- **Core Data**: 로컬 데이터 저장 (예정)

### 코딩 컨벤션
- Swift API 가이드라인 준수
- 명확한 네이밍과 주석
- 일관된 코드 스타일

## 📈 향후 아키텍처 발전 계획

### Phase 1: ViewModel 계층 완성 ✅
- ✅ 각 View별 ViewModel 구현 (5개 완료)
- ✅ 상태 관리 체계 확립 (@Published 프로퍼티 활용)
- 🔄 남은 View들의 ViewModel 연결 (진행 중)

### Phase 2: 데이터 계층 강화
- Core Data 모델 설계 및 구현
- Repository 패턴 도입
- 캐싱 전략 수립
- 실제 CRUD 동작 구현

### Phase 3: 네트워크 계층 구축
- REST API 클라이언트 구현
- 오프라인 동기화
- 실시간 업데이트 (WebSocket)
- API 서비스 계층 구현

### Phase 4: 고급 기능
- 푸시 알림 시스템
- 백그라운드 작업 처리
- 분석 및 로깅 시스템
- 성능 모니터링

### 현재 달성한 아키텍처 목표
- ✅ **MVVM 패턴 완전 구현**: 관심사 분리, 테스트 가능성 확보
- ✅ **반응형 UI**: SwiftUI + Combine을 활용한 데이터 바인딩
- ✅ **확장 가능한 구조**: 모듈화된 컴포넌트, 재사용 가능한 서비스
- ✅ **사용자 경험 개선**: 로딩 상태, 빈 상태, 오류 처리

이 아키텍처는 앱의 성장과 함께 지속적으로 발전시켜 나갈 예정입니다.