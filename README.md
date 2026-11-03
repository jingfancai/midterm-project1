# Polarsteps v2

Flutter 수업에서 만든 여행 기록 프로젝트입니다. 이번 프로젝트에서는 여행 목록을 날짜별로 나누고, 여행을 추가하거나 정보를 수정하는 흐름부터 만들었습니다. 이후 일정 계획, 사진 기록, 지도에서 지난 여행을 보는 기능까지 붙였습니다.

여행 데이터는 json-server에서 GET으로 읽습니다. 화면에서 바꾼 내용은 메모리에만 남기 때문에 새로고침하면 사라집니다. 로컬에서 살펴보려면 아래 실행 방법대로 서버와 앱을 각각 켜면 됩니다.

## 앱 소개

### 앱 이름
Polarsteps v2

### 부제
여행 날짜를 확인하고 사진과 이야기를 남기는 여행 기록 앱

### 카테고리
여행

### 대상 사용자 / 사용 상황
여행 전에는 일정을 정리하고, 여행 중에는 사진과 짧은 기록을 남기고 싶은 대학생이나 개인 여행자를 생각하며 만들었습니다. 모바일 크기의 브라우저에서 기록하고, 여행이 끝난 뒤 데스크톱에서 목록과 회고 화면을 볼 수 있도록 창 크기에 따라 배치를 바꿨습니다.

### 스크린샷
최신 화면 캡처는 아직 정리하지 못했습니다. 아래 순서대로 `docs/screenshots/`에 넣을 예정입니다. 이전 발표자료의 캡처를 최신 화면으로 대신 쓰지는 않았습니다.

| v1 현행 | v2 화면 A | v2 화면 B | v2 화면 C | v2 넓은 화면 |
|---|---|---|---|---|
| TODO: `01_v1_current.png` | TODO: `02_v2_a.png` | TODO: `03_v2_b.png` | TODO: `04_v2_c.png` | TODO: `05_v2_wide.png` |
| 현행 앱 · 출처 확인 필요 | 여행 목록 | 여행 상세 · 계획/기록 | 기록 모아보기 | 넓은 창 배치 |

### 설명
여행이 많아지면 예정된 여행과 이미 끝난 여행을 구분해서 보고 싶을 것 같아, 시작일과 종료일에 따라 목록을 나눴습니다. 목록에서 여행을 선택하면 상세 정보와 기록을 볼 수 있고, 잘못 입력한 제목이나 날짜도 같은 화면에서 수정할 수 있습니다.

계획은 미래 여행과 진행 중인 여행에서 관리합니다. 기록은 여행이 시작된 뒤 작성할 수 있습니다. 두 기능을 구분해 아직 출발하지 않은 여행에 기록을 남기거나, 지난 날짜의 계획 내용을 바꾸는 일을 막았습니다. 실제 사용자 리뷰를 바탕으로 한 검증은 아직 보완이 필요합니다.

### 새로운 기능
중심이 된 변경은 다음 세 가지입니다. 리뷰 원문과 출처는 아래 평가 및 리뷰 항목에 따로 보완할 예정입니다.

| P번호 | 바뀐 것 (화면 · 요소 번호) | 근거 (리뷰 · 원칙) |
|---|---|---|
| P06 | A-2: 다가오는 여행·진행 중인 여행·지난 여행으로 목록 구분 | 날짜를 하나씩 읽지 않아도 여행 상태를 구분하도록 함 |
| P05 | A-11: + 버튼에서 여행 이름·목적지·날짜를 입력해 여행 추가 | 같은 폼에서 필수 항목과 날짜를 확인하고 잘못된 입력을 안내함 |
| P03 · P05 | B-1/B-8: 상세에서 여행 정보 수정, 저장 전 취소 | 기존 화면에서 정보를 고치되 취소하면 원래 값을 유지함 |

추가로 여행 계획과 완료 체크, 기록별 사진 한 장, 상단 여행 사진 모음도 만들었습니다. 여행지 추천은 로컬 도시 목록을 검색하는 Dialog입니다. 기록 모아보기에서는 방문 통계와 정적 세계 지도를 확인하고, 종료된 여행의 추억 카드를 골라 PNG로 내보낼 수 있습니다.

### 평가 및 리뷰

| 항목 | 내용 |
|---|---|
| 현행 별점 | TODO: 스토어에서 다시 확인 |
| 리뷰 수 | TODO: 확인 날짜와 함께 기록 |
| 대표 리뷰 | TODO: 원문·별점·날짜 확인 후 인용, 작성자 이름은 제외 |
| 출처 | TODO: 스토어 링크와 확인 날짜 |

이전 발표자료에는 평점과 리뷰가 적혀 있지만 집계와 일부 별점이 일치하지 않아, 확인 전까지 확정된 수치로 옮기지 않았습니다.

## 작성자 · 제출 정보

| 칸 | 내용 |
|---|---|
| 현행 앱 | Polarsteps — TODO: 비교한 버전과 스토어 링크 확인 |
| v2 한 문장 | 여행 상태를 나눠 보고, 여행 정보와 사진 기록을 수정하는 Flutter 프로젝트 |
| 작성자 | TODO: 제출할 이름 또는 이니셜 확인 · 1인 1팀 |
| 데모 | [데모 영상.mp4](docs/영상/데모%20영상.mp4) — 약 1분 42초. 제출용 1분 길이는 별도 확인 필요 |
| AI 사용 | [AGENTS.md](AGENTS.md) · [prompt-log](docs/prompt-log.md) · [셀프 논증](docs/셀프논증.md). 실제 사용 내역과 발표자료 연결 확인 필요 |

## 0. 처음 받았을 때: 폴더 이름 · 앱 이름 바꾸기

저장소 이름은 `midterm-project1`, Dart 패키지 이름은 `mid_project_template`입니다. 패키지 이름을 바꾸려면 `pubspec.yaml`과 테스트의 import도 함께 수정해야 해서 그대로 두었습니다.

`lib/main.dart`의 제목은 `Polarsteps v2`입니다. Android/iOS 표시 이름과 웹 title/manifest에는 템플릿 이름이 남아 있으므로 제출 전 확인이 필요합니다. 교수 템플릿은 한글 경로에서 분석 오류가 날 수 있다고 안내하므로, 문제가 생기면 `~/dev/`처럼 영문 경로에서 실행해 보세요.

## 1. 실행 방법 — 터미널 2개

Flutter와 Chrome, Node.js 18 이상이 필요합니다. `pubspec.yaml`의 Dart SDK 조건은 `^3.10.0`입니다. 먼저 `flutter --version`, `node --version`으로 설치 여부를 확인해 주세요.

처음 받는 경우:

```bash
git clone https://github.com/jingfancai/midterm-project1.git
cd midterm-project1
```

터미널 1에서는 목업 서버를 켭니다. `npm ci`는 처음 실행하거나 lockfile이 바뀌었을 때 하면 됩니다.

```bash
cd mock_server
npm ci
npm start
```

터미널 2에서는 저장소 루트로 이동해 앱을 실행합니다. 서버 터미널은 닫지 않습니다.

```bash
cd /path/to/midterm-project1
flutter pub get --enforce-lockfile
flutter run -d chrome
```

`/path/to/midterm-project1`은 실제 저장한 경로로 바꿔 주세요. 서버 연결이 안 되면 `curl http://localhost:3000/items`로 JSON 배열이 나오는지 먼저 확인하면 됩니다.

Chrome과 데스크톱, iOS 시뮬레이터는 `http://localhost:3000`, Android 에뮬레이터는 `http://10.0.2.2:3000`을 사용합니다. 이 구분은 `lib/api.dart`에 있습니다. 실기기는 PC와 같은 Wi-Fi에 연결한 뒤 실제 PC IP를 지정해야 합니다.

```bash
flutter run --dart-define=API_BASE=http://192.168.0.10:3000
```

위 IP는 예시입니다. PC 방화벽과 HTTP 접근 설정도 확인해야 합니다. 서버의 실행 방식은 [mock_server/README.md](mock_server/README.md)에 정리되어 있습니다. Web에서 로컬 사진 선택과 PNG 다운로드를 지원하며, 네이티브에는 별도 파일 선택·저장 플러그인을 붙이지 않았습니다.

### 상태 화면 시연 — `DEMO_STATE` (발표·영상용)

```bash
flutter run -d chrome --dart-define=DEMO_STATE=loading
flutter run -d chrome --dart-define=DEMO_STATE=error
flutter run -d chrome --dart-define=DEMO_STATE=empty
```

A 목록의 상태를 확인할 때 사용합니다. `loading`은 3초 기다린 뒤 GET을 하므로 이후 목록을 보려면 서버가 켜져 있어야 합니다. B의 기록 탭은 별도로 GET 결과에 따라 로딩·오류·빈 상태를 보여 줍니다.

## 2. 구조

```text
lib/
├── main.dart / api.dart / models.dart / widgets.dart
├── screens/
│   ├── a_list_screen.dart          # 여행 목록
│   ├── b_detail_screen.dart        # 여행 상세
│   ├── c_result_sheet.dart         # 기록 모아보기
│   └── e_recommendations_dialog.dart  # A의 여행지 추천 Dialog
├── trip_editor.dart / trip_insights.dart / destinations.dart
├── trip_plans.dart / travel_plans_section.dart
├── trip_photos.dart / photo_picker*.dart
├── travel_notes.dart / visited_places_map.dart
└── travel_memory_card.dart / png_download*.dart
assets/       # destinations.json, 정적 세계 지도와 사진 출처
mock_server/  # db.json, GET 서버, 서버 테스트
test/        # 위젯·날짜·사진·검색·지도·PNG 회귀 테스트
docs/         # 디자인 가이드, 원칙 카드, 논증 기록, 영상, 스크린샷 자리
```

## 3. 화면 목록 ↔ 기획 문서 요소 번호

화면 구성은 A 목록, B 상세, C 기록 모아보기로 나눴습니다. 아래 요소 번호는 [디자인 가이드](docs/디자인가이드.md)와 코드 상단 주석을 따라갑니다.

| 화면 | 역할 | 파일 | 이동 방식 | 요소 번호 |
|---|---|---|---|---|
| A | 여행 목록 | `a_list_screen.dart` | 첫 화면 | A-1 ~ A-13 |
| B | 여행 상세 · 정보/기록 탭 | `b_detail_screen.dart` | A 또는 C 전체 여행 목록에서 push | B-1 ~ B-17 |
| C | 기록 모아보기 · 통계/지도/전체 여행 | `c_result_sheet.dart` | A에서 BottomSheet | C-1 ~ C-10 |
| A의 보조 Dialog E | 여행지 추천 | `e_recommendations_dialog.dart` | A에서 Dialog | E-1 ~ E-4 |

C 안의 추억 카드 미리보기는 `TravelMemoryDialog`입니다. 별도 페이지가 아니며 B의 카드 만들기 버튼에서도 같은 Dialog를 엽니다. 지도 Marker는 도시 여행 개요만 보여 주고 상세로 이동하지 않습니다. C의 전체 여행 목록에서는 B로 들어갈 수 있습니다.

### 구현 내용

A는 `FutureBuilder`로 GET 결과를 받고 `LoadingView`, `ErrorView`, `EmptyView`를 나눠 표시합니다. `LayoutBuilder`에서 창 너비가 600dp 이상이면 격자를 사용합니다. 검색과 즐겨찾기 필터, 그룹 안의 정렬도 현재 목록에 적용됩니다.

B는 `TabBar`와 `TabBarView`로 정보와 기록을 구분했습니다. 계획 날짜는 `DatePicker`, 시간은 12시간 AM/PM `TimePicker`로 입력합니다. 미래 여행은 전체 여행 기간, 진행 중인 여행은 로컬 오늘부터 종료일까지 선택할 수 있습니다. 지난 날짜 계획의 내용은 바꿀 수 없지만 진행 중에는 완료 체크가 가능합니다. 종료 여행에서는 계획 영역을 숨깁니다.

여행 기록은 시작된 여행에서만 추가·편집·삭제할 수 있습니다. 기록마다 독립 사진 한 장을 붙일 수 있고 상단 사진과 섞이지 않습니다. 상단 사진은 최대 다섯 장이며 썸네일과 스와이프로 바꿔 봅니다. 사진은 장당 10MB/60MP 제한을 확인한 뒤 긴 축 1920px 이하의 PNG로 변환합니다.

여행지 추천은 `destinations.json`의 50개 도시를 도시명·국가·테마로 검색하는 기능입니다. AI 추천은 아닙니다. 지도도 Google Maps가 아니라 번들 세계 지도 위에 도시 좌표를 찍은 것입니다. 통계와 지도에는 이미 시작한 유효한 여행만 방문 도시/국가로 집계합니다.

추억 카드는 종료 여행에서만 만듭니다. 심플·엽서·사진 콜라주 중 하나를 고르면 기존 여행 사진과 글로 미리보기를 구성하고, `RepaintBoundary`를 PNG로 내보냅니다. 기본 목적지 사진은 기존 외부 이미지 URL을 사용하며, 출처는 [assets/images/README.md](assets/images/README.md)에 있습니다.

HTTP 요청은 `lib/api.dart`의 GET `/items`, `/notes?itemId=`뿐입니다. 여행·즐겨찾기·계획·상단 사진은 A가 가진 메모리를 공유합니다. 기록과 기록 사진은 현재 상세 화면 안에서만 유지됩니다. 상세를 닫고 다시 들어오면 기록은 GET 원본으로 돌아가고, 새로고침하면 공유 메모리 변경도 사라집니다.

## 4. 원칙 번호 추적 P01–P10 [권장]

원칙 번호를 코드 주석과 [원칙 카드](docs/원칙카드.md)에 같이 적어 두었습니다. 실제 사용자 리뷰에 근거한 평가는 아직 보완이 필요합니다.

| 번호 | 적용한 부분 |
|---|---|
| P01 | 로딩/빈 상태, 계획 완료 진행률 |
| P02 | 사진·여행 제목·날짜·장소 순서 |
| P03 | 뒤로가기, 편집 취소, 삭제 확인/실행 취소 |
| P04 | 공통 색상·버튼·탭 구성 |
| P05 | 필수 입력과 날짜 범위 확인 |
| P06 | 여행 상태 구분, 사진·태그·지도 개요 |
| P07 | 검색·필터·정렬, 기존 폼 재사용 |
| P08 | 중복 사진 영역을 줄이고 여백 유지 |
| P09 | GET 재시도, PNG 실패 안내 |
| P10 | 날짜 제한과 메모리 초기화 안내 |

`rg -n 'P09' lib`, `git log --oneline --grep='p09'`로 코드와 커밋을 찾을 수 있습니다. 발표자료의 번호도 여기에 맞춰 확인해야 합니다.

## 5. 기준점 Git 태그 `v1-plan` [권장]

기획 확정 시점을 남기는 태그입니다. 현재 로컬에는 없고 원격 태그는 확인이 필요합니다. 이미 있는 태그를 덮어쓰거나 지금을 과거 기획 시점처럼 표시하지 않도록 합니다.

```bash
git tag -l v1-plan
git ls-remote --tags origin v1-plan
# 확정한 커밋과 기존 태그를 확인한 뒤 필요한 경우에만 실행
# git tag -a v1-plan <확정한-커밋> -m "화면 기획 확정"
# git push origin v1-plan
# git log v1-plan..HEAD --oneline
# git diff v1-plan..HEAD --stat
```

변경 이유는 [셀프논증.md](docs/셀프논증.md), AI 요청과 판단은 [prompt-log.md](docs/prompt-log.md)에 남깁니다.

## 6. 영상 파일 이름

현재 저장소에 올린 영상입니다. 파일명은 업로드한 이름 그대로이며, 실제 장면과 원칙 카드의 연결은 제출 전에 다시 확인해야 합니다.

- [데모 영상.mp4](docs/영상/데모%20영상.mp4): 약 1분 42초, 전체 시연. 과제의 1분 조건에 맞춘 편집은 필요합니다.
- [p3.mov](docs/영상/p3.mov), [p6.mov](docs/영상/p6.mov), [p7.mov](docs/영상/p7.mov): 원칙 시연용 짧은 영상.

교수 템플릿의 권장 이름은 `demo_1min.mp4`, `p01.mp4` 같은 형식입니다. 현재 파일명이 그 형식과 다르다는 점은 제출할 때 확인할 예정입니다. 녹화본에 개인정보나 알림이 없는지도 함께 확인해야 합니다.

## 7. 감점 점검 (제출 전, 결과가 비어 있어야 함)

```bash
grep -rnE "http\.(post|put|patch|delete)|SharedPreferences|sqflite|hive|FirebaseAuth|ChangeNotifierProvider|Riverpod|BlocProvider" lib/ pubspec.yaml
```

현재는 서버 쓰기나 영구 저장 없이 `setState`와 콜백으로 데이터를 바꿉니다. 다만 실제 상태 변경, 검색·집계·날짜 계산, 사진 처리와 PNG 내보내기는 구현되어 있습니다. 위 검색 결과가 비어 있어도 과제의 UI 전용 규칙을 모두 충족한다고 볼 수는 없습니다. 남은 위험은 [디자인 가이드 11장](docs/디자인가이드.md)과 [자가평가](docs/자가평가.md)에 적어 두었습니다.

## 8. 제출 전 clone 테스트 [필수 확인]

새 폴더에서 받아 1절 명령만으로 실행되는지 확인합니다. 서버를 켠 뒤 GET 목록, A→B 이동, C와 보조 Dialog를 열어 봅니다. 창 크기를 바꾸고 `DEMO_STATE`로 오류/빈 상태도 확인합니다. 사진·계획·기록을 바꾼 뒤 새로고침했을 때 원본으로 돌아오는지도 살펴봐야 합니다.

```bash
flutter analyze
flutter test
node --test mock_server/test/persistence.test.js
flutter build web
```

테스트 코드는 있지만 현재 작업 환경에는 Flutter SDK가 없어 전체 분석·테스트·빌드를 확인하지 못했습니다. 서버 테스트도 이전 환경에서 로컬 포트 권한 문제로 막혔습니다. 실행 가능한 환경에서 버전과 실제 결과를 기록하는 일은 남아 있습니다.

## 9. 확인된 상태 (템플릿 배포 시점)

원본 템플릿의 `flutter analyze` 0 issues와 테스트 4개 통과는 템플릿 배포 당시 결과입니다. 지금 프로젝트의 테스트 결과로 쓰지는 않았습니다. 현재 의존성은 Flutter SDK, `cupertino_icons`, `http`와 개발용 `flutter_test`, `flutter_lints`입니다. 이번 README 수정에서는 앱 테스트를 새로 실행하지 않았습니다.

## 10. 아쉬웠던 점 / 개선할 점

아쉬운 점은 화면에서 바꾼 내용이 새로고침 후 사라진다는 것입니다. 현재는 과제 범위에 맞춰 서버 쓰기와 데이터 영구 저장을 넣지 않았습니다. 이후에는 허용 범위를 먼저 정한 뒤 여행 정보와 사진을 다시 불러올 수 있게 저장 방식을 붙이고 싶습니다.

정적 지도는 도시를 확인하는 정도로는 쓸 수 있지만 실제 이동 경로나 자세한 위치를 보여 주지는 못합니다. 지도 API 연동과 더 넓은 목적지 목록도 다음에 검토할 부분입니다. 우선은 최신 스크린샷을 정리하고, 다른 기기에서 실행해 보면서 날짜 제한과 사진 선택 흐름을 더 확인해야 합니다.
