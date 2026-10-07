import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../providers/locale_provider.dart';
import '../providers/phase2/phase2_providers.dart';
import '../screens/phase2/landing/landing_checklist_screen.dart';
import '../screens/phase2/guides/guides_screen.dart';
import '../screens/phase2/employment/employment_hub_screen.dart';
import '../screens/phase2/regional_work/regional_work_screen.dart';
import '../widgets/phase2/visa_dates_survey_dialog.dart';

class Phase2NavigationScreen extends ConsumerStatefulWidget {
  const Phase2NavigationScreen({super.key});

  @override
  ConsumerState<Phase2NavigationScreen> createState() => _Phase2NavigationScreenState();
}

class _Phase2NavigationScreenState extends ConsumerState<Phase2NavigationScreen> {
  final List<Widget> _screens = const [
    LandingChecklistScreen(),
    GuidesScreen(),
    EmploymentHubScreen(),
    RegionalWorkScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Lanzar pop-up de fechas si no lo ha completado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showVisaDatesSurveyDialogIfNeeded(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(phase2NavigationProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';

    // Clamp currentTabIndex to max 3
    final activeIndex = navState.currentTabIndex.clamp(0, _screens.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: activeIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: CupertinoIcons.compass,
                  activeIcon: CupertinoIcons.compass_fill,
                  label: isEn ? 'Arrival' : 'Aterrizaje',
                ),
                _buildNavItem(
                  index: 1,
                  icon: CupertinoIcons.book,
                  activeIcon: CupertinoIcons.book_fill,
                  label: isEn ? 'Guides' : 'Guías',
                ),
                _buildNavItem(
                  index: 2,
                  icon: CupertinoIcons.briefcase,
                  activeIcon: CupertinoIcons.briefcase_fill,
                  label: isEn ? 'Jobs' : 'Empleo',
                ),
                _buildNavItem(
                  index: 3,
                  icon: CupertinoIcons.calendar_badge_plus,
                  activeIcon: CupertinoIcons.calendar_badge_plus,
                  label: isEn ? '88 Days' : '88 Días',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final navNotifier = ref.read(phase2NavigationProvider.notifier);
    final isSelected = ref.watch(phase2NavigationProvider).currentTabIndex == index;
    final color = isSelected ? AppColors.secondary : AppColors.textMuted;

    return GestureDetector(
      onTap: () => navNotifier.setTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 14 : 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 21),
            if (isSelected) ...[
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
