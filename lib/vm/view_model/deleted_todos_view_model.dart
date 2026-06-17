import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 삭제 보관함 화면의 ViewModel
/// 
/// 삭제 보관함 화면의 로컬 UI 상태를 관리합니다.
class DeletedTodosViewModel extends Notifier<DeletedTodosViewState> {
  @override
  DeletedTodosViewState build() {
    return DeletedTodosViewState(
      selectedDateFilter: 0, // 0 = 전체
      sortByTime: false,
      cachedStartDate: null,
      cachedEndDate: null,
    );
  }

  /// 날짜 필터 변경
  /// 0 = 전체, 1 = 오늘, 2 = 7일, 3 = 30일
  void setDateFilter(int filter) {
    state = state.copyWith(selectedDateFilter: filter);
    
    // 필터 변경 시 날짜 범위 재계산
    if (filter == 0) {
      // 전체 선택 시 캐시 초기화
      state = state.copyWith(
        cachedStartDate: null,
        cachedEndDate: null,
      );
    } else {
      final now = DateTime.now();
      DateTime? startDate;
      DateTime? endDate;
      
      if (filter == 1) {
        // 오늘
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (filter == 2) {
        // 7일
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
      } else if (filter == 3) {
        // 30일
        startDate = now.subtract(const Duration(days: 30));
        endDate = now;
      }
      
      state = state.copyWith(
        cachedStartDate: startDate,
        cachedEndDate: endDate,
      );
    }
  }

  /// 정렬 방식 변경
  void setSortByTime(bool sortByTime) {
    state = state.copyWith(sortByTime: sortByTime);
  }
}

/// 삭제 보관함 화면의 상태
class DeletedTodosViewState {
  final int selectedDateFilter; // 0 = 전체, 1 = 오늘, 2 = 7일, 3 = 30일
  final bool sortByTime; // true: 중요도순, false: 시간순
  final DateTime? cachedStartDate;
  final DateTime? cachedEndDate;

  DeletedTodosViewState({
    required this.selectedDateFilter,
    required this.sortByTime,
    required this.cachedStartDate,
    required this.cachedEndDate,
  });

  DeletedTodosViewState copyWith({
    int? selectedDateFilter,
    bool? sortByTime,
    DateTime? cachedStartDate,
    DateTime? cachedEndDate,
  }) {
    return DeletedTodosViewState(
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      sortByTime: sortByTime ?? this.sortByTime,
      cachedStartDate: cachedStartDate ?? this.cachedStartDate,
      cachedEndDate: cachedEndDate ?? this.cachedEndDate,
    );
  }
}

/// 삭제 보관함 화면 ViewModel Provider
final deletedTodosViewModelProvider =
    NotifierProvider<DeletedTodosViewModel, DeletedTodosViewState>(
      DeletedTodosViewModel.new,
    );
