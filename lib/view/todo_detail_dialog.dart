import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../model/todo_model.dart';
import '../app_custom/step_mapper_util.dart';
import '../app_custom/app_common_util.dart';

//----------------------------------
//-- TodoDetailDialog
//----------------------------------

// Todo 상세 정보 다이얼로그
//
// 개별 Todo 항목의 상세 정보를 표시하는 다이얼로그입니다.
// Edit 버튼을 통해 수정 화면으로 이동하거나 Close 버튼으로 닫을 수 있습니다.
class TodoDetailDialog {
  // Todo 상세 다이얼로그 표시
  //
  // [context] BuildContext
  // [todo] 표시할 Todo 객체
  //
  // 반환값: Edit 버튼 클릭 시 true, Close 버튼 클릭 시 false
  static Future<bool?> show({
    required BuildContext context,
    required Todo todo,
  }) async {
    final p = context.palette;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
            decoration: BoxDecoration(
              color: p.cardBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                child: CustomColumn(
                  spacing: 0,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(dialogContext, p, todo),
                    _buildBody(p, todo),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //----------------------------------
  //-- 헤더 영역
  //----------------------------------

  static Widget _buildHeader(
    BuildContext dialogContext,
    AppColorScheme p,
    Todo todo,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: p.primary),
      child: CustomRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomColumn(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.isDone) _buildDoneBadge(),
                CustomText(
                  todo.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildCloseButton(dialogContext),
        ],
      ),
    );
  }

  // 완료 상태 배지
  static Widget _buildDoneBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomRow(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.white),
          CustomText(
            "완료됨",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 닫기 버튼
  static Widget _buildCloseButton(BuildContext dialogContext) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      child: CustomIconButton(
        icon: Icons.close_rounded,
        iconColor: Colors.white,
        backgroundColor: Colors.transparent,
        size: 36,
        onPressed: () => Navigator.of(dialogContext).pop(false),
      ),
    );
  }

  //----------------------------------
  //-- 본문 영역
  //----------------------------------

  static Widget _buildBody(AppColorScheme p, Todo todo) {
    return CustomPadding.all(
      24,
      child: CustomColumn(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimeCard(p, todo),
          _buildMemoSection(p, todo),
          _buildPriorityCard(p, todo),
          const SizedBox(height: 8),
          _buildEditButton(p),
        ],
      ),
    );
  }

  //----------------------------------
  //-- 날짜 및 시간 정보
  //----------------------------------

  static Widget _buildDateTimeCard(AppColorScheme p, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.divider, width: 1),
      ),
      child: CustomColumn(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜
          _buildInfoRow(
            p,
            Icons.calendar_today_rounded,
            p.primary,
            CustomText(
              CustomCommonUtil.formatDate(
                DateTime.parse(todo.date),
                'yyyy년 MM월 dd일',
              ),
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 시간대와 시간
          _buildInfoRow(
            p,
            Icons.access_time_rounded,
            p.accent,
            Expanded(
              child: CustomRow(
                spacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomText(
                      StepMapperUtil.stepToKorean(todo.step),
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (todo.time != null)
                    CustomText(
                      CustomCommonUtil.formatTime12Hour(todo.time!),
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    CustomText(
                      "종일",
                      style: TextStyle(color: p.textSecondary, fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
          // 알람 정보
          if (todo.hasAlarm && todo.time != null)
            _buildInfoRow(
              p,
              Icons.alarm_rounded,
              Colors.orange,
              CustomText(
                "알람 설정됨",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 아이콘 + 내용 행
  static Widget _buildInfoRow(
    AppColorScheme p,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return CustomRow(
      spacing: 12,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        content,
      ],
    );
  }

  //----------------------------------
  //-- 메모 영역
  //----------------------------------

  static Widget _buildMemoSection(AppColorScheme p, Todo todo) {
    return CustomColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          "메모",
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.divider, width: 1),
          ),
          constraints: const BoxConstraints(minHeight: 120),
          child: CustomText(
            todo.memo != null && todo.memo!.isNotEmpty
                ? todo.memo!
                : "메모가 없습니다",
            style: TextStyle(
              color: todo.memo != null && todo.memo!.isNotEmpty
                  ? p.textPrimary
                  : p.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  //----------------------------------
  //-- 중요도 카드
  //----------------------------------

  static Widget _buildPriorityCard(AppColorScheme p, Todo todo) {
    final color = getPriorityColor(todo.priority, p);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: CustomRow(
        spacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.flag_rounded, size: 24, color: Colors.white),
          ),
          Expanded(
            child: CustomColumn(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  "중요도",
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
                CustomText(
                  getPriorityText(todo.priority),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------
  //-- 수정 버튼
  //----------------------------------

  static Widget _buildEditButton(AppColorScheme p) {
    return Builder(
      builder: (context) {
        return CustomButton(
          btnText: CustomRow(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_rounded, size: 20, color: Colors.white),
              CustomText(
                "수정하기",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          buttonType: ButtonType.elevated,
          backgroundColor: p.primary,
          textColor: Colors.white,
          onCallBack: () => Navigator.of(context).pop(true),
          minimumSize: const Size(double.infinity, 56),
        );
      },
    );
  }
}
