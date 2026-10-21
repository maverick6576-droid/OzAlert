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
    final lang = locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra Superior con Logo y Selector de Idioma (5 Idiomas)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Text('🦘', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'OzAlert',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Selector rápido de idioma (5 idiomas disponibles con escala automática en pantallas estrechas)
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.all(2),
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
                                isSelected: (locale?.languageCode ?? 'es') == 'es',
                                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('es')),
                              ),
                              _buildLangPill(
                                label: 'EN',
                                isSelected: (locale?.languageCode ?? 'es') == 'en',
                                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                              ),
                              _buildLangPill(
                                label: 'FR',
                                isSelected: (locale?.languageCode ?? 'es') == 'fr',
                                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('fr')),
                              ),
                              _buildLangPill(
                                label: 'IT',
                                isSelected: (locale?.languageCode ?? 'es') == 'it',
                                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('it')),
                              ),
                              _buildLangPill(
                                label: 'ZH',
                                isSelected: (locale?.languageCode ?? 'es') == 'zh',
                                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('zh')),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                        _getHeroBadge(lang),
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
                      _getSectionHeader(lang),
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
                      badge: _getCardBadge(lang, 1),
                      badgeColor: AppColors.primary,
                      title: _getCardTitle(lang, 1),
                      description: l10n.welcomeBullet1,
                      delay: 350,
                    ),
                    _buildFeatureCard(
                      icon: CupertinoIcons.compass_fill,
                      iconColor: AppColors.secondary,
                      badge: _getCardBadge(lang, 2),
                      badgeColor: AppColors.secondary,
                      title: _getCardTitle(lang, 2),
                      description: l10n.welcomeBullet2,
                      delay: 450,
                    ),
                    _buildFeatureCard(
                      icon: CupertinoIcons.briefcase_fill,
                      iconColor: const Color(0xFF2563EB),
                      badge: _getCardBadge(lang, 3),
                      badgeColor: const Color(0xFF2563EB),
                      title: _getCardTitle(lang, 3),
                      description: l10n.welcomeBullet3,
                      delay: 550,
                    ),
                    _buildFeatureCard(
                      icon: CupertinoIcons.calendar_badge_plus,
                      iconColor: const Color(0xFFD97706),
                      badge: _getCardBadge(lang, 4),
                      badgeColor: const Color(0xFFD97706),
                      title: _getCardTitle(lang, 4),
                      description: l10n.welcomeBullet4,
                      delay: 650,
                    ),
                    _buildFeatureCard(
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      iconColor: const Color(0xFF059669),
                      badge: _getCardBadge(lang, 5),
                      badgeColor: const Color(0xFF059669),
                      title: _getCardTitle(lang, 5),
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
                    _getFooterNote(lang),
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
        padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _getHeroBadge(String lang) {
    switch (lang) {
      case 'en':
        return '🇦🇺 YOUR ALL-IN-ONE AUSTRALIAN COMPANION';
      case 'fr':
        return '🇦🇺 VOTRE COPILOTE TOUT-EN-UN EN AUSTRALIE';
      case 'it':
        return '🇦🇺 IL TUO COPILOTA COMPLETO PER L’AUSTRALIA';
      case 'zh':
        return '🇦🇺 您的全方位澳大利亚指南与助手';
      case 'es':
      default:
        return '🇦🇺 TU COPILOTO INTEGRAL PARA AUSTRALIA';
    }
  }

  String _getSectionHeader(String lang) {
    switch (lang) {
      case 'en':
        return 'Everything OzAlert does for you:';
      case 'fr':
        return 'Tout ce qu’OzAlert fait pour vous :';
      case 'it':
        return 'Tutto ciò che OzAlert fa per te:';
      case 'zh':
        return 'OzAlert 为您提供的一切：';
      case 'es':
      default:
        return 'Todo lo que OzAlert hace por ti:';
    }
  }

  String _getCardBadge(String lang, int cardIndex) {
    switch (cardIndex) {
      case 1:
        return lang == 'zh' ? '全天候雷达' : (lang == 'en' ? '24/7 RADAR' : 'RADAR 24/7');
      case 2:
        return lang == 'zh' ? '入境清单' : 'CHECKLIST';
      case 3:
        switch (lang) {
          case 'en':
            return 'JOBS & PDF';
          case 'fr':
            return 'EMPLOI & PDF';
          case 'it':
            return 'LAVORO & PDF';
          case 'zh':
            return '求职与简历';
          case 'es':
          default:
            return 'EMPLEO & PDF';
        }
      case 4:
        switch (lang) {
          case 'en':
            return '88 & 179 DAYS';
          case 'fr':
            return '88 & 179 JOURS';
          case 'it':
            return '88 & 179 GIORNI';
          case 'zh':
            return '88天与179天';
          case 'es':
          default:
            return '88 & 179 DÍAS';
        }
      case 5:
        switch (lang) {
          case 'en':
            return 'TAX & MONEY';
          case 'fr':
            return 'FISCALITÉ & ÉPARGNE';
          case 'it':
            return 'TASSE & RISPARMIO';
          case 'zh':
            return '税务与退税';
          case 'es':
          default:
            return 'FISCAL & AHORRO';
        }
      default:
        return '';
    }
  }

  String _getCardTitle(String lang, int cardIndex) {
    switch (cardIndex) {
      case 1:
        switch (lang) {
          case 'en':
            return 'Instant Visa Opening Alerts';
          case 'fr':
            return 'Alertes d’Ouverture de Visa';
          case 'it':
            return 'Avvisi Apertura Visto';
          case 'zh':
            return '即时签证开放提醒';
          case 'es':
          default:
            return 'Alertas de Visas al Instante';
        }
      case 2:
        switch (lang) {
          case 'en':
            return 'Arrival & First Days Roadmap';
          case 'fr':
            return 'Arrivée & Premiers Jours';
          case 'it':
            return 'Arrivo & Primi Giorni';
          case 'zh':
            return '入境与抵澳初期路线图';
          case 'es':
          default:
            return 'Aterrizaje & Primeros Días';
        }
      case 3:
        switch (lang) {
          case 'en':
            return 'Australian CV & Fair Work Awards';
          case 'fr':
            return 'CV Australien & Barèmes Fair Work';
          case 'it':
            return 'CV Australiano & Tabelle Fair Work';
          case 'zh':
            return '澳洲标准简历与劳工法计算';
          case 'es':
          default:
            return 'CV Australiano & Ley Fair Work';
        }
      case 4:
        switch (lang) {
          case 'en':
            return 'Regional Days & Form 1263 Sign';
          case 'fr':
            return 'Jours Régionaux & Formulaire 1263';
          case 'it':
            return 'Giorni Regionali & Modulo 1263';
          case 'zh':
            return '二签三签天数与 1263 表格签署';
          case 'es':
          default:
            return 'Días Regionales & Form 1263';
        }
      case 5:
        switch (lang) {
          case 'en':
          case 'fr':
          case 'it':
            return 'Tax Return, Medicare & DASP';
          case 'zh':
            return '报税退税、Medicare 豁免与退休金';
          case 'es':
          default:
            return 'Tax Return, Medicare 2% & DASP';
        }
      default:
        return '';
    }
  }

  String _getFooterNote(String lang) {
    switch (lang) {
      case 'en':
        return 'Official data & Australian regulations 🦘';
      case 'fr':
        return 'Données officielles et réglementations australiennes 🦘';
      case 'it':
        return 'Dati ufficiali e normative australiane 🦘';
      case 'zh':
        return '官方数据与澳大利亚移民法规 🦘';
      case 'es':
      default:
        return 'Datos oficiales y normativa australiana 🦘';
    }
  }
}
