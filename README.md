# Polarsteps v2 — GAI3008 중간프로젝트

## 앱 소개

> 교수 [mid-project-template 원본 README](https://github.com/xide-projext/mid-project-template/blob/main/README.md)의 칸 이름과 순서를 유지합니다. 아래 설명은 현재 저장소 구현 기준이며 실제 서비스의 스토어 소개·평가와 구분합니다.

### 앱 이름
Polarsteps v2

### 부제
여행 계획부터 사진 일기와 추억 카드까지, 나의 여정을 한곳에서

### 카테고리
여행 — UI 프로토타입의 분류이며 실제 스토어 등록을 뜻하지 않습니다.

### 대상 사용자 / 사용 상황
- 대상 사용자: 여행 일정을 준비하고, 여행 중 사진과 이야기를 남기며, 여행 후 추억을 돌아보고 싶은 대학생 및 개인 여행자.
- 사용 상황: 여행 전 집에서 데스크톱으로 목적지와 일정을 탐색하고, 여행 중 모바일 크기의 브라우저에서 기록하며, 여행 후 큰 화면에서 지도와 추억 카드를 살펴보는 상황. 로컬 사진 선택·PNG 다운로드는 현재 Web 구현 범위입니다.

### 스크린샷
이미지는 `docs/screenshots/`에 넣습니다. 현재 확인된 제출용 이미지가 없어 아래는 **파일명 안내와 TODO**만 표시합니다. 실제 캡처를 추가한 뒤 이미지 링크로 교체합니다. 왼쪽부터 v1(현행) → v2 순서를 유지합니다.

| v1 현행 | v2 화면 A | v2 화면 B | v2 화면 C | v2 넓은 화면 |
|---|---|---|---|---|
| TODO: `01_v1_current.png` | TODO: `02_v2_a.png` | TODO: `03_v2_b.png` | TODO: `04_v2_c.png` | TODO: `05_v2_wide.png` |
| TODO: 현행 앱 직접 캡처·출처 확인 | TODO: 여행 목록·탐색 버튼 캡처 | TODO: 여행 상세·계획/기록 캡처 | TODO: 회고·지도/카드 캡처 | TODO: 실제 넓은 창 레이아웃 캡처 |

### 설명
1. **이 앱이 하는 일:** 여행 목록과 상세, 일정 계획, 독립 사진이 있는 여행 기록, 방문 도시 지도, 목적지 탐색과 추억 카드 미리보기를 제공하는 Flutter UI 프로토타입입니다.
2. **v2가 해결하려는 문제:** 여행 전 계획과 여행 중 기록, 여행 후 회고를 연결해 정보를 찾기 쉽게 구성합니다. 실제 사용자 리뷰·저니 근거는 **TODO: 조사 후 출처와 분석을 보완**해야 하며, 현재 설명은 설계 의도입니다.
3. **v2의 핵심 가치:** 날짜에 맞는 작업만 안내하고 사진·시간 카드·지도 개요로 여정을 알아보기 쉽게 보여 줍니다. 변경은 메모리에만 유지되며 로그인·GPS 추적·서버 쓰기·영구 저장·실제 AI 추천은 제공하지 않습니다.

### 새로운 기능
v2에서 바뀐 것 3개 — [원칙 카드](docs/원칙카드.md)의 P번호 및 [디자인 가이드](docs/디자인가이드.md)의 요소와 연결합니다.

| P번호 | 바뀐 것 (화면 · 요소 번호) | 근거 (리뷰 · 원칙) |
|---|---|---|
| P01 | B-12/B-16: 날짜별 계획 카드, 완료 체크와 완료 수/전체 진행률 | 시스템 상태를 눈에 보이게 표시한다. 실제 리뷰 근거는 TODO. |
| P03 | B-14/B-15/B-17: 기록별 사진 1장과 본문 편집·취소, 확인 후 삭제 | 사용자 통제와 자유. 기존 데이터는 취소 시 보존한다. 실제 리뷰 근거는 TODO. |
| P06 | C-6/C-7/C-8/C-10: 선택 도시 여행 개요 및 3종 추억 카드 템플릿 | 사진·지도·템플릿 미리보기로 기억보다 재인을 돕는다. 실제 리뷰 근거는 TODO. |

### 평가 및 리뷰

| 항목 | 내용 |
|---|---|
| 현행 별점 | TODO: 실제 App Store / Google Play 별점 확인 후 입력 |
| 리뷰 수 | TODO: 실제 리뷰 수 확인 후 입력 |
| 대표 리뷰 | TODO: 실제 원문·별점·작성 날짜를 확인해 인용하고 작성자 이름 제거 |
| 출처 | TODO: 실제 스토어 링크와 확인 날짜 입력 |

---

## 작성자 · 제출 정보

| 칸 | 내용 |
|---|---|
| 현행 앱 | Polarsteps — TODO: 실제 스토어 링크 및 비교 대상 버전 확인 |
| v2 한 문장 | 여행 계획·사진 일기·지도 개요·추억 카드를 연결한 메모리 기반 UI 프로토타입 |
| 작성자 | TODO: 이름 또는 이니셜 · 1인 1팀, 각자 제출 |
| 데모 | TODO: 실제 1분 데모 영상 링크 또는 배포 URL — 제출물 ① 필수. 예정 파일: `docs/영상/demo_1min.mp4` |
| AI 사용 | 규칙 [AGENTS.md](AGENTS.md) · 기록 [prompt-log](docs/prompt-log.md) · [셀프 논증](docs/셀프논증.md) · TODO: 실제 사용 내역과 `v1-plan` 원격 태그 확인 |

> 원본 과제는 UI 전용 구현을 요구합니다. 현재 버전은 사용자 요청에 따라 setState/콜백 기반 메모리 변경, 검색·정렬·날짜 검증·집계·사진 처리·PNG 내보내기를 실제 구현했습니다. 서버 쓰기·여행 데이터 영구 저장은 없지만, 실제 상태/로직 및 다운로드에 대한 **과제 감점 위험**은 남습니다. [디자인 가이드 11절](docs/디자인가이드.md)을 참고하며 완전한 과제 규칙 충족을 주장하지 않습니다.

---

## 0. 처음 받았을 때: 폴더 이름 · 앱 이름 바꾸기

1. 현재 저장소 이름은 `midterm-project1`이고 Dart 패키지는 `mid_project_template`입니다. 이 문서 정리에서는 저장소·앱 설정을 변경하지 않습니다.
2. 교수 템플릿은 전체 경로를 영문·숫자·하이픈으로 둘 것을 권장합니다. 원본에는 한글 경로에서 Flutter analyze 오류가 보고되어 있습니다. 환경별 재현 여부는 별도 확인합니다.
3. Flutter `lib/main.dart`의 표시 제목은 `Polarsteps v2`입니다. Android `android:label`, iOS `CFBundleDisplayName`, 웹 `<title>`/manifest는 아직 `Mid Project Template` 계열입니다. **TODO: 제출 전 플랫폼 표시 이름 확인**. 이름을 바꿀 경우 각 플랫폼 파일을 별도 작업으로 수정합니다.
4. 패키지 이름은 그대로 두는 것을 권장합니다. 변경 시 `pubspec.yaml`과 모든 `package:mid_project_template/…` import를 함께 맞춰야 합니다.

## 1. 실행 방법 — 터미널 2개

준비물: Flutter stable 및 Dart SDK `^3.10.0`을 만족하는 버전, Node.js 18 이상, npm, Chrome. Flutter SDK는 직접 설치하고 PATH에 추가해야 하며 특정 `/workspace` 경로를 전제로 하지 않습니다.

**터미널 1 — 목업 서버(json-server)**

```bash
cd mock_server
npm ci
npm start
# npm run mock도 같은 서버 실행
```

다른 터미널에서 `curl http://localhost:3000/items`로 JSON 배열 응답을 확인합니다. `npm install`도 가능하지만 저장소의 `package-lock.json`을 재현하려면 `npm ci`를 사용합니다. 서버는 `server.js`에서 `api/server.js`의 읽기 전용 메모리 라우터를 실행합니다.

**터미널 2 — 앱**

프로젝트 루트(`pubspec.yaml`이 있는 곳)에서 실행합니다.

```bash
flutter pub get --enforce-lockfile
flutter run -d chrome
# 다른 설치된 실행 대상: flutter devices 확인 후 flutter run
```

| 실행 대상 | 앱이 부르는 주소 | 따로 할 일 |
|---|---|---|
| Chrome · macOS · Windows · iOS 시뮬레이터 | `http://localhost:3000` | 서버 실행, 해당 플랫폼 Flutter 도구 준비 |
| Android 에뮬레이터 | `http://10.0.2.2:3000` | `lib/api.dart`가 자동 선택 |
| 실기기(같은 Wi-Fi) | PC의 실제 LAN IP | `flutter run --dart-define=API_BASE=http://192.168.0.10:3000`의 IP를 실제 주소로 변경; 방화벽/HTTP 접근 확인 |
| Vercel 서버 예시 | 배포한 API 주소 | `--dart-define=API_BASE=https://<프로젝트>.vercel.app/api`; 실제 배포 URL은 TODO. [서버 문서](mock_server/README.md)와 `vercel.json` 확인 |

앱은 GET `/items`, `/notes?itemId=`만 호출하며 서버 쓰기 요청은 거절됩니다. 서버 중단 시 오류 안내와 다시 시도를 제공합니다. 기존 목적지 고정 사진은 네트워크 연결이 필요하며 실패 시 대체 표시합니다. 지도/도시 검색은 번들 자원을 사용합니다. 사진 선택·PNG 다운로드는 Web에서 지원하고 네이티브에서는 안내/미리보기 범위를 따릅니다.

### 상태 화면 시연 — `DEMO_STATE` (발표·영상용)

```bash
flutter run -d chrome --dart-define=DEMO_STATE=loading
flutter run -d chrome --dart-define=DEMO_STATE=error
flutter run -d chrome --dart-define=DEMO_STATE=empty
```

`loading`/`slow`는 3초 지연 후 GET을 수행하므로 이후 정상 목록 표시에는 서버가 필요합니다. `error`/`empty`는 A 목록의 오류/빈 상태를 시연합니다. B 기록의 3상태는 별도 GET 응답에 따릅니다. `API_BASE`와 함께 사용할 수 있습니다.

## 2. 구조

```text
midterm-project1/
├── README.md / AGENTS.md / pubspec.yaml / pubspec.lock
├── lib/
│   ├── main.dart / api.dart / models.dart / widgets.dart
│   ├── destinations.dart / trip_insights.dart / trip_editor.dart
│   ├── trip_plans.dart / travel_plans_section.dart
│   ├── trip_photos.dart / photo_picker*.dart
│   ├── travel_notes.dart
│   ├── visited_places_map.dart / travel_memory_card.dart / png_download*.dart
│   └── screens/
│       ├── a_list_screen.dart
│       ├── b_detail_screen.dart
│       ├── c_result_sheet.dart
│       └── e_recommendations_dialog.dart
├── assets/
│   ├── data/destinations.json
│   └── images/                 # 로컬 지도 및 이미지 출처 README
├── test/                       # 위젯·날짜 권한·사진·검색·지도·PNG 등 회귀 테스트
├── mock_server/
│   ├── db.json / server.js / package.json / package-lock.json
│   ├── api/server.js / vercel.json
│   ├── test/persistence.test.js # 이름은 유지; 실제로는 GET/쓰기 거절 검증
│   └── README.md
├── docs/
│   ├── 디자인가이드.md / 원칙카드.md / prompt-log.md
│   ├── 셀프논증.md / 자가평가.md
│   └── screenshots/ · 영상/   # 제출용 캡처/영상은 TODO
└── android/ · ios/ · macos/ · windows/ · linux/ · web/
```

## 3. 화면 목록 ↔ 기획 문서 요소 번호

| 화면 | 이름 (TODO: 비즈니스 명칭) | 파일 | 전환 | 요소 번호 |
|---|---|---|---|---|
| A | 나의 여행 목록 | `lib/screens/a_list_screen.dart` | 첫 화면 | A-1 ~ A-13 |
| B | 여행 상세 | `lib/screens/b_detail_screen.dart` 및 공통 컴포넌트 | 쌓기(push) · 옆으로(tab) | B-1 ~ B-17 |
| C | 여행 추억 카드 | `lib/screens/c_result_sheet.dart` 및 공통 컴포넌트 | 덮기(BottomSheet/Dialog) | C-1 ~ C-10 |
| E | 여행지 추천 | `lib/screens/e_recommendations_dialog.dart` | A에서 Dialog | E-1 ~ E-4 |

B 계획/기록 편집과 추억 카드 템플릿은 기존 화면 안의 컴포넌트/모달이며 독립 페이지가 아닙니다. 삭제된 D 여행 선택 Dialog는 현재 구조에 없습니다.

각 화면과 공통 컴포넌트의 상단 대응표 및 `// A-5 P09` 같은 주석을 [디자인 가이드](docs/디자인가이드.md)와 맞춥니다. `// STATE:`는 현재 실제 메모리 상태 변경 지점의 설명이며, 상태가 미구현이라는 의미가 아닙니다. 확인: `rg -n 'STATE:' lib`.

## 4. 원칙 번호 추적 P01–P10 [권장]

P번호는 닐슨 원칙 번호입니다. 동일 번호를 다음 자료에 연결합니다.

| 어디 | 쓰는 법 |
|---|---|
| 디자인 가이드 | [디자인가이드.md](docs/디자인가이드.md)의 원칙 표·요소 분석 |
| 코드 주석 | 원칙을 보여 주는 요소: `// A-5 P09` |
| 커밋 메시지 | `p09: …` 형식 |
| 영상 | TODO: 실제 `docs/영상/p09.mp4` 등 원칙별 클립 제작 |
| 발표 | TODO: 원칙 카드와 실제 시연·발표자료 연결 |

확인: `rg -n 'P09' lib` · `git log --oneline --grep='p09'`. 원칙별 설계 판단은 [원칙카드.md](docs/원칙카드.md), 실제 사용 근거는 [prompt-log.md](docs/prompt-log.md)에 기록합니다.

## 5. 기준점 Git 태그 `v1-plan` [권장]

기획 확정 시 한 번 붙이는 태그입니다. 현재 로컬 확인에서는 태그가 없으며, 원격의 존재·기획 확정 시점은 **TODO: 확인**합니다. 이미 있는 태그를 덮어쓰거나 현재 시점을 과거 기획 시점으로 표시하지 않습니다.

```bash
git tag -l v1-plan
# 기획 확정 시점이 확인되고 태그가 없을 때만 실행
# git tag -a v1-plan <확정한-커밋> -m "화면 기획 확정"
# git push origin v1-plan
# git log v1-plan..HEAD --oneline
# git diff v1-plan..HEAD --stat
```

기획 변경의 쟁점과 전/후 근거는 [셀프논증.md](docs/셀프논증.md)에 기록합니다.

## 6. 영상 파일 이름

- `docs/영상/demo_1min.mp4`: 전체 흐름 1분. **TODO: 실제 영상 제작·확인 후 위 데모 칸에 링크**. 배포 URL로 대신할 경우 실제 실행 확인이 필요합니다.
- `docs/영상/p01.mp4`, `p09.mp4` 등: 원칙별 5–10초 클립 권장. 현재 확인된 영상은 없습니다.
- 시연 예: A 검색/상태 → B 계획·사진 기록 → C 지도 도시 개요·템플릿 → GET 목록 및 넓은 창 레이아웃.
- 녹화 전 개인정보·알림을 확인합니다. 100MB 초과 파일은 GitHub에 직접 올리지 않고 실제 제출 가능한 링크를 사용합니다.

## 7. 감점 점검 (제출 전, 결과가 비어 있어야 함)

```bash
grep -rnE "http\.(post|put|patch|delete)|SharedPreferences|sqflite|hive|FirebaseAuth|ChangeNotifierProvider|Riverpod|BlocProvider" lib/ pubspec.yaml
```

이 검사는 과제의 금지 API/패키지 문자열 검사입니다. 빈 결과만으로 과제 전체 준수를 보장하지 않습니다. 화면을 눌러 실제 전송·자동 저장이 없는지 확인하고 [자가평가.md](docs/자가평가.md) 및 디자인 가이드의 상태/로직 위험도 함께 검토합니다. 실제 검색·집계·메모리 상태와 명시적 PNG 다운로드를 없는 기능처럼 설명하지 않습니다.

## 8. 제출 전 clone 테스트 [필수 확인]

1. `git clone https://github.com/jingfancai/midterm-project1.git clone-test`
2. 터미널 1: `cd clone-test/mock_server`, `npm ci`, `npm start`.
3. 별도 터미널: `curl http://localhost:3000/items`로 GET JSON 확인.
4. 터미널 2: `cd clone-test`, `flutter pub get --enforce-lockfile`, `flutter run -d chrome`.
5. A→B→C/모달, 여행 날짜별 권한, 계획 진행률, 독립 기록 사진, 지도 도시 개요, 추천 검색·폼 미리 입력, 템플릿 PNG를 확인합니다.
6. `DEMO_STATE`와 서버 중단/재시도로 3상태를 확인하고 창 폭 600dp 전후 및 작은 창에서 레이아웃을 확인합니다.
7. 새로고침/상세 재진입으로 세션 수명이 설명과 일치하는지 확인합니다. 실패하면 원인을 수정한 뒤 새 clone으로 재검증합니다.

```bash
flutter analyze
flutter test
node --test mock_server/test/persistence.test.js
flutter build web
```

`db.json`·assets·lockfile 포함 여부와 설치 의존성을 확인하며 `node_modules/`와 개인 로컬 경로에 의존하지 않습니다. 테스트가 추가된 것과 실제 통과한 것은 구분합니다.

## 9. 제출물 2종 체크 (LMS, 10/29(목) 15:00 전 — 9주차 수업 시작 전, 각자 제출)

위 제목과 일정은 **교수 원본 템플릿 안내를 보존한 것**입니다. 현재 유효한 제출 기한/발표 일정은 **TODO: LMS에서 재확인**합니다. 제출 또는 기한 연장을 완료했다고 주장하지 않습니다.

- [ ] ① **데모 시연 + 코드** — 실제 GitHub 저장소 URL 및 clone 테스트 결과 확인
  - [ ] Flutter 코드와 `mock_server/db.json`
  - [ ] README 앱 소개 8칸·실행 방법·실제 1분 데모 영상 또는 배포 URL
  - [ ] 디자인 가이드·원칙 카드·prompt-log·셀프 논증·자가평가
- [ ] ② **발표자료** — `mid-project-presentation-template` 기반 PPTX/PDF, 6분 발표 + 2분 질의
  - [ ] 본문 7장 및 부록 B1 데모/스크린샷 · B2 원칙 카드 · B3 prompt-log · B4 자가평가 · B5 기획 상세
  - [ ] B5 사업 요약·저니·피쉬본/5 Why·화면별 요소 분석·상태관리 포인트를 실제 근거로 보완

기획 1–5단계는 발표자료 본문/부록 B5에 담습니다. 기획 양식 PPTX는 교수 템플릿에서 선택 참고 자료로 안내합니다. 현재 발표자료/리뷰 증거는 TODO입니다.

## 10. 확인된 상태 (템플릿 배포 시점)

교수 원본 README에는 배포 시점 `flutter analyze` 0 issues와 템플릿 테스트 4개 통과가 기재되어 있습니다. **이는 현재 Polarsteps v2의 검증 결과가 아닙니다.** 현재 저장소는 기능별 회귀 테스트가 추가되어 있습니다.

이 문서 정리 시점의 실행 환경에는 Flutter SDK가 없어 현재 전체 analyze/test/build 통과를 확인하지 못했습니다. 이전 서버 테스트도 환경의 로컬 포트 리슨 제한으로 `EPERM`이 보고되었습니다. **TODO: 실행 가능한 환경에서 8절 명령을 수행하고 버전·날짜·실제 결과 기록**. README만 변경하는 이번 작업에서는 앱 테스트를 통과했다고 표시하지 않습니다.

현재 의존성은 Flutter SDK, `cupertino_icons`, `http`와 개발용 `flutter_test`, `flutter_lints`입니다. 사진 선택·PNG 다운로드는 기존 Web 구현 범위이며 네이티브 플러그인은 추가하지 않았습니다.

## 11. 보충: 현재 기능과 메모리 범위

| 기능 | 현재 동작과 제한 |
|---|---|
| A 여행 목록 | 검색·즐겨찾기·그룹 내 정렬·여행 추가/편집·삭제 확인/취소. 600dp 기준 목록/격자. 기록 모아보기·여행지 추천은 같은 스타일로 나란히 배치. |
| B 여행 사진 | 시작한 여행만 로컬 사진 최대 5장 관리, 상단 대형 사진·썸네일 전환/스와이프. 미래/날짜 오류 여행은 기본 사진. |
| B 여행 계획 | 미래: 여행 전체 기간. 진행 중: 시스템 로컬 오늘~종료일 DatePicker. AM/PM TimePicker·시간순 카드. 지난 계획의 내용 편집/삭제는 금지하되 진행 중에는 완료 체크 가능. 미래/진행 여행의 완료 수/전체와 진행률 표시. 종료 여행은 계획 영역 숨김. |
| B 여행 기록 | 진행/종료 여행만 추가·편집·확인 삭제. 기록별 독립 사진 최대 1장, 본문·날짜·AM/PM 시간. 상단 사진과 분리하며 시간 없는 옛 기록은 시간 미기록 표시. 취소 시 사진 교체/삭제도 취소. |
| C 방문 지도 | 번들 세계 지도·도시 좌표, 1~8배 확대/드래그. 시작한 유효 여행만 도시별 집계. 클릭한 한 도시의 여행 개요만 표시하고 상세로 이동하지 않음. C 전체 여행 목록의 상세 이동은 유지. |
| E 목적지 탐색 | 기존 JSON 50도시의 중/한/영 도시·국가·테마·키워드 검색과 테마 필터, 고정 사진, 새 여행 폼 미리 입력. 외부 추천 API/AI 없음. |
| 추억 카드 | 종료 여행만 심플/엽서/사진 콜라주 선택·미리보기·Web PNG 내보내기. 기존 여행 사진·제목·날짜·Tag·후기를 재사용. |

사진은 기존 Web 선택기로 읽고 장당 10MB/60MP 이하 입력을 긴 축 1920px 이하 정적 PNG로 변환합니다. 서버 업로드·브라우저 저장소·자동 파일 저장은 없습니다. 목적지 기본 사진은 기존 고정 외부 이미지 URL이며 로컬 지도/검색과 구분합니다. 사진 출처는 [assets/images/README.md](assets/images/README.md)를 참고합니다.

여행·즐겨찾기·계획·여행 사진은 A/B/C가 공유하는 세션 메모리이며 GET 새로고침/재시작 시 초기화됩니다. **여행 기록과 독립 기록 사진은 현재 상세 화면 범위**여서 상세를 닫고 다시 들어가면 GET 원본으로 복구됩니다. 사용자가 직접 요청하는 PNG 다운로드는 여행 데이터 영구 저장과 별개입니다.
