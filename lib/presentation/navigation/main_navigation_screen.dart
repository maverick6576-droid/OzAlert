import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/checklist/checklist_screen.dart';
import '../screens/news/news_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(), // Pantalla 1: Dashboard Principal + Radar Live + Probar Alerta + Paywall
    ChecklistScreen(), // Pantalla 2: Checklist de Requisitos interactivo
    NewsScreen(), // Pantalla 3: Avisos Oficiales, Guías útiles, Divisas y Seguros
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: CupertinoIcons.dot_radiowaves_left_right,
                  activeIcon: CupertinoIcons.dot_radiowaves_left_right,
                  label: 'Live Radar',
                ),
                _buildNavItem(
                  index: 1,
                  icon: CupertinoIcons.checkmark_seal,
                  activeIcon: CupertinoIcons.checkmark_seal_fill,
                  label: 'Requisitos',
                ),
                _buildNavItem(
                  index: 2,
                  icon: CupertinoIcons.news,
                  activeIcon: CupertinoIcons.news_solid,
                  label: 'Noticias',
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
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.statusOpen : AppColors.textMuted;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.statusOpen.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border:
              isSelected
                  ? Border.all(
                    color: AppColors.statusOpen.withOpacity(0.4),
                    width: 1,
                  )
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 22),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
