import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import 'onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Fondo corporativo oscuro/llamativo
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Icono animado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.bolt_fill,
                  size: 48,
                  color: AppColors.secondary,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              // Título con gancho
              const Text(
                'Las visas de\nAustralia vuelan\nen minutos.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
              
              const SizedBox(height: 24),
              
              // Explicación de valor
              const Text(
                'Cada año, miles de personas se quedan fuera por no enterarse a tiempo de la apertura de cupos. Nuestro sistema rastrea las fuentes oficiales 24/7 y te avisa al instante para que seas el primero en aplicar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
              
              const SizedBox(height: 32),
              
              // Bullet points de urgencia
              _buildBullet(
                icon: CupertinoIcons.bell_solid,
                text: 'Notificaciones instantáneas reales',
                delay: 600,
              ),
              _buildBullet(
                icon: CupertinoIcons.time_solid,
                text: 'Gana ventaja sobre otros aplicantes',
                delay: 700,
              ),
              _buildBullet(
                icon: CupertinoIcons.shield_fill,
                text: 'Fuentes oficiales del gobierno (Inmigración)',
                delay: 800,
              ),
              
              const Spacer(),
              
              // Botón de acción principal
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const OnboardingScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Configurar mi Radar ahora',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().slideY(begin: 1.0, end: 0, delay: 1000.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet({required IconData icon, required String text, required int delay}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: -0.1, end: 0);
  }
}
