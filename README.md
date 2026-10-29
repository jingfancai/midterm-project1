# Polarsteps v2 — Flutter UI/UX Prototype

중간 제출용 여행 기록 화면 시연입니다. A 나의 여행 목록, B 여행 상세, C 여행 추억 카드와 기존 사진·테마를 유지합니다.
실제 로그인·결제·저장·국가 추론·추천·통계 계산은 구현하지 않습니다.

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
추가·수정·즐겨찾기·삭제·실행 취소·기록 추가는 Dialog/SnackBar 시연이며 GET 데이터를 변경하지 않습니다.
검색/필터는 고정된 첫 항목 예시, 정렬은 선택 표시만 제공합니다. 통계는 예시 상수이고 분류는 샘플 demoStatus 표시입니다.

## Demo 순서

1. A에서 표지·날짜·태그와 창 너비별 목록/격자를 확인한다.
2. 검색어 입력 → 첫 예시 결과 → 검색어 지우기로 원래 목록 복귀. 정렬·필터는 예시 안내와 함께 시연한다.
3. 즐겨찾기·추가·삭제 확인·실행 취소: 저장되지 않는다는 안내와 원본 카드가 남는지 확인한다.
4. 카드 선택 → B 표지·제목·날짜·장소 → 정보 수정 입력/취소/완료 안내.
5. B 여행 기록 탭 → GET 목록 또는 빈 상태 → 기록 추가는 안내만 보여 준다.
6. A 기록 모아보기 → C의 예시 통계·회고 사진 → 카드 선택/닫기.
7. 서버 중단/GET 빈 배열/지연으로 Error·Empty·Loading을 확인하고 다시 시도한다.

## 검증과 제출 범위

```bash
flutter analyze
flutter test
node --test mock_server/test/persistence.test.js
flutter build web
```

기존 테스트 파일은 유지하되 서버 쓰기·영구 저장·실제 계산을 요구하던 단언을 GET-only/원본 불변의 원형 계약으로 변경했습니다.
디자인 기준은 docs/디자인가이드.md, P01–P10은 docs/원칙카드.md를 참고하세요. 업무 상태 계획은 // STATE:에 표시합니다.
실제 PPT/PDF·앱 리뷰·발표 영상은 저장소에 제공되지 않아 최종 일치 여부와 점수를 보증하지 않습니다.
