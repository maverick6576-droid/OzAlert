import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/passport_provider.dart';
import '../../providers/repository_providers.dart';
import '../../domain/models/country_config.dart';
import 'package:url_launcher/url_launcher.dart';

class VisaStatusCard extends ConsumerWidget {
  final CountryConfig country;
  
  const VisaStatusCard({super.key, required this.country});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(visaStatusStreamProvider(country.code));

    final status = statusAsync.when(
      data: (val) => val,
      loading: () => country.defaultStatus,
      error: (_, __) => country.defaultStatus,
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
      if (isOpen) return '¡ABIERTA!';
      if (isPaused) return 'PAUSADA';
      return 'CERRADA';
    }

    String getSubtitle() {
      if (isOpen) return 'Visas disponibles. ¡Inicia la expedición!';
      if (isPaused) return 'A la espera. Procesamiento temporalmente detenido.';
      return 'Campamento cerrado. 0 plazas actualmente.';
    }

    IconData getIconData() {
      if (isOpen) return CupertinoIcons.location_solid;
      if (isPaused) return CupertinoIcons.pause_solid;
      return CupertinoIcons.xmark_circle_fill;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Concentric ripples for radar aesthetic (Only active if OPEN or scanning)
        if (isOpen) ...[
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.statusOpen.withOpacity(0.5), width: 2),
            ),
          ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 0.9, end: 1.15, duration: 2.seconds).fadeOut(duration: 2.seconds),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.statusOpen.withOpacity(0.3), width: 1),
            ),
          ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 1.0, end: 1.25, duration: 2.seconds).fadeOut(duration: 2.seconds),
        ],

        // Main Card
        GestureDetector(
          onTap: () async {
            if (isOpen) {
              final url = Uri.parse('https://online.immi.gov.au/lusc/login');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir el enlace de InmiAccount.')),
                  );
                }
              }
            }
          },
          child: Container(
            width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: getGradient(),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: getStatusColor().withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: getStatusColor().withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: getStatusColor().withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getIconData(),
                          color: getStatusColor(),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RADAR: ${getTitle()}',
                          style: TextStyle(
                            color: getStatusColor(),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Simular cambio de estado de exploración',
                    onPressed: () {
                      final newStatus = isOpen ? false : true;
                      ref
                          .read(visaRepositoryProvider)
                          .toggleDemoStatus(country.code, newStatus);
                    },
                    icon: Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      color: getStatusColor(),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                getTitle(),
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: getStatusColor().withOpacity(0.6),
                      blurRadius: 15,
                    ),
                  ],
                ),
              )
                  .animate(target: isOpen ? 1 : 0)
                  .shimmer(duration: 1500.ms, color: AppColors.statusOpen),
              const SizedBox(height: 8),
              Text(
                getSubtitle(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isOpen ? Colors.white : Colors.white.withOpacity(0.9),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${country.flagEmoji} Ruta: ${country.name} (Subclase ${country.visaSubclass})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
            ],
          ),
        ),
        
        // Botón Ver Fuente Oficial
        Positioned(
          bottom: -16,
          child: ElevatedButton.icon(
            onPressed: () async {
              final url = Uri.parse('https://immi.homeaffairs.gov.au/what-we-do/whm-program/status-of-country-caps?utm_source=chatgpt.com');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir el enlace.')),
                  );
                }
              }
            },
            icon: const Icon(CupertinoIcons.link, size: 16),
            label: const Text(
              'Ver fuente oficial',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
