/// Fixed city aliases and photos. No geocoding, substring guessing or random URLs.
const defaultTripPhoto =
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=1000&q=85';

class DestinationInfo {
  const DestinationInfo(
    this.countryCode,
    this.countryName,
    this.aliases, {
    this.photoUrl = defaultTripPhoto,
  });

  final String countryCode;
  final String countryName;
  final List<String> aliases;
  final String photoUrl;
}

const _destinations = [
  DestinationInfo(
    'JP',
    '일본',
    [
      'Tokyo',
      '도쿄',
      '东京',
      '東京',
      '东京都',
      '東京都',
      '일본 도쿄',
      '日本东京',
      '日本 東京',
      'Tokyo, Japan',
      'Japan Tokyo',
    ],
    photoUrl:
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=1000&q=85',
  ),
  DestinationInfo(
    'JP',
    '일본',
    ['Osaka', '오사카', '大阪', '일본 오사카', '日本大阪', 'Osaka, Japan'],
    photoUrl:
        'https://images.unsplash.com/photo-1590559899731-a382839e5549?w=1000&q=85',
  ),
  DestinationInfo(
    'JP',
    '일본',
    ['Kyoto', '교토', '京都', '일본 교토', '日本京都', 'Kyoto, Japan'],
    photoUrl:
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=1000&q=85',
  ),
  DestinationInfo(
    'KR',
    '대한민국',
    [
      'Seoul',
      '서울',
      '서울특별시',
      '首尔',
      '首爾',
      '대한민국 서울',
      '한국 서울',
      '韩国首尔',
      'Seoul, South Korea',
    ],
    photoUrl:
        'https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=1000&q=85',
  ),
  DestinationInfo('KR', '대한민국', [
    'Busan',
    '부산',
    '부산광역시',
    '釜山',
    '한국 부산',
    'Busan, South Korea',
  ]),
  DestinationInfo('KR', '대한민국', [
    'Jeju',
    'Jeju Island',
    '제주',
    '제주도',
    '제주특별자치도',
    '济州',
    '济州岛',
    '濟州島',
  ]),
  DestinationInfo('KR', '대한민국', [
    'Gangwon',
    'Gangwon-do',
    '강원도',
    '강원특별자치도',
    '江原道',
  ]),
  DestinationInfo(
    'FR',
    '프랑스',
    ['Paris', '파리', '巴黎', '프랑스 파리', '法国巴黎', '法國巴黎', 'Paris, France'],
    photoUrl:
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1000&q=85',
  ),
  DestinationInfo('FR', '프랑스', ['Lyon', '리옹', '里昂']),
  DestinationInfo(
    'GB',
    '영국',
    ['London', '런던', '伦敦', '倫敦', '영국 런던', '英国伦敦', 'London, UK'],
    photoUrl:
        'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=1000&q=85',
  ),
  DestinationInfo(
    'US',
    '미국',
    ['New York', 'New York City', 'NYC', '뉴욕', '纽约', '紐約', '미국 뉴욕', '美国纽约'],
    photoUrl:
        'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=1000&q=85',
  ),
  DestinationInfo('US', '미국', ['Los Angeles', '로스앤젤레스', '洛杉矶', '洛杉磯']),
  DestinationInfo('CN', '중국', ['Beijing', '베이징', '北京', '중국 베이징', '中国北京']),
  DestinationInfo('CN', '중국', ['Shanghai', '상하이', '上海', '중국 상하이', '中国上海']),
  DestinationInfo('SG', '싱가포르', ['Singapore', '싱가포르', '新加坡']),
  DestinationInfo('TH', '태국', ['Bangkok', '방콕', '曼谷']),
  DestinationInfo('VN', '베트남', ['Hanoi', '하노이', '河内', '河內']),
  DestinationInfo('VN', '베트남', ['Da Nang', 'Danang', '다낭', '岘港', '峴港']),
  DestinationInfo('IT', '이탈리아', ['Rome', 'Roma', '로마', '罗马', '羅馬']),
  DestinationInfo('ES', '스페인', ['Barcelona', '바르셀로나', '巴塞罗那', '巴塞羅那']),
  DestinationInfo('DE', '독일', ['Berlin', '베를린', '柏林']),
  DestinationInfo('AU', '호주', ['Sydney', '시드니', '悉尼', '雪梨']),
];

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'[,，\s]+'), ' ');

final _byAlias = <String, DestinationInfo>{
  for (final destination in _destinations)
    for (final alias in destination.aliases) _normalize(alias): destination,
};

/// Only known complete names match. Unknown or multi-city text stays unknown.
DestinationInfo? resolveDestination(String value) =>
    _byAlias[_normalize(value)];
