import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/passport_provider.dart';
import '../../../../domain/models/country_config.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(visaStatusStreamProvider(widget.country.code));

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
        if (isOpen || _isScanning) ...[
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _isScanning ? Colors.white30 : AppColors.statusOpen.withOpacity(0.5), width: 2),
            ),
          ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 0.9, end: 1.10, duration: 1500.ms).fadeOut(duration: 1500.ms),
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _isScanning ? Colors.white24 : AppColors.statusOpen.withOpacity(0.3), width: 1),
            ),
          ).animate(onPlay: (c) => c.repeat()).scaleXY(begin: 1.0, end: 1.20, duration: 1500.ms).fadeOut(duration: 1500.ms),
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
                // 1. Top Bar: Fuente Oficial & Refresh Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
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
                      icon: const Icon(CupertinoIcons.link, size: 14),
                      label: const Text(
                        'Ver fuente oficial',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
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

                // 3. TITLE (ABIERTA/PAUSADA/CERRADA)
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

                // 4. SUBTITLE
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

                // 5. RUTA (COUNTRY)
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
                        '${widget.country.flagEmoji} Ruta: ${widget.country.name} (Subclase ${widget.country.visaSubclass})',
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
          ).animate(target: _isScanning ? 1 : 0).fade(end: 0.7, duration: 400.ms).shimmer(duration: 1500.ms, color: Colors.white30),
        ),
      ],
    );
  }
}
