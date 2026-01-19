# MovieSearch

OMDb API를 사용하여 영화를 검색하고 즐겨찾기에 등록할 수 있는 iOS 앱입니다.  
UI는 코드베이스로 구현했으며, 검색 탭 / 즐겨찾기 탭 총 2개의 하단 탭으로 구성됩니다.

---

## 개발 환경

- Xcode: 16+
- Swift: 5.9+
- iOS Deployment Target: 16+
- UI: SwiftUI + UIKit(컬렉션뷰) 혼합
- 레이아웃: AutoLayout 기반
- 네트워크: URLSession 기반
- 이미지 로딩: Kingfisher (SPM)

---

## API

- OMDb Search API  
  `http://www.omdbapi.com/?apikey=92e32667&s={검색어}&page={페이지번호}`

### 응답 예시

```json
{
  "Search": [
    {
      "Title": "Batman Begins",
      "Year": "2005",
      "imdbID": "tt0372784",
      "Type": "movie",
      "Poster": "https://..."
    }
  ],
  "Response": "True",
  "totalResults": "123"
}
```
---

## 앱 구성

### 탭 구조

1) 검색 탭
	-	네비게이션 바에 검색창 노출
	-	초기 상태: “검색결과가 없습니다.” 표시

2) 즐겨찾기 탭<br>
	-	네비게이션 타이틀: “내 즐겨찾기”
	-	즐겨찾기 목록 표시

---

### 주요 기능

1) 영화 검색
	-	검색창 입력 후 키보드의 검색 버튼(submitLabel(.search))으로 검색 수행
	-	검색 성공 시:
		-	결과를 2열 카드 그리드 형태로 표시
		-	검색 후 리스트는 항상 최상단으로 이동

2) 페이징(무한 스크롤)
	-	검색 결과 목록에서 하단 근처 도달 시 다음 페이지를 요청하여 이어서 로딩
	-	totalResults와 현재 로딩된 개수를 비교하여 hasNextPage를 관리

3) 즐겨찾기 추가/삭제
	-	검색 결과에서 영화 선택 시 팝업(액션 선택) 표시
		-	즐겨찾기 추가 / 즐겨찾기 제거 / 취소
	-	즐겨찾기된 영화는 검색 목록에서 아이콘(★)으로 구분 표시
	-	즐겨찾기 탭에서도 동일한 카드 UI로 목록 표시
	-	즐겨찾기 탭에서 항목 선택 시 제거 가능
	-	즐겨찾기 데이터 자동 저장(영속화)되어 앱 종료 후 다시 실행해도 유지됨

---

## UI 구현 방식

1) SwiftUI + UICollectionView 조합

	검색/즐겨찾기 목록은 UICollectionViewCompositionalLayout 기반 2열 그리드로 구현했습니다.
	-	SwiftUI: 화면 구조, 검색창, 탭, 상태 관리
	-	UIKit: 카드형 2열 그리드 성능 및 제어를 위해 UICollectionView 사용
	-	UIViewRepresentable로 SwiftUI에 컬렉션뷰를 래핑하여 사용합니다.

2) Diffable Data Source

	컬렉션뷰는 UICollectionViewDiffableDataSource를 사용합니다.
	-	Diffable identifier는 MovieItem 전체가 아닌 imdbID(String) 를 사용하여
		API 응답에 중복 영화가 섞이는 경우에도 크래시가 발생하지 않도록 처리했습니다.
	-	즐겨찾기 상태(★ 배지)는 favorites 변경 시 snapshot reload 방식으로 즉시 갱신합니다.

---

## 이미지 처리 (Kingfisher)
-	포스터 URL이 nil, "N/A", 또는 로딩 실패(404 등)인 경우를 고려하여 placeholder 이미지를 표시합니다.
-	셀 재사용 시 이미지 다운로드 작업을 취소하여 이미지가 뒤섞이지 않도록 처리했습니다.

### Kingfisher 사용 이유

포스터 이미지는 네트워크를 통해 비동기로 로딩되며, 스크롤이 많은 그리드 UI에서는 이미지 로딩/캐싱 최적화가 중요합니다.<br>
Kingfisher를 사용하여 다음을 안정적으로 처리했습니다.
-	메모리/디스크 캐싱을 통해 동일 이미지 재요청을 줄이고 스크롤 성능을 개선
-	셀 재사용 시 발생할 수 있는 이미지 깜빡임/뒤섞임 문제를 최소화
-	이미지 로딩 실패(404 등) 및 "N/A" 케이스에 대해 placeholder 처리를 간단하게 적용 가능

---

## 상태 관리 / ViewModel
### SearchTabViewModel
-	검색 결과 목록 상태
-	로딩 상태
-	다음 페이지 여부 관리

주요 함수:
-	search(query:)
-	loadNextPageIfNeeded()
-	resetSearch()
---
### FavoritesTabViewModel
-	즐겨찾기 목록 및 즐겨찾기 여부 관리
-	Set 기반으로 빠르게 즐겨찾기 여부 확인
-	추가/삭제 시 즉시 목록 반영
-	즐겨찾기 데이터 영속화를 위한 파일 저장 및 로드

주요 함수:
-	isFavorite(_:)
-	add(_:)
-	remove(id:)
-	toggle(_:)
-	move(from:to:)
-	load()<br>
-	save()<br>

---

## 데이터 영속화 (선택 구현)

즐겨찾기 목록은 JSON 파일로 저장/로드하도록 구현했습니다.
-	저장 위치: Application Support Directory
-	파일명: favorites.json
-	앱 재시작 후에도 즐겨찾기 탭에서 동일한 상태로 복원됩니다.

---

## 즐겨찾기 순서 변경 (선택 구현)
-	즐겨찾기 탭에서 영화 카드의 순서를 드래그 & 드롭으로 변경할 수 있습니다.
-	순서 변경 결과는 즉시 UI에 반영되며, 저장(영속화)에도 반영됩니다.

### 구현 방식 선택 이유
즐겨찾기 순서 변경은 UICollectionView의 기본 beginInteractiveMovementForItem 기반 이동 기능 대신,<br>
UICollectionViewDragDelegate / UICollectionViewDropDelegate를 이용한 Drag & Drop 방식으로 구현했습니다.
-	UICollectionViewDiffableDataSource를 사용하는 구조에서 기본 이동 방식은 DataSource 이동 처리와<br>
	스냅샷 갱신 타이밍이 꼬일 수 있어 안정적인 동기화가 어려웠습니다.
-	Drag & Drop 방식은 이동 시작/드롭 시점을 명확히 제어할 수 있어, ViewModel의 배열 순서 변경 → 스냅샷 재적용<br>
  	흐름으로 구현하기가 더 안정적이었습니다.
-	결과적으로 즐겨찾기 탭에서 순서 변경 시 UI 반영과 데이터 영속화(JSON 저장)가 일관되게 동작하도록 구성했습니다.

---

## 실행 방법
1.	프로젝트 클론
2.	Xcode에서 MovieSearch.xcodeproj 열기
3.	실행 대상(iPhone) 선택 후 Run

---

## 참고 사항
-	OMDb API 응답에서 동일한 영화(imdbID)가 중복 포함되는 경우가 있어,<br>
	목록 구성 시 중복 제거 및 Diffable identifier를 imdbID 기반으로 구성했습니다.
