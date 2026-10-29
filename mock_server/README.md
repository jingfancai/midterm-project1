# Polarsteps v2 — 영구 저장 개발 서버

현재 여행 관리 기능은 json-server 0.17.4의 **파일 기반 REST API**를 사용합니다.
이 기능은 사용자의 명시적 요청에 따라 기존 GET 전용 UI 템플릿을 확장한 것입니다.

## 실행과 검증

```bash
cd /workspace/midterm-project1/mock_server
npm ci
npm start
```

`--read-only`를 붙이면 저장이 403으로 실패합니다. 이전 읽기 전용 서버가 실행 중이면 먼저 종료하세요.
서버는 `db.json`에 저장하므로 브라우저 새로고침이나 프로세스 재시작 후에도 데이터가 유지됩니다.
클라우드 호스트가 교체될 때까지 보장하려면 `db.json`이 있는 디렉터리를 영구 볼륨에 보관해야 합니다.
이 서버는 인증 없는 로컬 개발용입니다. 공개 인터넷에 쓰기 API를 그대로 노출하지 마세요.

```bash
node --test test/persistence.test.js
```

테스트는 임시 DB로 POST/PATCH, 서버 재시작, 삭제와 복원 후 재시작을 검사합니다. 실제 `db.json`은 수정하지 않습니다.

## 데이터 구조와 API

| 필드 | 의미 |
|---|---|
| `id` | 서버가 발급한 숫자 ID |
| `title`, `image`, `tags` | 기존 카드 정보 |
| `destination` | 사용자가 편집하는 목적지 |
| `countryCode` | ISO 3166-1 alpha-2 코드, 예: KR / JP |
| `startDate`, `endDate` | YYYY-MM-DD, 시작일 ≤ 종료일 |
| `favorite` | 영구 저장되는 즐겨찾기 여부 |
| `deleted` | 영구 저장되는 소프트 삭제 여부 |
| `subtitle` | 호환용 날짜·목적지 표시. 새 앱은 구조화 필드에서 표시를 생성 |

| 메서드·경로 | 동작 |
|---|---|
| `GET /items?deleted_ne=true` | 삭제되지 않은 여행 조회 |
| `POST /items` | 서버 ID로 여행 생성 |
| `PATCH /items/:id` | 제목·목적지·국가·날짜·즐겨찾기 수정 |
| `PATCH /items/:id` + `deleted: true` | 새로고침 후에도 숨겨지는 삭제 |
| `PATCH /items/:id` + `deleted: false` | 동일 ID와 연관 기록을 유지하는 실행 취소 |
| `GET /notes?itemId=:id` | 기존 여행 기록 조회 |

물리적 DELETE는 실행 취소와 연관 기록 보존을 위해 사용하지 않습니다. 삭제된 여행은 목록·회고·통계에서 제외됩니다.
신규·수정 작업은 성공 응답을 받은 뒤에만 화면에 반영되며, 실패 시 원래 데이터를 유지합니다.
기존 여행 기록(notes)의 추가 UI는 이번 여행 데이터 영구 저장 범위에 포함하지 않았습니다.

## Flutter 연결

```bash
export PATH=/workspace/toolchains/flutter/bin:$PATH
export PUB_CACHE=/workspace/.pub-cache
cd /workspace/midterm-project1
flutter pub get --enforce-lockfile
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

웹 기본 API는 `http://localhost:3000`, Android 에뮬레이터는 `http://10.0.2.2:3000`입니다.
다른 호스트의 쓰기 가능한 서버는 `--dart-define=API_BASE=https://your-api.example`로 지정하세요.
json-server는 기본 CORS와 PATCH/POST 사전 요청을 지원합니다. 별도 인증·클라우드 배포는 수행하지 않았습니다.

## 통계

국가 수는 태그나 도시명을 세지 않고 국가 코드의 중복을 제거해 계산합니다.
시작일이 오늘 이하인 진행/완료 여행만 방문으로 포함하며, 미래 여행·날짜 미정·국가 미지정은 제외합니다.
검색 필터와 무관하게 삭제되지 않은 전체 여행을 기준으로 갱신합니다.
여행일 합계는 계획된 미래 여행도 포함하는 여행별 기간 합계이며, 겹치는 날짜는 여행별로 합산합니다.

## 기존 Vercel 예시의 제한

`api/server.js`는 여전히 **GET 전용 메모리 라우터**입니다. 서버리스 파일시스템은 이 데이터베이스의 영구 저장소가 아닙니다.
Vercel 예시를 쓰기 가능하게 바꾸는 것으로 해결하지 않았습니다. 실제 영구 저장 배포에는 지속 실행되는 쓰기 서버와 영구 디스크 또는 별도 데이터베이스가 필요합니다.
