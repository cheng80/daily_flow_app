import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom/custom.dart';
import '../custom/external_util/slidable/custom_slidable.dart';
import '../theme/app_colors.dart';
import '../vm/theme_notifier.dart';
import 'deleted_todos_view.dart';
import 'home.dart';

// 메인 화면 Drawer
//
// 메인 화면에서 사용하는 Drawer 위젯입니다.
// 설정, 삭제 보관함, Home 화면으로 이동할 수 있는 메뉴를 제공합니다.
class MainDrawer extends ConsumerWidget {
  // 위젯이 마운트되어 있는지 확인하는 함수
  final bool Function() isMounted;

  // 슬라이더블 리스트 키 (화면 이동 전 슬라이더블 닫기용)
  final GlobalKey<CustomSlidableListState>? slidableKey;

  const MainDrawer({
    super.key,
    required this.isMounted,
    this.slidableKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;

    return CustomDrawer(
      header: DrawerHeader(
        decoration: BoxDecoration(color: p.primary),
        child: CustomColumn(
          width: double.infinity,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 48,
                  color: p.textOnPrimary,
                ),
                const SizedBox(width: 12),
                CustomText(
                  "설정",
                  style: TextStyle(
                    color: p.textOnPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      items: [
        // 다크 모드 토글
        DrawerItem(
          label: CustomRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomRow(
                spacing: 12,
                children: [
                  Icon(Icons.light_mode_outlined, color: p.textPrimary),
                  CustomText(
                    "다크 모드",
                    style: TextStyle(color: p.textPrimary, fontSize: 16),
                  ),
                ],
              ),
              Consumer(
                builder: (context, ref, child) {
                  final themeMode = ref.watch(themeNotifierProvider);
                  final isDark = themeMode == ThemeMode.dark;
                  return Switch(
                    value: isDark,
                    onChanged: (value) {
                      ref.read(themeNotifierProvider.notifier).toggleTheme();
                    },
                  );
                },
              ),
            ],
          ),
          onTap: () {
            ref.read(themeNotifierProvider.notifier).toggleTheme();
          },
        ),
        // 삭제 보관함
        DrawerItem(
          label: "삭제 보관함",
          icon: Icons.delete_outline,
          iconColor: p.textPrimary,
          onTap: () async {
            slidableKey?.currentState?.closeAll();
            // CustomDrawer가 이미 Drawer를 닫으므로, 네비게이션만 처리
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!isMounted()) return;
              await _navigateToDeletedTodos(context);
            });
          },
        ),
        // Home 화면으로 이동
        DrawerItem(
          label: "Home",
          icon: Icons.home_outlined,
          iconColor: p.textPrimary,
          onTap: () async {
            slidableKey?.currentState?.closeAll();
            // CustomDrawer가 이미 Drawer를 닫으므로, 네비게이션만 처리
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!isMounted()) return;
              await _navigateToHome(context);
            });
          },
        ),
      ],
      footer: Container(
        padding: const EdgeInsets.all(16),
        child: CustomColumn(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 4,
          children: [
            Divider(color: p.textSecondary.withValues(alpha: 0.2)),
            CustomText(
              "DailyFlow v1.0.0",
              style: TextStyle(color: p.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // 삭제된 Todo 화면으로 이동
  Future<void> _navigateToDeletedTodos(BuildContext context) async {
    await CustomNavigationUtil.to(
      context,
      const DeletedTodosView(),
      transitionType: PageTransitionType.fade,
    );
  }

  // Home 화면으로 이동 (off 모드)
  Future<void> _navigateToHome(BuildContext context) async {
    await CustomNavigationUtil.off(
      context,
      const Home(),
      transitionType: PageTransitionType.fade,
    );
  }
}
