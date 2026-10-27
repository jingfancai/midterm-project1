<<<<<<< HEAD
# Polarsteps v2 — 여행 기록 UI 프로토타입

## 앱 소개
- 앱 이름: Polarsteps v2
- 부제: 여행 경로와 사진, 기록을 한곳에서 돌아보는 여행 일기
- 카테고리: 여행
- 대상 사용자: 여행 중 사진과 장소를 기록하고, 여행 후 추억을 정리하고 싶은 대학생 및 여행자
- 개선 방향: 여행 기록을 카드와 시간선으로 더 쉽게 탐색하고, 여행 회고 진입점을 명확하게 제공한다.
- AI 기능 제안: 여행 사진과 메모를 바탕으로 회고 문장을 제안한다. 현재 화면의 결과는 고정된 시연용 데이터이며 실제 AI 호출은 없다.

## 화면 목록
1. A — 나의 여행: 여행 카드 목록, 로딩/오류/빈 상태, 600dp 이상 넓은 화면 격자
2. B — 여행 상세: 여행 정보와 여행 기록 탭
3. C — 여행 추억 카드: 미리 정한 회고 제안 결과를 보여 주는 모달

## 실행 방법
### 1. JSON Server 실행
```bash
cd mock_server
npm install
npm start
```
서버 기본 주소는 `http://localhost:3000`입니다.

### 2. Flutter 실행
프로젝트 루트에서 별도 터미널을 열고 실행합니다.
```bash
flutter pub get
flutter run -d chrome
```
Flutter 웹에서 `localhost:3000`의 JSON Server를 사용합니다. Android 에뮬레이터에서는 템플릿의 `10.0.2.2:3000` 설정을 사용합니다.

## 데모 영상 또는 배포 URL
- 1분 데모 영상: TODO — https://drive.google.com/file/d/1GcZCoI2VISxBMF445PMPQqvMuczyzweF/view?usp=sharing
- 배포 URL: TODO — https://drive.google.com/file/d/1GcZCoI2VISxBMF445PMPQqvMuczyzweF/view?usp=sharing

## 데이터와 제한
- `mock_server/db.json`의 여행과 기록은 프로젝트용 모의 데이터입니다.
- 앱은 JSON Server에서 GET 요청만 사용합니다.
- 로그인, 결제, 영구 저장, 실제 GPS 추적 및 실제 AI API는 구현하지 않습니다.

## 문서
`docs/` 폴더에는 디자인 가이드, 원칙 카드, AI prompt-log, 셀프 논증 기록, 자가평가가 있습니다. 제출 전 각 문서를 실제 리뷰 근거와 본인의 결정으로 업데이트해야 합니다.
=======
# midterm-project
>>>>>>> 53b2b4dad4cd56e25429e5758e6788990237e47b
