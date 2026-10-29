# 로컬 세계 지도

`world_map.png`는 C의 방문 장소 지도용 정적 배경이다. 앱은 이 PNG를 asset으로만 읽고
지도 API/타일 서버를 호출하지 않는다. 여행 사진 자원과는 별개다.

- 육지 윤곽: Natural Earth, **1:110m Physical Vectors – Land**, 공개 도메인.
- 데이터: https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_110m_land.geojson
- 공식 자료: https://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-land/
- 이용 조건: https://www.naturalearthdata.com/about/terms-of-use/ (public domain)
- 원본 확인일: 2026-10-30
- 다운로드 원본 SHA-256: `9e0729ee253ca7d7a5c4ae9395fb1902264c5377c52e224d13dd85010e2835d9`

GeoJSON의 육지 Polygon/MultiPolygon을 기존 테마의 녹색으로 래스터화했다. 국경은 표시하지 않는다.
1440×720 PNG의 왼쪽/오른쪽은 경도 -180/+180, 위/아래는 위도 +90/-90이다.
위치 = `x=(longitude+180)/360*width`, `y=(90-latitude)/180*height`.
지도에 추가 패딩·크롭이 없으며 위도/경도 30도 간격의 배경선을 포함한다.

`destinations.json` 좌표는 50개 관광 도시의 근사 도심 예시이며 개인 위치/여행 동선 데이터가 아니다.
정확한 내비게이션이나 경계 판단 용도로 쓰지 않는다. 바탕 지도 및 Marker 모두 로컬 자원이다.
