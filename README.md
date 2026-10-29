# Polarsteps v2 — Flutter UI/UX Prototype

중간 제출용 여행 기록 화면 시연입니다. A 나의 여행 목록, B 여행 상세, C 여행 추억 카드와 기존 사진·테마를 유지합니다.
실제 로그인·결제·서버 쓰기·영구 저장은 구현하지 않습니다. 기존 세션 상호작용과 검색·집계는 유지합니다.
**교수 감점 위험:** 상태관리 프레임워크가 없어도 메모리 상태 변경과 실제 검색·정렬·날짜/통계·국가 인식은 감점 대상일 수 있습니다.

## 실행

```bash
cd mock_server
npm ci
npm start
```

다른 터미널에서:

```bash
export PATH=/workspace/toolchains/flutter/bin:$PATH
export PUB_CACHE=/workspace/.pub-cache
flutter pub get --enforce-lockfile
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

API는 GET /items 및 /notes?itemId=만 사용합니다. npm start는 읽기 전용 메모리 라우터를 실행합니다.
추가·수정·즐겨찾기·삭제·실행 취소는 메모리 데이터만 변경하고 A/B/C에 반영합니다.
검색·필터·정렬, 날짜 분류, 방문 도시/국가 중복 제거와 목적지 인식은 실제 동작합니다.
새로고침/재실행하면 GET 원본으로 복구됩니다. 기록 추가는 현재 상세 탭에서만 유지됩니다.

## Demo 순서

1. A에서 표지·날짜·태그와 창 너비별 목록/격자를 확인한다.
2. Tokyo 검색 → 실제 일치 항목 → 없는 검색어의 빈 상태 → 검색어 지우기. 정렬·즐겨찾기 필터의 결과를 확인한다.
3. 즐겨찾기·추가·삭제 확인·실행 취소: 선택 아이콘·새 카드·삭제·복원을 확인하고 새로고침 후 원본으로 돌아오는지 확인한다.
4. 카드 선택 → B 표지·제목·날짜·장소 → 정보 수정 입력/취소/완료 후 A/B의 제목·목적지·날짜·사진 동기화를 확인한다.
5. B 여행 기록 탭 → GET 목록 또는 빈 상태 → 임시 기록 추가 후 상세 재진입 시 사라지는지 확인한다.
6. A 기록 모아보기 → C의 현재 통계·회고 사진 → 카드 선택/닫기.
7. 서버 중단/GET 빈 배열/지연으로 Error·Empty·Loading을 확인하고 다시 시도한다.

## 검증과 제출 범위

```bash
flutter analyze
flutter test
node --test mock_server/test/persistence.test.js
flutter build web
```

기존 테스트 파일은 유지하되 서버 쓰기·영구 저장·실제 계산을 요구하던 단언을 GET-only/세션 변경·재조회 초기화 계약으로 변경했습니다.
디자인 기준은 docs/디자인가이드.md, P01–P10은 docs/원칙카드.md를 참고하세요. 업무 상태 변화는 // STATE:에 표시합니다. 기능 보존에 따른 감점 위험은 가이드 11절에 명시합니다.
실제 PPT/PDF·앱 리뷰·발표 영상은 저장소에 제공되지 않아 최종 일치 여부와 점수를 보증하지 않습니다.
