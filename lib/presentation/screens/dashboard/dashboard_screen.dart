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
                color: AppColors.primary.withOpacity(0.05),
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
                color: AppColors.secondary.withOpacity(0.05),
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
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: VisaStatusCard(country: country),
                  )),

                const SizedBox(height: 10),
                const StatisticsCard(),
                const SizedBox(height: 12),
                const CommunityVisaTimesCard(),
                const SizedBox(height: 16),
                _buildPhase2TransitionCard(context, ref),
                const SizedBox(height: 24),

                // 4. Panel de información de seguridad
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
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

  Widget _buildPhase2TransitionCard(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.flight_takeoff_rounded, color: AppColors.secondary),
                SizedBox(width: 10),
                Expanded(child: Text('¡Ya tengo mi visado! 🎉', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ],
            ),
            content: const Text(
              'Al pasar a la Fase 2, accederás a la guía de llegada a Australia, generador de CV australiano, calculadora de salarios Fair Work y validador de los 88 días. Además, apagaremos las alarmas push de apertura de cupos para no molestarte.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await NotificationService().syncPassportSubscriptions([]);
                  final profile = ref.read(userProfileProvider).value;
                  if (profile != null) {
                    await ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(currentPhase: 2));
                  }
                },
                child: const Text('Entrar a la Fase 2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Ya te concedieron el visado? ✈️',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pasa a la Fase 2: Guía de llegada, CV australiano y 88 días.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: AppColors.secondary, size: 18),
          ],
        ),
      ),
    );
  }
}
