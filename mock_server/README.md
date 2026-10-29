# Polarsteps v2 — GET 전용 UI Prototype 서버

```bash
cd mock_server
npm ci
npm start
```

server.js는 기존 api/server.js의 readOnly 메모리 라우터를 실행한다. 파일은 읽기만 하며, 앱은
GET /items와 GET /notes?itemId=만 호출한다. 서버의 모든 쓰기 요청은 403이다.
`node --test test/persistence.test.js`는 이름을 보존한 읽기 전용 회귀 테스트다. 쓰기 금지 확인을 위한
부정 요청만 보내며 실제 앱 코드에 쓰기 함수는 없다. 테스트는 DB 파일이 바뀌지 않았는지도 확인한다.

추가·편집·즐겨찾기·삭제·기록 추가는 Flutter 메모리만 변경하며 서버 데이터는 바뀌지 않는다.
검색·정렬·통계·날짜 분류·국가 인식은 실제 동작한다. 새로고침/재실행 시 세션 변경이 사라진다.
이 메모리 상태와 실제 로직은 교수 규칙상 감점 위험이 남는다.
아이콘·표지 사진은 기존 자원을 유지한다. Vercel 예시도 같은 GET 전용 서버다.
로그인·결제·개인정보·유료 API는 사용하지 않는다. 발표할 때 실제 서비스로 설명하지 않는다.
