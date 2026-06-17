import 'package:flutter_test/flutter_test.dart';
import 'package:daily_flow_app/app_custom/step_mapper_util.dart';

void main() {
  group('StepMapperUtil Tests', () {
    group('mapTimeToStep - 시간 -> Step 변환', () {
      test('오전 시간대 (06:00 ~ 11:59)', () {
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

      test('오후 시간대 (12:00 ~ 17:59)', () {
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

      test('야간 시간대 (00:00 ~ 05:59)', () {
        expect(
          StepMapperUtil.mapTimeToStep("00:00"),
          equals(StepMapperUtil.stepNight),
        );
        expect(
          StepMapperUtil.mapTimeToStep("03:30"),
          equals(StepMapperUtil.stepNight),
        );
        expect(
          StepMapperUtil.mapTimeToStep("05:59"),
          equals(StepMapperUtil.stepNight),
        );
      });

      test('null 또는 빈 문자열 -> 종일', () {
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

      test('잘못된 형식 -> 종일', () {
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
        );
        expect(
          StepMapperUtil.mapTimeToStep("14:60"),
          equals(StepMapperUtil.stepAnytime),
        );
      });

      test('경계값 테스트', () {
        expect(
          StepMapperUtil.mapTimeToStep("05:59"),
          equals(StepMapperUtil.stepNight),
        );
        expect(
          StepMapperUtil.mapTimeToStep("06:00"),
          equals(StepMapperUtil.stepMorning),
        );
        expect(
          StepMapperUtil.mapTimeToStep("11:59"),
          equals(StepMapperUtil.stepMorning),
        );
        expect(
          StepMapperUtil.mapTimeToStep("12:00"),
          equals(StepMapperUtil.stepNoon),
        );
        expect(
          StepMapperUtil.mapTimeToStep("17:59"),
          equals(StepMapperUtil.stepNoon),
        );
        expect(
          StepMapperUtil.mapTimeToStep("18:00"),
          equals(StepMapperUtil.stepEvening),
        );
        expect(
          StepMapperUtil.mapTimeToStep("23:59"),
          equals(StepMapperUtil.stepEvening),
        );
        expect(
          StepMapperUtil.mapTimeToStep("00:00"),
          equals(StepMapperUtil.stepNight),
        );
      });
    });

    group('stepToKorean - Step -> 한국어 변환', () {
      test('유효한 Step 값 변환', () {
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepMorning),
          equals("오전"),
        );
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepNoon),
          equals("오후"),
        );
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepEvening),
          equals("저녁"),
        );
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepNight),
          equals("야간"),
        );
        expect(
          StepMapperUtil.stepToKorean(StepMapperUtil.stepAnytime),
          equals("종일"),
        );
      });

      test('유효하지 않은 Step 값 -> 종일', () {
        expect(StepMapperUtil.stepToKorean(-1), equals("종일"));
        expect(StepMapperUtil.stepToKorean(4), equals("종일"));
        expect(StepMapperUtil.stepToKorean(100), equals("종일"));
      });
    });

    group('통합 테스트 - 시간 -> Step -> 한국어', () {
      test('시간 입력부터 한국어 출력까지 전체 플로우', () {
        final testCases = [
          ("08:00", StepMapperUtil.stepMorning, "오전"),
          ("14:30", StepMapperUtil.stepNoon, "오후"),
          ("20:00", StepMapperUtil.stepEvening, "저녁"),
          ("03:00", StepMapperUtil.stepNight, "야간"),
          (null, StepMapperUtil.stepAnytime, "종일"),
        ];

        for (final testCase in testCases) {
          final step = StepMapperUtil.mapTimeToStep(testCase.$1);
          final korean = StepMapperUtil.stepToKorean(step);

          expect(step, equals(testCase.$2));
          expect(korean, equals(testCase.$3));
        }
      });
    });
  });
}
