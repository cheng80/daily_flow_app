import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../model/todo_model.dart';
import '../app_custom/step_mapper_util.dart';
import '../app_custom/app_common_util.dart';
import '../custom/custom_common_util.dart';

/// Todo 상세 정보 다이얼로그
///
/// 개별 Todo 항목의 상세 정보를 표시하는 다이얼로그입니다.
/// Edit 버튼을 통해 수정 화면으로 이동하거나 Close 버튼으로 닫을 수 있습니다.
class TodoDetailDialog {
  /// Todo 상세 다이얼로그 표시
  ///
  /// [context] BuildContext
  /// [todo] 표시할 Todo 객체
  ///
  /// 반환값: Edit 버튼 클릭 시 true, Close 버튼 클릭 시 false
  static Future<bool?> show({
    required BuildContext context,
    required Todo todo,
  }) async {
    final p = context.palette;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: p.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(12.0),

            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
            child: SingleChildScrollView(
              child: CustomColumn(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닫기 버튼 (오른쪽 정렬)
                  CustomRow(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.textSecondary.withOpacity(0.1),
                        ),
                        child: CustomIconButton(
                          icon: Icons.close,
                          iconColor: p.textSecondary,
                          backgroundColor: Colors.transparent,
                          size: 32,
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // 제목
                  CustomText(
                    todo.title,
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 날짜
                  CustomText(
                    CustomCommonUtil.formatDate(
                      DateTime.parse(todo.date),
                      'yyyy.MM.dd',
                    ),
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // 시간대와 시간 + 알람 정보
                  CustomRow(
                    spacing: 8,
                    children: [
                      // 시간대 (항상 표시)
                      CustomText(
                        '[ ${StepMapperUtil.stepToKorean(todo.step)} ]',
                        style: TextStyle(color: p.textSecondary, fontSize: 16),
                      ),
                      // 시간 (시간이 있을 때만 표시)
                      if (todo.time != null) ...[
                        CustomText(
                          CustomCommonUtil.formatTime12Hour(todo.time!),
                          style: TextStyle(color: p.textPrimary, fontSize: 16),
                        ),
                        // 알람 정보
                        if (todo.hasAlarm) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.alarm, size: 18, color: p.primary),
                          CustomText(
                            "알람 설정됨",
                            style: TextStyle(color: p.primary, fontSize: 14),
                          ),
                        ],
                      ],
                    ],
                  ),

                  // 메모 영역
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.purple.shade200,
                        width: 1,
                      ),
                    ),
                    constraints: const BoxConstraints(minHeight: 100),
                    child: CustomText(
                      todo.memo != null && todo.memo!.isNotEmpty
                          ? todo.memo!
                          : "상세 일정 메모",
                      style: TextStyle(
                        color: todo.memo != null && todo.memo!.isNotEmpty
                            ? p.textPrimary
                            : p.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // 중요도 : [매우 높음] (색상 카드)
                  CustomRow(
                    spacing: 8,
                    children: [
                      CustomText(
                        "중요도 :",
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getPriorityColor(todo.priority, p),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomText(
                          getPriorityText(todo.priority),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 완료 상태
                  if (todo.isDone)
                    CustomText(
                      "완료",
                      style: TextStyle(
                        color: p.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Edit 버튼
                  CustomButton(
                    btnText: "Edit",
                    buttonType: ButtonType.elevated,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    onCallBack: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
