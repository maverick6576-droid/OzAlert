import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class LiveRadarBanner extends StatefulWidget {
  const LiveRadarBanner({super.key});

  @override
  State<LiveRadarBanner> createState() => _LiveRadarBannerState();
}

class _LiveRadarBannerState extends State<LiveRadarBanner> {
  int _secondsAgo = 14; // Comienza en 14 segundos como en la especificación
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsAgo++;
          if (_secondsAgo >= 60) {
            _secondsAgo = 0; // Reiniciar tras cada comprobación de ciclo
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.statusOpen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.statusOpen.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Punto verde parpadeante (Live Radar)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.statusOpen,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scaleXY(begin: 0.8, end: 1.3, duration: 800.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Servidores rastreando la web oficial de Inmigración de Australia',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              'Última comprobación: hace $_secondsAgo segundos (Frecuencia: cada 60 seg)',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
