import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/todo_model.dart';
import '../../vm/vm_notifier.dart';
import '../../custom/custom_common_util.dart';
import '../../custom/util/log/custom_log_util.dart';
import '../../service/notification_service.dart';

/// 메인 달력 화면의 ViewModel
/// 
/// 메인 달력 화면의 로컬 UI 상태와 비즈니스 로직을 관리합니다.
class MainRangeViewModel extends Notifier<MainRangeViewState> {
  @override
  MainRangeViewState build() {
    final now = DateTime.now();
    return MainRangeViewState(
      selectedDay: now,
      focusedDay: now,
      minDate: null,
      maxDate: null,
      sortByTime: false,
      calendarExpanded: true,
    );
  }

  /// 선택된 날짜 변경
  void setSelectedDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  /// 포커스된 날짜 변경
  void setFocusedDay(DateTime day) {
    state = state.copyWith(focusedDay: day);
  }

  /// 최소 날짜 설정
  void setMinDate(DateTime? date) {
    state = state.copyWith(minDate: date);
  }

  /// 최대 날짜 설정
  void setMaxDate(DateTime? date) {
    state = state.copyWith(maxDate: date);
  }

  /// 정렬 방식 변경
  void setSortByTime(bool sortByTime) {
    state = state.copyWith(sortByTime: sortByTime);
  }

  /// 달력 확장 상태 변경
  void setCalendarExpanded(bool expanded) {
    state = state.copyWith(calendarExpanded: expanded);
  }

  /// 오늘 날짜로 이동
  void goToToday() {
    final now = DateTime.now();
    state = state.copyWith(
      selectedDay: now,
      focusedDay: now,
    );
  }

  //----------------------------------
  //-- Business Logic Methods
  //----------------------------------

  /// Todo 리스트 정렬
  ///
  /// [todos] 정렬할 Todo 리스트
  /// 반환값: 정렬된 Todo 리스트
  /// - 중요도순: priority 내림차순, 같으면 time 오름차순
  /// - 시간순: time이 null이면 뒤로, 같으면 priority 내림차순
  List<Todo> sortTodos(List<Todo> todos) {
    final sorted = List<Todo>.from(todos);

    if (state.sortByTime) {
      // 중요도순 정렬: priority 내림차순, 같으면 time 오름차순
      sorted.sort((a, b) {
        final priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;

        // priority가 같으면 time 비교
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1; // a가 null이면 뒤로
        if (b.time == null) return -1; // b가 null이면 뒤로

        return a.time!.compareTo(b.time!); // time 오름차순
      });
    } else {
      // 시간순 정렬: time이 null이면 뒤로, 같으면 priority 내림차순
      sorted.sort((a, b) {
        if (a.time == null && b.time == null) {
          return b.priority.compareTo(a.priority); // priority 내림차순
        }
        if (a.time == null) return 1; // a가 null이면 뒤로
        if (b.time == null) return -1; // b가 null이면 뒤로

        // time 오름차순 비교
        final timeCompare = a.time!.compareTo(b.time!);
        if (timeCompare != 0) return timeCompare;

        // time이 같으면 priority 내림차순
        return b.priority.compareTo(a.priority);
      });
    }

    return sorted;
  }

  /// 날짜 선택 처리
  ///
  /// [selectedDay] 사용자가 선택한 날짜
  /// [focusedDay] 현재 포커스된 날짜
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    AppLogger.d(
      '[날짜 선택 시작] selectedDay: ${selectedDay.toString().split(' ')[0]}, focusedDay: ${focusedDay.toString().split(' ')[0]}',
      tag: 'MainRangeViewModel',
    );

    // 날짜 유효성 검사: 현재 날짜 기준 ±5년 이내만 허용
    final now = DateTime.now();
    final minValidDate = DateTime(now.year - 5, 1, 1);
    final maxValidDate = DateTime(now.year + 5, 12, 31);

    // selectedDay가 유효 범위를 벗어나면 무시하고 현재 focusedDay 사용
    if (selectedDay.isBefore(minValidDate) ||
        selectedDay.isAfter(maxValidDate)) {
      AppLogger.e(
        '[날짜 선택 무시] 비정상적인 날짜: ${selectedDay.toString().split(' ')[0]} (범위: ${minValidDate.toString().split(' ')[0]} ~ ${maxValidDate.toString().split(' ')[0]}), focusedDay로 대체',
        tag: 'MainRangeViewModel',
      );
      // focusedDay가 유효하면 focusedDay 사용, 아니면 현재 날짜 사용
      if (focusedDay.isBefore(minValidDate) ||
          focusedDay.isAfter(maxValidDate)) {
        goToToday();
      } else {
        setSelectedDay(focusedDay);
        setFocusedDay(focusedDay);
      }
    } else {
      setSelectedDay(selectedDay);
      // focusedDay도 유효한 범위인지 확인
      if (focusedDay.isBefore(minValidDate) ||
          focusedDay.isAfter(maxValidDate)) {
        AppLogger.e(
          '[focusedDay 조정] 비정상적인 focusedDay: ${focusedDay.toString().split(' ')[0]}, selectedDay로 대체',
          tag: 'MainRangeViewModel',
        );
        setFocusedDay(selectedDay);
      } else {
        setFocusedDay(focusedDay);
      }
    }

    AppLogger.d(
      '[날짜 선택 완료] 최종 selectedDay: ${state.selectedDay.toString().split(' ')[0]}, focusedDay: ${state.focusedDay.toString().split(' ')[0]}',
      tag: 'MainRangeViewModel',
    );
  }

  /// 달력 페이지 변경 처리
  ///
  /// [focusedDay] 변경된 포커스 날짜
  void onPageChanged(DateTime focusedDay) {
    setFocusedDay(focusedDay);
  }

  /// 이전 월 이동
  void onPreviousMonth() {
    final previousMonth = DateTime(
      state.focusedDay.year,
      state.focusedDay.month - 1,
      state.focusedDay.day,
    );
    onPageChanged(previousMonth);
  }

  /// 다음 월 이동
  void onNextMonth() {
    final nextMonth = DateTime(
      state.focusedDay.year,
      state.focusedDay.month + 1,
      state.focusedDay.day,
    );
    onPageChanged(nextMonth);
  }

  /// 이벤트 로더
  ///
  /// [day] 조회할 날짜
  /// 반환값: 해당 날짜의 Todo 리스트
  List<Todo> eventLoader(DateTime day) {
    // 날짜를 'YYYY-MM-DD' 형식으로 변환
    final dateStr = CustomCommonUtil.formatDate(day, 'yyyy-MM-dd');
    // Provider에서 직접 조회
    final yearMonth = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}';
    final calendarAsync = ref.read(calendarEventsProvider(yearMonth));
    return calendarAsync.when(
      data: (cache) => cache[dateStr] ?? [],
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Todo 완료 상태 토글
  ///
  /// [todo] 완료 상태를 변경할 Todo 객체
  /// [value] 새로운 완료 상태 (null일 수 있음)
  Future<void> toggleTodoDone(Todo todo, bool? value) async {
    if (todo.id != null) {
      final notifier = ref.read(todoNotifierProvider(TodoType.normal).notifier);
      await notifier.toggleDone(todo.id!, value ?? false);
      reloadData();
    }
  }

  /// 데이터 다시 로드
  ///
  /// Todo 리스트, 달력 이벤트를 모두 갱신합니다.
  void reloadData() {
    // Provider를 invalidate하여 자동으로 rebuild되도록 함
    ref.invalidate(todoByDateProvider(CustomCommonUtil.formatDate(state.selectedDay, 'yyyy-MM-dd')));
    final yearMonth = '${state.focusedDay.year.toString().padLeft(4, '0')}-${state.focusedDay.month.toString().padLeft(2, '0')}';
    ref.invalidate(calendarEventsProvider(yearMonth));
  }

  /// Todo 삭제
  ///
  /// [todo] 삭제할 Todo 객체
  Future<void> deleteTodo(Todo todo) async {
    // 알람이 있으면 취소
    if (todo.notificationId != null) {
      final notificationService = NotificationService();
      await notificationService.cancelNotification(todo.notificationId!);
      AppLogger.s(
        "알람 취소 완료: notificationId=${todo.notificationId}",
        tag: 'MainRangeViewModel',
      );
    }

    final notifier = ref.read(todoNotifierProvider(TodoType.normal).notifier);
    await notifier.deleteTodo(todo);
    reloadData();
  }
}

/// 메인 달력 화면의 상태
class MainRangeViewState {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool sortByTime; // true=중요도순, false=시간순
  final bool calendarExpanded;

  MainRangeViewState({
    required this.selectedDay,
    required this.focusedDay,
    required this.minDate,
    required this.maxDate,
    required this.sortByTime,
    required this.calendarExpanded,
  });

  MainRangeViewState copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    DateTime? minDate,
    DateTime? maxDate,
    bool? sortByTime,
    bool? calendarExpanded,
  }) {
    return MainRangeViewState(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      minDate: minDate ?? this.minDate,
      maxDate: maxDate ?? this.maxDate,
      sortByTime: sortByTime ?? this.sortByTime,
      calendarExpanded: calendarExpanded ?? this.calendarExpanded,
    );
  }
}

/// 메인 달력 화면 ViewModel Provider
final mainRangeViewModelProvider =
    NotifierProvider<MainRangeViewModel, MainRangeViewState>(
      MainRangeViewModel.new,
    );
