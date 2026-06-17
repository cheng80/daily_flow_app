import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'custom_address_util.dart';

// CustomAddressUtil 사용 예제
void main() async {
  // BigDataCloud API 응답 예시 JSON
  const jsonString = '''
{
  "latitude": 37.497429,
  "longitude": 127.127782,
  "countryName": "대한민국",
  "countryCode": "KR",
  "principalSubdivision": "서울특별시",
  "city": "서울특별시",
  "locality": "가락2동",
  "localityInfo": {
    "administrative": [
      {
        "name": "대한민국",
        "adminLevel": 2
      },
      {
        "name": "서울특별시",
        "adminLevel": 4
      },
      {
        "name": "송파구",
        "adminLevel": 6
      },
      {
        "name": "가락2동",
        "adminLevel": 8
      }
    ]
  }
}
''';

  // 1. 기본 주소 파싱 (국가 포함)
  final address = CustomAddressUtil.parseAddress(jsonString);
  debugPrint('전체 주소: $address');
  // 출력: 전체 주소: 대한민국 서울특별시 송파구 가락2동

  // 2. 간단한 주소 파싱 (국가 제외)
  final simpleAddress = CustomAddressUtil.parseSimpleAddress(jsonString);
  debugPrint('간단한 주소: $simpleAddress');
  // 출력: 간단한 주소: 서울특별시 송파구 가락2동

  // 3. 커스텀 구분자 사용
  final addressWithComma = CustomAddressUtil.parseAddress(
    jsonString,
    separator: ", ",
  );
  debugPrint('쉼표 구분 주소: $addressWithComma');
  // 출력: 쉼표 구분 주소: 대한민국, 서울특별시, 송파구, 가락2동

  // 4. 국가 제외하고 커스텀 구분자 사용
  final addressWithoutCountry = CustomAddressUtil.parseAddress(
    jsonString,
    separator: " > ",
    includeCountry: false,
  );
  debugPrint('화살표 구분 주소: $addressWithoutCountry');
  // 출력: 화살표 구분 주소: 서울특별시 > 송파구 > 가락2동

  // 5. 상세 주소 정보 가져오기
  final addressInfo = CustomAddressUtil.getAddressInfo(jsonString);
  if (addressInfo != null) {
    debugPrint('\n=== 상세 주소 정보 ===');
    debugPrint('국가: ${addressInfo['countryName']}');
    debugPrint('시/도: ${addressInfo['province']}');
    debugPrint('시: ${addressInfo['city']}');
    debugPrint('구: ${addressInfo['district']}');
    debugPrint('동: ${addressInfo['locality']}');
    debugPrint('전체 주소: ${addressInfo['fullAddress']}');
  }

  // 6. Map 형태의 JSON에서 직접 파싱
  final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
  final addressFromMap = CustomAddressUtil.parseAddressFromMap(jsonMap);
  debugPrint('\nMap에서 파싱한 주소: $addressFromMap');

  // 7. 위도, 경도로 주소 가져오기 (API 호출) - 예외 처리 포함
  debugPrint('\n=== 위도, 경도로 주소 가져오기 ===');
  try {
    final addressFromCoords = await CustomAddressUtil.getAddressFromCoordinates(
      37.497429,
      127.127782,
    );
    debugPrint('위도/경도로 가져온 주소: $addressFromCoords');
    // 출력: 위도/경도로 가져온 주소: 대한민국 서울특별시 송파구 가락2동
  } on AddressException catch (e) {
    debugPrint('주소 가져오기 실패: ${e.message} (코드: ${e.code})');
  }

  // 8. 간단한 주소 가져오기 (국가 제외) - 예외 처리 포함
  try {
    final simpleAddressFromCoords =
        await CustomAddressUtil.getSimpleAddressFromCoordinates(
          37.497429,
          127.127782,
        );
    debugPrint('간단한 주소: $simpleAddressFromCoords');
    // 출력: 간단한 주소: 서울특별시 송파구 가락2동
  } on AddressException catch (e) {
    debugPrint('간단한 주소 가져오기 실패: ${e.message}');
  }

  // 9. 상세 주소 정보 가져오기 - 예외 처리 포함
  try {
    final addressInfoFromCoords =
        await CustomAddressUtil.getAddressInfoFromCoordinates(
          37.497429,
          127.127782,
        );
    if (addressInfoFromCoords != null) {
      debugPrint('\n상세 주소 정보:');
      debugPrint('국가: ${addressInfoFromCoords['countryName']}');
      debugPrint('시/도: ${addressInfoFromCoords['province']}');
      debugPrint('시: ${addressInfoFromCoords['city']}');
      debugPrint('구: ${addressInfoFromCoords['district']}');
      debugPrint('동: ${addressInfoFromCoords['locality']}');
      debugPrint('전체 주소: ${addressInfoFromCoords['fullAddress']}');
    }
  } on AddressException catch (e) {
    debugPrint('상세 주소 정보 가져오기 실패: ${e.message} (코드: ${e.code})');
  }

  // 10. 잘못된 좌표로 예외 처리 테스트
  debugPrint('\n=== 예외 처리 테스트 ===');
  try {
    await CustomAddressUtil.getAddressFromCoordinates(999, 999);
  } on AddressException catch (e) {
    debugPrint('예외 발생: ${e.message} (코드: ${e.code})');
    // 출력: 예외 발생: 유효하지 않은 좌표입니다. 위도: 999.0, 경도: 999.0 (코드: INVALID_COORDINATE)
  }
}
