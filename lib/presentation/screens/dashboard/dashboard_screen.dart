import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/paywall_provider.dart';
import '../../providers/user_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../widgets/dashboard/live_radar_banner.dart';
import '../../widgets/dashboard/visa_status_card.dart';
import '../../widgets/dashboard/statistics_card.dart';
import '../../widgets/dashboard/community_visa_times_card.dart';
import '../../../../core/services/notification_service.dart';

import '../settings/settings_screen.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';
import '../../../../core/localization/app_strings.dart';
import '../../providers/locale_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});




  void _showDndDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loc.dndDialogTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.dndDialogIntro,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              Text(
                loc.dndDialogIosTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                loc.dndDialogIosSteps,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              Text(
                loc.dndDialogAndroidTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                loc.dndDialogAndroidSteps,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.dndDialogClose,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override

  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(paywallProvider);
    final userProfileState = ref.watch(userProfileProvider);
    final userProfile = userProfileState.value;
    final passports = userProfile?.passports ?? [];
    
    // Convertir los nombres de pasaportes a objetos CountryConfig
    final selectedCountries = passports.map((p) {
      return AppConstants.supportedCountries.firstWhere(
        (c) => c.name == p,
        orElse: () => AppConstants.supportedCountries.first,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/app_icon.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.dashboardTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.gear, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Fondo temático abstracto
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Live Radar Explorer
                const LiveRadarBanner(),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.dndNoticeTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showDndDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Tarjetas de Estado para cada pasaporte seleccionado
                if (selectedCountries.isEmpty)
                  Center(child: Text(AppLocalizations.of(context)!.onboardingErrorEmpty))
                else
                  ...selectedCountries.map((country) => Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: VisaStatusCard(country: country),
                  )),

                // 3. Botón destacado para pasar a la Fase 2 cuando el usuario ya tiene su visado
                _buildPhase2TransitionCard(context, ref),
                const SizedBox(height: 20),

                const StatisticsCard(),
                const SizedBox(height: 12),
                const CommunityVisaTimesCard(),
                const SizedBox(height: 24),

                // 4. Panel de información de seguridad
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.map_pin_ellipse,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.dashboardSafeExpedition,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.dashboardSafeExpeditionDesc,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPhase2ConfirmationDialog(BuildContext context, WidgetRef ref, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.flight_takeoff_rounded, color: AppColors.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.switchToPhase2DialogTitle(lang),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          AppStrings.switchToPhase2DialogContent(lang),
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancelButton(lang),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final profile = ref.read(userProfileProvider).value;
              if (profile != null) {
                await ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(currentPhase: 2));
              }
              // Desuscribir tópicos de Fase 1 en segundo plano sin bloquear la transición de pantalla
              NotificationService().syncPassportSubscriptions([]);
            },
            child: Text(
              AppStrings.enterPhase2Button(lang),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhase2TransitionCard(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final lang = locale?.languageCode ?? Localizations.localeOf(context).languageCode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.16),
            AppColors.primary.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPhase2ConfirmationDialog(context, ref, lang),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            AppStrings.dashboardPhase2NextStep(lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Text('🦘🇦🇺', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.dashboardAlreadyGotVisa(lang),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17.5,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.switchToPhase2Subtitle(lang),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showPhase2ConfirmationDialog(context, ref, lang),
                    icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                    label: Text(
                      AppStrings.dashboardTapToEnterPhase2(lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
