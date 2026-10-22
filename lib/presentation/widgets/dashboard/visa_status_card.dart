import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/passport_provider.dart';
import '../../providers/paywall_provider.dart';
import '../../providers/user_provider.dart';
import '../../../../domain/models/country_config.dart';
import '../phase2/paywall_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';
import '../../../../core/localization/app_strings.dart';
import '../../providers/locale_provider.dart';

class VisaStatusCard extends ConsumerStatefulWidget {
  final CountryConfig country;
  
  const VisaStatusCard({super.key, required this.country});

  @override
  ConsumerState<VisaStatusCard> createState() => _VisaStatusCardState();
}

class _VisaStatusCardState extends ConsumerState<VisaStatusCard> {
  bool _isScanning = false;

  void _simulateScan() {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  void _openProPaywall(BuildContext context, String lang) {
    showPhase2PaywallBottomSheet(
      context: context,
      featureTitle: AppStrings.instantVisaAlertTitle(lang),
      featureBenefit: AppStrings.instantVisaAlertBenefit(lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(visaStatusStreamProvider(widget.country.code));
    final isPaywallSubscribed = ref.watch(paywallProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final isPremium = isPaywallSubscribed || (userProfile?.isPremium ?? false);
    final locale = ref.watch(localeProvider);
    final lang = locale?.languageCode ?? Localizations.localeOf(context).languageCode;

    final status = statusAsync.when(
      data: (val) => val,
      loading: () => widget.country.defaultStatus,
      error: (_, __) => widget.country.defaultStatus,
    );

    final isOpen = status == 'OPEN';
    final isPaused = status == 'PAUSED';

    LinearGradient getGradient() {
      if (isOpen) return AppColors.openCardGradient;
      if (isPaused) return AppColors.pausedCardGradient;
      return AppColors.closedCardGradient;
    }

    Color getStatusColor() {
      if (isOpen) return AppColors.statusOpen;
      if (isPaused) return AppColors.statusPaused;
      return AppColors.statusClosed;
    }

    String getTitle() {
      if (isOpen) return AppLocalizations.of(context)!.visaStatusOpen;
      if (isPaused) return AppLocalizations.of(context)!.visaStatusPaused;
      return AppLocalizations.of(context)!.visaStatusClosed;
    }

    String getStatusSubtitle(BuildContext context) {
      if (isOpen) return AppLocalizations.of(context)!.visaStatusOpenDesc;
      if (isPaused) return AppLocalizations.of(context)!.visaStatusPausedDesc;
      return AppLocalizations.of(context)!.visaStatusClosedDesc;
    }


    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Concentric ripples for radar aesthetic (Only active if OPEN or scanning)
        if (isOpen || _isScanning) ...[
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _isScanning ? Colors.white30 : AppColors.statusOpen.withValues(alpha: 0.5), width: 2),
            ),
          ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 0.9, end: 1.10, duration: 1500.ms).fadeOut(duration: 1500.ms),
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _isScanning ? Colors.white24 : AppColors.statusOpen.withValues(alpha: 0.3), width: 1),
            ),
          ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 1.0, end: 1.20, duration: 1500.ms).fadeOut(duration: 1500.ms),
        ],

        // Main Card
        GestureDetector(
          onTap: () async {
            if (isOpen) {
              final uri = Uri.parse('https://online.immi.gov.au/lusc/login');
              if (!await launchUrl(uri)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorOpeningLink)),
                  );
                }
              }
            } else if (!isPremium) {
              _openProPaywall(context, lang);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: getGradient(),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: getStatusColor().withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: getStatusColor().withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar: Fuente Oficial & Refresh Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse('https://immi.homeaffairs.gov.au/what-we-do/whm-program/status-of-country-caps');
                          if (!await launchUrl(uri)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.errorOpeningLink)),
                              );
                            }
                          }
                        },
                        icon: const Icon(CupertinoIcons.barcode_viewfinder, size: 20),
                        label: Text(
                          AppLocalizations.of(context)!.visaSourceButton,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Escanear radar en vivo',
                      onPressed: _isScanning ? null : _simulateScan,
                      icon: _isScanning
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: getStatusColor(), strokeWidth: 2),
                            )
                          : Icon(
                              CupertinoIcons.arrow_2_circlepath,
                              color: getStatusColor(),
                              size: 24,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. TITLE (ABIERTA/PAUSADA/CERRADA) + Candado en versión gratuita
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Text(
                      getTitle(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: getStatusColor().withValues(alpha: 0.6),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    )
                        .animate(target: isOpen ? 1 : 0)
                        .shimmer(duration: 1500.ms, color: AppColors.statusOpen),
                    if (!isPremium)
                      GestureDetector(
                        onTap: () => _openProPaywall(context, lang),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.amberAccent.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.lock_fill,
                                color: Colors.amberAccent,
                                size: 15,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // 4. SUBTITLE
                Text(
                  getStatusSubtitle(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // 5. RUTA (COUNTRY)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '${widget.country.flagEmoji} Ruta: ${widget.country.getLocalizedName(context)} (Subclase ${widget.country.visaSubclass})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 6. ETIQUETA DE NOTIFICACIÓN DE VISADO ABIERTO (Con candado en parte gratuita para suscribirse a PRO)
                if (!isPremium)
                  GestureDetector(
                    onTap: () => _openProPaywall(context, lang),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amberAccent.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.lock_fill,
                              color: Colors.amberAccent,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.visaOpenNotification(lang),
                                  softWrap: true,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.subscribeProAlert(lang),
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.lock_fill, color: Colors.black87, size: 11),
                                SizedBox(width: 4),
                                Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.bell_fill,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppStrings.visaNotificationActive(lang),
                            softWrap: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PRO ✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ).animate(target: _isScanning ? 1 : 0).fade(end: 0.7, duration: 400.ms).shimmer(duration: 1500.ms, color: Colors.white30),
        ),
      ],
    );
  }
}
