# 목적지 사진 출처와 확인 기록

도시 50개 모두 서로 다른 전용 고정 사진을 사용합니다. 별도 지역인 제주도에도 전용 등대 사진을 지정했습니다.
강원도 및 미인식 목적지는 특정 도시를 나타내지 않는 비행기·구름 기본 사진을 사용합니다.

2026-10-29에 도시 50개 + 제주도 + 기본 표지 총 52개 URL을 실제 GET으로 확인했습니다. 모두 HTTP 200, 이미지 MIME, 정상 디코딩 및 `Access-Control-Allow-Origin: *`를 반환했습니다. 외부 URL의 장기 가용성까지 보장하지는 않으며 실패 시 중성 기본 표지로 한 번만 대체합니다.

새 사진은 Wikimedia Commons의 CC0/공유영역 파일을 사용합니다. 기존 Unsplash 사진 7개와 중성 기본 표지는 Unsplash License에 따라 사용합니다. 별도 지도/검색 API는 앱에서 호출하지 않습니다. 각 파일 페이지·라이선스 링크와 가능한 작성자명은 destinations.json의 photoSource에도 보관합니다.

암스테르담 중앙역과 덴파사르 박물관 사진은 역사 사진입니다. 특히 덴파사르는 1935년 자료이며 현대 풍경으로 주장하지 않습니다. 도시 외부의 유명 관광지나 다른 도시 이미지를 해당 도시 사진으로 대신하지 않았습니다.

| 목적지 | 사진·출처 | 라이선스 |
|---|---|---|
| 도쿄 (Tokyo) | [Tokyo fixed city photograph](https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=1000&q=85) | [Unsplash License](https://unsplash.com/license) |
| 오사카 (Osaka) | [Osaka fixed city photograph](https://images.unsplash.com/photo-1590559899731-a382839e5549?w=1000&q=85) | [Unsplash License](https://unsplash.com/license) |
| 교토 (Kyoto) | [Kyoto fixed city photograph](https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=1000&q=85) | [Unsplash License](https://unsplash.com/license) |
| 서울 (Seoul) | [Seoul fixed city photograph](https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=1000&q=85) | [Unsplash License](https://unsplash.com/license) |
| 부산 (Busan) | [Busan beach.jpg](https://commons.wikimedia.org/wiki/File:Busan_beach.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 파리 (Paris) | [Paris fixed city photograph](https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1000&q=85) | [Unsplash License](https://unsplash.com/license) |
| 리옹 (Lyon) | [Lyon 1er - Place Bellevue - Vue sur le quartier de La Part-Dieu et les Alpes.jpg](https://commons.wikimedia.org/wiki/File:Lyon_1er_-_Place_Bellevue_-_Vue_sur_le_quartier_de_La_Part-Dieu_et_les_Alpes.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 런던 (London) | [London fixed city photograph](https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=1000&q=85) | [Unsplash License](https://unsplash.com/license) |
| 뉴욕 (New York) | [New York fixed city photograph](https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=1000&q=85) | [Unsplash License](https://unsplash.com/license) |
| 로스앤젤레스 (Los Angeles) | [Los Angeles Skyline; August 30, 2022.jpg](https://commons.wikimedia.org/wiki/File:Los_Angeles_Skyline;_August_30,_2022.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 베이징 (Beijing) | [The Birds' Nest, Beijing, Jan 1 2023.jpg](https://commons.wikimedia.org/wiki/File:The_Birds%27_Nest,_Beijing,_Jan_1_2023.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 상하이 (Shanghai) | [Shanghai skyline waterfront pudong 5166168 69 70.jpg](https://commons.wikimedia.org/wiki/File:Shanghai_skyline_waterfront_pudong_5166168_69_70.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 싱가포르 (Singapore) | [Skyline of Singapore Central Business District 20250903.jpg](https://commons.wikimedia.org/wiki/File:Skyline_of_Singapore_Central_Business_District_20250903.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 방콕 (Bangkok) | [A Bangkok Skyline. (28200943426).jpg](https://commons.wikimedia.org/wiki/File:A_Bangkok_Skyline._(28200943426).jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 하노이 (Hanoi) | [August 2003 Hanoi 2.jpg](https://commons.wikimedia.org/wiki/File:August_2003_Hanoi_2.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 다낭 (Da Nang) | [Da Nang, Vietnam.jpg](https://commons.wikimedia.org/wiki/File:Da_Nang,_Vietnam.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 로마 (Rome) | [Er Cuppolone (179597823).jpeg](https://commons.wikimedia.org/wiki/File:Er_Cuppolone_(179597823).jpeg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 바르셀로나 (Barcelona) | [Barcelona - Skyline del Diagonal Mar i el Front Marítim del Poblenou, Hotel Barcelona Princess, CCIB, Hotel AC Barcelona Forum, Consorci de la Zona Franca ,Hotel Hilton Diagonal Mar y Torre B Diagonal Mar.jpg](https://commons.wikimedia.org/wiki/File:Barcelona_-_Skyline_del_Diagonal_Mar_i_el_Front_Mar%C3%ADtim_del_Poblenou,_Hotel_Barcelona_Princess,_CCIB,_Hotel_AC_Barcelona_Forum,_Consorci_de_la_Zona_Franca_,Hotel_Hilton_Diagonal_Mar_y_Torre_B_Diagonal_Mar.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 베를린 (Berlin) | [Berlin TV tower city skyline (41610209475).jpg](https://commons.wikimedia.org/wiki/File:Berlin_TV_tower_city_skyline_(41610209475).jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 시드니 (Sydney) | [Sydney Central Station.jpg](https://commons.wikimedia.org/wiki/File:Sydney_Central_Station.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 암스테르담 (Amsterdam) | [Amsterdam Centraal Station2.jpg](https://commons.wikimedia.org/wiki/File:Amsterdam_Centraal_Station2.jpg) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) |
| 브뤼셀 (Brussels) | [Night skyline above Rue de la Fourche, Brussels, 2013.jpg](https://commons.wikimedia.org/wiki/File:Night_skyline_above_Rue_de_la_Fourche,_Brussels,_2013.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 취리히 (Zurich) | [Zurich city center.jpg](https://commons.wikimedia.org/wiki/File:Zurich_city_center.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 빈 (Vienna) | [Vienna Austria Skyline Aerial, October 2024.jpg](https://commons.wikimedia.org/wiki/File:Vienna_Austria_Skyline_Aerial,_October_2024.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 프라하 (Prague) | [Prague skyline view.jpg](https://commons.wikimedia.org/wiki/File:Prague_skyline_view.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 부다페스트 (Budapest) | [View from Buda Castle 2014 01.jpg](https://commons.wikimedia.org/wiki/File:View_from_Buda_Castle_2014_01.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 리스본 (Lisbon) | [Lisbon W Ponte 25 De Abril (256368647).jpeg](https://commons.wikimedia.org/wiki/File:Lisbon_W_Ponte_25_De_Abril_(256368647).jpeg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 아테네 (Athens) | [From Temple of Olympian Zeus to Lycabetus Athens Greece.jpg](https://commons.wikimedia.org/wiki/File:From_Temple_of_Olympian_Zeus_to_Lycabetus_Athens_Greece.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 이스탄불 (Istanbul) | [Historical peninsula and modern skyline of Istanbul.jpg](https://commons.wikimedia.org/wiki/File:Historical_peninsula_and_modern_skyline_of_Istanbul.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 코펜하겐 (Copenhagen) | [January 2008 Copenhagen skyline.jpg](https://commons.wikimedia.org/wiki/File:January_2008_Copenhagen_skyline.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 스톡홀름 (Stockholm) | [Nationalmuseum stockholm 20050902 001.jpg](https://commons.wikimedia.org/wiki/File:Nationalmuseum_stockholm_20050902_001.jpg) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) |
| 오클랜드 (Auckland) | [Skyline - Auckland, NZ - DSC07092.jpg](https://commons.wikimedia.org/wiki/File:Skyline_-_Auckland,_NZ_-_DSC07092.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 쿠알라룸푸르 (Kuala Lumpur) | [Kuala Lumpur skyline long exposure.jpg](https://commons.wikimedia.org/wiki/File:Kuala_Lumpur_skyline_long_exposure.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 더블린 (Dublin) | [Dublin with Spire (23698542464).jpg](https://commons.wikimedia.org/wiki/File:Dublin_with_Spire_(23698542464).jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 레이캬비크 (Reykjavik) | [August 2006 in Reykjavik 27.jpg](https://commons.wikimedia.org/wiki/File:August_2006_in_Reykjavik_27.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 덴파사르 (Denpasar) | [Denpasar Museum by Sosialist Denpasar, Melantjong ka Bali (1935), np.jpg](https://commons.wikimedia.org/wiki/File:Denpasar_Museum_by_Sosialist_Denpasar,_Melantjong_ka_Bali_(1935),_np.jpg) | [Public domain](https://creativecommons.org/publicdomain/mark/1.0/) |
| 두바이 (Dubai) | [Dubai skyline unsplash.jpg](https://commons.wikimedia.org/wiki/File:Dubai_skyline_unsplash.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 카이로 (Cairo) | [Cairo Tower, al-Qāhirah, CG, EGY (40942425723).jpg](https://commons.wikimedia.org/wiki/File:Cairo_Tower,_al-Q%C4%81hirah,_CG,_EGY_(40942425723).jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 마라케시 (Marrakesh) | [Mosque El Mansour – Marrakesh - 01.jpg](https://commons.wikimedia.org/wiki/File:Mosque_El_Mansour_%E2%80%93_Marrakesh_-_01.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 케이프타운 (Cape Town) | [Cape-town-port-boats.jpg](https://commons.wikimedia.org/wiki/File:Cape-town-port-boats.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 토론토 (Toronto) | [Toronto Skyline, Ontario Canada.jpg](https://commons.wikimedia.org/wiki/File:Toronto_Skyline,_Ontario_Canada.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 멕시코시티 (Mexico City) | [Santa Fe Skyline 2017 CDMX.jpg](https://commons.wikimedia.org/wiki/File:Santa_Fe_Skyline_2017_CDMX.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 마드리드 (Madrid) | [Puerta de Alcalá, Madrid, illuminated with the rainbow colours during the celebrations of WorldPride 2017.jpg](https://commons.wikimedia.org/wiki/File:Puerta_de_Alcal%C3%A1,_Madrid,_illuminated_with_the_rainbow_colours_during_the_celebrations_of_WorldPride_2017.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 피렌체 (Florence) | [Perseus Medusa Cellini Lanzi Florence.jpg](https://commons.wikimedia.org/wiki/File:Perseus_Medusa_Cellini_Lanzi_Florence.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 베네치아 (Venice) | [Alejandro Franco 2015 (Unsplash).jpg](https://commons.wikimedia.org/wiki/File:Alejandro_Franco_2015_(Unsplash).jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 뮌헨 (Munich) | [Marianische Männerkongregation Munich.jpg](https://commons.wikimedia.org/wiki/File:Marianische_M%C3%A4nnerkongregation_Munich.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 멜버른 (Melbourne) | [City of Melbourne Skyline From Docklands.JPG](https://commons.wikimedia.org/wiki/File:City_of_Melbourne_Skyline_From_Docklands.JPG) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 샌프란시스코 (San Francisco) | [Golden Gate Bridge, San Francisco, 2017.jpg](https://commons.wikimedia.org/wiki/File:Golden_Gate_Bridge,_San_Francisco,_2017.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 밴쿠버 (Vancouver) | [Vancouver Skyline September.jpg](https://commons.wikimedia.org/wiki/File:Vancouver_Skyline_September.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 포르투 (Porto) | [Porto.png](https://commons.wikimedia.org/wiki/File:Porto.png) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 제주 (Jeju) | [Lighthouse in Jeju Island.jpg](https://commons.wikimedia.org/wiki/File:Lighthouse_in_Jeju_Island.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) |
| 기본 표지 | [Airplane wing above clouds (neutral travel cover)](https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1000&q=85) | [Unsplash License](https://unsplash.com/license) |
