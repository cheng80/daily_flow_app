import 'package:flutter_test/flutter_test.dart';
import 'package:daily_flow_app/app_custom/step_mapper_util.dart';

void main() {
  group('StepMapperUtil Tests', () {
    group('mapTimeToStep - 시간 → Step 변환', () {
      test('아침 시간대 (06:00 ~ 11:59)', () {
        // Given & When & Then
        expect(
          StepMapperUtil.mapTimeToStep("06:00"),
          equals(StepMapperUtil.stepMorning),
        );
        expect(
          StepMapperUtil.mapTimeToStep("08:30"),
          equals(StepMapperUtil.stepMorning),
        );
        expect(
          StepMapperUtil.mapTimeToStep("11:59"),
          equals(StepMapperUtil.stepMorning),
        );
      });

      test('낮 시간대 (12:00 ~ 17:59)', () {
        // Given & When & Then
        expect(
          StepMapperUtil.mapTimeToStep("12:00"),
          equals(StepMapperUtil.stepNoon),
        );
        expect(
          StepMapperUtil.mapTimeToStep("14:30"),
          equals(StepMapperUtil.stepNoon),
        );
        expect(
          StepMapperUtil.mapTimeToStep("17:59"),
          equals(StepMapperUtil.stepNoon),
        );
      });

      test('저녁 시간대 (18:00 ~ 23:59)', () {
        // Given & When & Then
        expect(
          StepMapperUtil.mapTimeToStep("18:00"),
          equals(StepMapperUtil.stepEvening),
        );
        expect(
          StepMapperUtil.mapTimeToStep("20:30"),
          equals(StepMapperUtil.stepEvening),
        );
        expect(
          StepMapperUtil.mapTimeToStep("23:59"),
          equals(StepMapperUtil.stepEvening),
        );
      });

      test('새벽 시간대 (00:00 ~ 05:59) → Anytime', () {
        // Given & When & Then
        expect(
          StepMapperUtil.mapTimeToStep("00:00"),
          equals(StepMapperUtil.stepAnytime),
        );
        expect(
          StepMapperUtil.mapTimeToStep("03:30"),
          equals(StepMapperUtil.stepAnytime),
        );
        expect(
          StepMapperUtil.mapTimeToStep("05:59"),
          equals(StepMapperUtil.stepAnytime),
        );
      });

      test('null 또는 빈 문자열 → Anytime', () {
        // Given & When & Then
        expect(
          StepMapperUtil.mapTimeToStep(null),
          equals(StepMapperUtil.stepAnytime),
        );
        expect(
          StepMapperUtil.mapTimeToStep(""),
          equals(StepMapperUtil.stepAnytime),
        );
        expect(
          StepMapperUtil.mapTimeToStep("   "),
          equals(StepMapperUtil.stepAnytime),
        );
      });

      test('잘못된 형식 → Anytime', () {
        // Given & When & Then
        expect(
          StepMapperUtil.mapTimeToStep("14"),
          equals(StepMapperUtil.stepAnytime),
        );
        expect(
          StepMapperUtil.mapTimeToStep("14:30:00"),
          equals(StepMapperUtil.stepAnytime),
        );
        expect(
          StepMapperUtil.mapTimeToStep("invalid"),
          equals(StepMapperUtil.stepAnytime),
        );
        expect(
          StepMapperUtil.mapTimeToStep("25:00"),
          equals(StepMapperUtil.stepAnytime),
        ); // 유효하지 않은 시간
        expect(
          StepMapperUtil.mapTimeToStep("14:60"),
          equals(StepMapperUtil.stepAnytime),
        ); // 유효하지 않은 분
      });

      test('경계값 테스트', () {
        // Given & When & Then
        // 아침 시작
        expect(
          StepMapperUtil.mapTimeToStep("05:59"),
          equals(StepMapperUtil.stepAnytime),
        );
        expect(
          StepMapperUtil.mapTimeToStep("06:00"),
          equals(StepMapperUtil.stepMorning),
        );

        // 낮 시작
        expect(
          StepMapperUtil.mapTimeToStep("11:59"),
          equals(StepMapperUtil.stepMorning),
        );
        expect(
          StepMapperUtil.mapTimeToStep("12:00"),
          equals(StepMapperUtil.stepNoon),
        );

        // 저녁 시작
        expect(
          StepMapperUtil.mapTimeToStep("17:59"),
          equals(StepMapperUtil.stepNoon),
        );
        expect(
          StepMapperUtil.mapTimeToStep("18:00"),
          equals(StepMapperUtil.stepEvening),
        );

        // 자정
        expect(
          StepMapperUtil.mapTimeToStep("23:59"),
          equals(StepMapperUtil.stepEvening),
        );
        expect(
          StepMapperUtil.mapTimeToStep("00:00"),
          equals(StepMapperUtil.stepAnytime),
        );
      });
    });

    group('stepToKorean - Step → 한국어 변환', () {
      test('유효한 Step 값 변환', () {
        // Given & When & Then
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepMorning),
          equals("아침"),
        );
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepNoon),
          equals("낮"),
        );
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepEvening),
          equals("저녁"),
        );
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepAnytime),
          equals("Anytime"),
        );
      });

      test('유효하지 않은 Step 값 → Anytime', () {
        // Given & When & Then
        expect(StepMapperUtil.stepToKorean(-1), equals("Anytime"));
        expect(StepMapperUtil.stepToKorean(4), equals("Anytime"));
        expect(StepMapperUtil.stepToKorean(100), equals("Anytime"));
      });
    });

    group('통합 테스트 - 시간 → Step → 한국어', () {
      test('시간 입력부터 한국어 출력까지 전체 플로우', () {
        // Given: 다양한 시간 입력
        final testCases = [
          ("08:00", StepMapperUtil.stepMorning, "아침"),
          ("14:30", StepMapperUtil.stepNoon, "낮"),
          ("20:00", StepMapperUtil.stepEvening, "저녁"),
          ("03:00", StepMapperUtil.stepAnytime, "Anytime"),
          (null, StepMapperUtil.stepAnytime, "Anytime"),
        ];

        for (final testCase in testCases) {
          // When: 시간 → Step → 한국어 변환
          final step = StepMapperUtil.mapTimeToStep(testCase.$1);
          final korean = StepMapperUtil.stepToKorean(step);

          // Then: 예상된 결과와 일치하는지 확인
          expect(step, equals(testCase.$2));
          expect(korean, equals(testCase.$3));
        }
      });
    });
  });
}
