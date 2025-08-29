# Matzip - 맛집 공유 & 발견 iOS 앱

맛집을 공유하고 발견할 수 있는 소셜 맛집 플랫폼 iOS 앱입니다.

## 📱 주요 기능

### 🏠 홈 화면
- **맛집 추천**: 인기 맛집, 새로 오픈한 맛집, 내 주변 맛집
- **카테고리 탐색**: 한식, 중식, 일식, 양식, 카페, 패스트푸드, 디저트 등
- **통합 검색**: 맛집명, 음식 종류 검색

### 🔍 검색 화면  
- **실시간 검색**: 맛집명, 카테고리별 실시간 검색
- **사용자 검색**: 다른 사용자 찾기 및 팔로우
- **필터링**: 음식 종류, 가격대별 필터
- **결과 표시**: 평점, 리뷰 수, 위치 정보 포함

### 👥 피드 화면 (NEW!)
- **소셜 피드**: 팔로잉한 사용자들의 맛집 활동
- **맛집 리스트 공유**: 새로 만든 맛집 리스트 소식
- **실시간 업데이트**: 맛집 추가, 리뷰 작성 등 활동 피드

### ❤️ 즐겨찾기 화면
- **맛집 저장**: 관심 맛집 즐겨찾기 추가/제거
- **맛집 리스트**: 사용자 정의 맛집 컬렉션 생성
- **공개/비공개**: 맛집 리스트 공유 설정
- **카드형 레이아웃**: 상세 정보와 함께 보기 좋은 레이아웃

### 👤 프로필 화면
- **사용자 정보**: 프로필 사진, 이름, 이메일, 소개글
- **활동 통계**: 작성한 리뷰 수, 평균 평점, 즐겨찾기 수
- **소셜 기능**: 팔로워/팔로잉 수, 공개 리스트 수
- **팔로우 관리**: 팔로워/팔로잉 목록 및 관리
- **설정 메뉴**: 알림, 다크모드, 위치 서비스 등

## 🏗️ 앱 아키텍처

### MVVM 패턴
```
├── Models/              # 데이터 모델
│   ├── Restaurant.swift       # 맛집 정보 모델
│   ├── Review.swift          # 리뷰 & 사용자 모델
│   ├── UserFollow.swift      # 팔로우 관계 모델
│   └── UserRestaurantList.swift # 사용자 맛집 리스트 모델
├── Views/               # UI 컴포넌트
│   ├── Home/           # 홈 화면 뷰
│   ├── Search/         # 검색 화면 뷰 (맛집 + 사용자)
│   ├── Feed/           # 피드 화면 뷰 (소셜 피드)
│   ├── Favorites/      # 즐겨찾기 화면 뷰
│   ├── Follow/         # 팔로우 관리 뷰
│   ├── Profile/        # 프로필 화면 뷰
│   └── Common/         # 공통 UI 컴포넌트
├── ViewModels/         # 비즈니스 로직 (예정)
├── Services/           # 서비스 계층
│   ├── UserFollowService.swift      # 팔로우 관리 서비스
│   └── UserRestaurantService.swift  # 맛집 리스트 관리 서비스
└── Utils/              # 유틸리티
    └── SampleData.swift  # 샘플 데이터
```

### 데이터 모델 설계

#### Restaurant (맛집)
```swift
- id: 고유 식별자
- name: 맛집명
- category: 음식 카테고리 (한식, 중식, 일식 등)
- address: 주소
- coordinate: 위도, 경도
- phoneNumber: 전화번호
- rating: 평점 (1.0-5.0)
- reviewCount: 리뷰 개수
- priceRange: 가격대 (₩, ₩₩, ₩₩₩, ₩₩₩₩)
- openingHours: 운영시간
- description: 설명
- imageURLs: 이미지 URL 배열
- isFavorite: 즐겨찾기 여부
```

#### Review (리뷰)
```swift
- id: 고유 식별자
- restaurantId: 맛집 ID
- userId: 사용자 ID
- userName: 사용자명
- rating: 평점
- content: 리뷰 내용
- imageURLs: 리뷰 이미지들
- createdAt: 작성일
```

#### User (사용자)
```swift
- id: 고유 식별자
- name: 사용자명
- email: 이메일
- profileImageURL: 프로필 이미지 URL
- reviewCount: 작성한 리뷰 수
- averageRating: 평균 평점
- followersCount: 팔로워 수
- followingCount: 팔로잉 수
- publicListsCount: 공개 리스트 수
- bio: 자기소개
- createdAt: 가입일
```

#### UserFollow (팔로우 관계)
```swift
- id: 고유 식별자
- followerId: 팔로워 사용자 ID
- followingId: 팔로잉 사용자 ID
- createdAt: 팔로우 시작일
```

#### UserRestaurantList (사용자 맛집 리스트)
```swift
- id: 고유 식별자
- userId: 작성자 ID
- name: 리스트명
- description: 리스트 설명
- restaurantIds: 포함된 맛집 ID 배열
- isPublic: 공개 여부
- createdAt: 생성일
- updatedAt: 수정일
```

## 🎨 UI/UX 디자인

### 디자인 시스템
- **주색상**: Orange (#FF9500)
- **배경색**: System Gray (.systemGray6)
- **텍스트**: Dynamic Type 지원
- **아이콘**: SF Symbols 활용
- **레이아웃**: 반응형 디자인

### 화면 구성
- **탭바**: 5개 메인 탭 (홈, 검색, 피드, 즐겨찾기, 프로필)
- **내비게이션**: Large Title, Inline Title 적절히 사용
- **카드형 레이아웃**: 맛집 정보를 카드로 표시
- **소셜 UI**: 팔로우 버튼, 사용자 프로필, 피드 아이템
- **빈 상태 처리**: 검색 결과 없음, 즐겨찾기 없음, 피드 없음 등

## 🛠️ 기술 스택

- **Framework**: SwiftUI (iOS 16.2+)
- **Architecture**: MVVM Pattern
- **Location**: CoreLocation
- **Image Loading**: AsyncImage
- **Data Persistence**: Core Data (예정)
- **Networking**: URLSession (예정)
- **Maps**: MapKit (예정)

## 📁 프로젝트 구조

```
MatzipApp/
├── MatzipApp.xcodeproj/
├── MatzipApp/
│   ├── Models/
│   │   ├── Restaurant.swift
│   │   ├── Review.swift
│   │   ├── UserFollow.swift
│   │   └── UserRestaurantList.swift
│   ├── Views/
│   │   ├── MainTabView.swift
│   │   ├── Home/
│   │   │   └── HomeView.swift
│   │   ├── Search/
│   │   │   ├── SearchView.swift
│   │   │   └── UserSearchView.swift
│   │   ├── Feed/
│   │   │   └── FeedView.swift
│   │   ├── Follow/
│   │   │   └── FollowListView.swift
│   │   ├── Favorites/
│   │   │   └── FavoritesView.swift
│   │   ├── Profile/
│   │   │   └── ProfileView.swift
│   │   └── Common/
│   ├── ViewModels/ (예정)
│   ├── Services/
│   │   ├── UserFollowService.swift
│   │   └── UserRestaurantService.swift
│   ├── Utils/
│   │   └── SampleData.swift
│   ├── Assets.xcassets/
│   ├── MatzipAppApp.swift
│   └── ContentView.swift
├── MatzipAppTests/
└── MatzipAppUITests/
```

## 🚀 개발 진행 상황

### ✅ 완료된 기능
- [x] 프로젝트 기본 설정
- [x] 데이터 모델 설계 (Restaurant, Review, User, UserFollow, UserRestaurantList)
- [x] 메인 탭바 구현 (5개 탭)
- [x] 홈 화면 UI (추천 맛집, 카테고리 스크롤)
- [x] 검색 화면 UI (맛집 + 사용자 검색)
- [x] 소셜 피드 화면 UI (팔로잉 사용자 활동)
- [x] 즐겨찾기 화면 UI (저장된 맛집 + 맛집 리스트)
- [x] 프로필 화면 UI (사용자 정보, 통계, 팔로우 관리)
- [x] 팔로우 관리 화면 (팔로워/팔로잉 목록)
- [x] 사용자 검색 기능
- [x] 서비스 계층 구현 (UserFollowService, UserRestaurantService)
- [x] 샘플 데이터 구성
- [x] 기본 UI 컴포넌트 (카드, 필터, 빈 상태)

### 🔄 진행 중
- ViewModels 계층 구현 (MVVM 패턴 완성)
- 맛집 리스트 CRUD 기능
- 피드 실시간 업데이트 로직

### 📋 예정된 기능
- 맛집 상세 화면
- 리뷰 작성 화면
- 지도 연동 (MapKit)
- Core Data를 이용한 로컬 데이터 저장
- 푸시 알림
- 사용자 인증
- 실제 API 서버 연동
- 위치 기반 맛집 검색 기능

## 💻 시작하기

### 요구사항
- **Xcode**: 16.2+
- **iOS**: 16.2+
- **Swift**: 5.0+

### 설치 및 실행
1. 저장소 클론
```bash
git clone https://github.com/yourusername/matzip.git
cd matzip/MatzipApp
```

2. Xcode에서 프로젝트 열기
```bash
open MatzipApp.xcodeproj
```

3. 시뮬레이터에서 실행 (⌘ + R)

### 빌드 설정
- **Bundle Identifier**: kr.jongheeyun.MatzipApp
- **Deployment Target**: iOS 16.2
- **Supported Orientations**: Portrait, Landscape

## 📚 문서
- [API 명세서](./Docs/API.md) (예정)
- [UI 디자인 가이드](./Docs/UI-Guide.md) (예정)
- [개발 가이드](./Docs/Development.md) (예정)

## 🤝 기여하기
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이센스
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 개발자
- **이름**: 윤종희
- **이메일**: jongheeyun@example.com
- **GitHub**: [@jongheeyun](https://github.com/jongheeyun)
