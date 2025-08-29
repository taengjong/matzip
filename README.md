# Matzip - 맛집 추천 & 리뷰 iOS 앱

맛집을 찾고 리뷰를 작성할 수 있는 iOS 앱입니다.

## 📱 주요 기능

### 🏠 홈 화면
- **맛집 추천**: 인기 맛집, 새로 오픈한 맛집, 내 주변 맛집
- **카테고리 탐색**: 한식, 중식, 일식, 양식, 카페, 패스트푸드, 디저트 등
- **통합 검색**: 맛집명, 음식 종류 검색

### 🔍 검색 화면  
- **실시간 검색**: 맛집명, 카테고리별 실시간 검색
- **필터링**: 음식 종류, 가격대별 필터
- **결과 표시**: 평점, 리뷰 수, 위치 정보 포함

### ❤️ 즐겨찾기 화면
- **맛집 저장**: 관심 맛집 즐겨찾기 추가/제거
- **카드형 레이아웃**: 상세 정보와 함께 보기 좋은 레이아웃
- **빠른 접근**: 저장한 맛집 목록 한눈에 보기

### 👤 프로필 화면
- **사용자 정보**: 프로필 사진, 이름, 이메일 관리
- **활동 통계**: 작성한 리뷰 수, 평균 평점, 즐겨찾기 수
- **설정 메뉴**: 알림, 다크모드, 위치 서비스 등
- **계정 관리**: 프로필 편집, 로그아웃

## 🏗️ 앱 아키텍처

### MVVM 패턴
```
├── Models/              # 데이터 모델
│   ├── Restaurant.swift    # 맛집 정보 모델
│   └── Review.swift       # 리뷰 & 사용자 모델
├── Views/               # UI 컴포넌트
│   ├── Home/           # 홈 화면 뷰
│   ├── Search/         # 검색 화면 뷰  
│   ├── Favorites/      # 즐겨찾기 화면 뷰
│   ├── Profile/        # 프로필 화면 뷰
│   └── Common/         # 공통 UI 컴포넌트
├── ViewModels/         # 비즈니스 로직
├── Services/           # API, 위치 서비스
└── Utils/             # 유틸리티 함수
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

## 🎨 UI/UX 디자인

### 디자인 시스템
- **주색상**: Orange (#FF9500)
- **배경색**: System Gray (.systemGray6)
- **텍스트**: Dynamic Type 지원
- **아이콘**: SF Symbols 활용
- **레이아웃**: 반응형 디자인

### 화면 구성
- **탭바**: 4개 메인 탭 (홈, 검색, 즐겨찾기, 프로필)
- **내비게이션**: Large Title, Inline Title 적절히 사용
- **카드형 레이아웃**: 맛집 정보를 카드로 표시
- **빈 상태 처리**: 검색 결과 없음, 즐겨찾기 없음 등

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
│   │   └── Review.swift
│   ├── Views/
│   │   ├── MainTabView.swift
│   │   ├── Home/
│   │   │   └── HomeView.swift
│   │   ├── Search/
│   │   │   └── SearchView.swift
│   │   ├── Favorites/
│   │   │   └── FavoritesView.swift
│   │   ├── Profile/
│   │   │   └── ProfileView.swift
│   │   └── Common/
│   ├── ViewModels/
│   ├── Services/
│   ├── Utils/
│   ├── Assets.xcassets/
│   ├── MatzipAppApp.swift
│   └── ContentView.swift
├── MatzipAppTests/
└── MatzipAppUITests/
```

## 🚀 개발 진행 상황

### ✅ 완료된 기능
- [x] 프로젝트 기본 설정
- [x] 데이터 모델 설계 (Restaurant, Review, User)
- [x] 메인 탭바 구현 (4개 탭)
- [x] 홈 화면 UI (추천 맛집, 카테고리 스크롤)
- [x] 검색 화면 UI (검색바, 필터, 결과 목록)
- [x] 즐겨찾기 화면 UI (저장된 맛집 목록)
- [x] 프로필 화면 UI (사용자 정보, 통계, 설정)
- [x] 기본 UI 컴포넌트 (카드, 필터, 빈 상태)

### 🔄 진행 중
- API 연동을 위한 Service 계층 구현
- Core Data를 이용한 로컬 데이터 저장
- 위치 기반 맛집 검색 기능

### 📋 예정된 기능
- 맛집 상세 화면
- 리뷰 작성 화면
- 지도 연동 (MapKit)
- 푸시 알림
- 사용자 인증
- 실제 API 서버 연동

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
