import 'package:flutter/foundation.dart';

/// 앱 전역 로깅 유틸리티 클래스
///
/// 디버그 모드와 릴리즈 모드를 자동으로 구분하여 로깅을 관리합니다.
/// - 디버그 모드: 모든 로그 출력
/// - 릴리즈 모드: 에러 로그만 출력 (선택적)
///
/// 릴리즈 빌드에서도 로그를 확인하려면:
/// - `adb logcat` (Android): `adb logcat | grep "ERROR\|WARN"`
/// - Xcode Console (iOS): 디바이스 연결 후 로그 확인
///
/// 사용 예시:
/// ```dart
/// AppLogger.d('디버그 메시지');
/// AppLogger.i('정보 메시지', tag: 'API');
/// AppLogger.w('경고 메시지', tag: 'Network');
/// AppLogger.e('에러 메시지', tag: 'Database', error: exception);
/// ```
class AppLogger {
  /// 릴리즈 모드에서도 에러 로그 출력 여부
  /// true: 릴리즈 모드에서도 에러 로그 출력 (adb logcat으로 확인 가능)
  /// false: 릴리즈 모드에서 모든 로그 비활성화
  static const bool _enableReleaseErrorLogs = true;
  /// 디버그 로그
  ///
  /// 개발 중 디버깅 정보를 출력합니다.
  ///
  /// [message] 출력할 메시지
  /// [tag] 로그 태그 (선택적, 카테고리 구분용)
  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('🔵 DEBUG: $prefix$message');
    }
  }

  /// 정보 로그
  ///
  /// 일반적인 정보 메시지를 출력합니다.
  ///
  /// [message] 출력할 메시지
  /// [tag] 로그 태그 (선택적, 카테고리 구분용)
  static void i(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('ℹ️ INFO: $prefix$message');
    }
  }

  /// 경고 로그
  ///
  /// 경고 메시지를 출력합니다.
  ///
  /// [message] 출력할 메시지
  /// [tag] 로그 태그 (선택적, 카테고리 구분용)
  /// [error] 에러 객체 (선택적)
  static void w(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('⚠️ WARN: $prefix$message');
      if (error != null) {
        print('   Error: $error');
      }
    }
  }

  /// 에러 로그
  ///
  /// 에러 메시지와 스택 트레이스를 출력합니다.
  /// 릴리즈 모드에서도 출력됩니다 (설정에 따라).
  ///
  /// [message] 출력할 메시지
  /// [tag] 로그 태그 (선택적, 카테고리 구분용)
  /// [error] 에러 객체 (선택적)
  /// [stackTrace] 스택 트레이스 (선택적)
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // 디버그 모드 또는 릴리즈 모드에서 에러 로그 활성화된 경우
    if (kDebugMode || _enableReleaseErrorLogs) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('❌ ERROR: $prefix$message');
      if (error != null) {
        print('   Error: $error');
      }
      if (stackTrace != null) {
        print('   StackTrace: $stackTrace');
      }
    }
  }

  /// 성공 로그
  ///
  /// 성공 메시지를 출력합니다.
  ///
  /// [message] 출력할 메시지
  /// [tag] 로그 태그 (선택적, 카테고리 구분용)
  static void s(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('✅ SUCCESS: $prefix$message');
    }
  }
}

