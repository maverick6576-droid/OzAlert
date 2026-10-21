import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';
import 'onboarding_screen.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = (locale?.languageCode ?? Localizations.localeOf(context).languageCode) == 'en';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra Superior con Logo y Selector de Idioma (ES / EN)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('🦘', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'OzAlert',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Selector rápido de idioma
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLangPill(
                          label: 'ES',
                          isSelected: !isEn,
                          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('es')),
                        ),
                        _buildLangPill(
                          label: 'EN',
                          isSelected: isEn,
                          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Cuerpo Scrollable con el Hero y los 5 Pilares de Valor de la App
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chip de bienvenida
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        isEn ? '🇦🇺 YOUR ALL-IN-ONE AUSTRALIAN COMPANION' : '🇦🇺 TU COPILOTO INTEGRAL PARA AUSTRALIA',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ).animate().fadeIn(duration: 350.ms),

                    const SizedBox(height: 10),

                    // Título principal renovado
                    Text(
                      l10n.welcomeTitle,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideY(begin: -0.1, end: 0),

                    const SizedBox(height: 10),

                    // Subtítulo con propuesta de valor integral
                    Text(
                      l10n.welcomeSubtitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 18),

                    // Título de la sección de funcionalidades
                    Text(
                      isEn ? 'Everything OzAlert does for you:' : 'Todo lo que OzAlert hace por ti:',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 5 Tarjetas Pilares de Valor
                    _buildFeatureCard(
                      icon: CupertinoIcons.bell_fill,
                      iconColor: AppColors.primary,
                      badge: isEn ? '24/7 RADAR' : 'RADAR 24/7',
                      badgeColor: AppColors.primary,
                      title: isEn ? 'Instant Visa Opening Alerts' : 'Alertas de Visas al Instante',
                      description: l10n.welcomeBullet1,
                      delay: 350,
                    ),
                    _buildFeatureCard(
                      icon: CupertinoIcons.compass_fill,
                      iconColor: AppColors.secondary,
                      badge: isEn ? 'CHECKLIST' : 'CHECKLIST',
                      badgeColor: AppColors.secondary,
                      title: isEn ? 'Arrival & First Days Roadmap' : 'Aterrizaje & Primeros Días',
                      description: l10n.welcomeBullet2,
                      delay: 450,
                    ),
                    _buildFeatureCard(
                      icon: CupertinoIcons.briefcase_fill,
                      iconColor: const Color(0xFF2563EB),
                      badge: isEn ? 'JOBS & PDF' : 'EMPLEO & PDF',
                      badgeColor: const Color(0xFF2563EB),
                      title: isEn ? 'Australian CV & Fair Work Awards' : 'CV Australiano & Ley Fair Work',
                      description: l10n.welcomeBullet3,
                      delay: 550,
                    ),
                    _buildFeatureCard(
                      icon: CupertinoIcons.calendar_badge_plus,
                      iconColor: const Color(0xFFD97706),
                      badge: isEn ? '88 & 179 DAYS' : '88 & 179 DÍAS',
                      badgeColor: const Color(0xFFD97706),
                      title: isEn ? 'Regional Days & Form 1263 Sign' : 'Días Regionales & Form 1263',
                      description: l10n.welcomeBullet4,
                      delay: 650,
                    ),
                    _buildFeatureCard(
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      iconColor: const Color(0xFF059669),
                      badge: isEn ? 'TAX & MONEY' : 'FISCAL & AHORRO',
                      badgeColor: const Color(0xFF059669),
                      title: isEn ? 'Tax Return, Medicare & DASP' : 'Tax Return, Medicare 2% & DASP',
                      description: l10n.welcomeBullet5,
                      delay: 750,
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // 3. Footer Fijo e Inamovible (NUNCA se oculta, CERO overflow, CERO desplazamiento forzado)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.8), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.welcomeButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(CupertinoIcons.arrow_right, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEn ? 'Official data & Australian regulations 🦘' : 'Datos oficiales y normativa australiana 🦘',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String badge,
    required Color badgeColor,
    required String title,
    required String description,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildLangPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
