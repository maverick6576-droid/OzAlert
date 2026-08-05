import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String _selectedLanguage = 'es';
  final List<String> _selectedPassports = [];

  // Lista de 30 países comunes para Work & Holiday o turismo en Australia
  final List<String> _countries = [
    'España', 'Chile', 'Perú', 'Argentina', 'Uruguay', 'Ecuador',
    'México', 'Colombia', 'Brasil', 'Portugal', 'Italia', 'Francia',
    'Alemania', 'Reino Unido', 'Irlanda', 'Estados Unidos', 'Canadá',
    'Japón', 'Corea del Sur', 'Taiwán', 'Hong Kong', 'Singapur',
    'Malasia', 'Indonesia', 'Tailandia', 'Vietnam', 'Filipinas',
    'Nueva Zelanda', 'Sudáfrica', 'Otros'
  ];

  void _togglePassport(String country) {
    setState(() {
      if (_selectedPassports.contains(country)) {
        _selectedPassports.remove(country);
      } else {
        _selectedPassports.add(country);
      }
    });
  }

  void _savePreferences() {
    if (_selectedPassports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona al menos un pasaporte')),
      );
      return;
    }
    
    ref.read(onboardingControllerProvider.notifier).completeOnboarding(
      _selectedLanguage,
      _selectedPassports,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(onboardingControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personaliza tu Radar',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  const Text(
                    'Configura tu perfil para recibir notificaciones de las visas que encajen con tu pasaporte.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0),
                ],
              ),
            ),
            
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Sección Idioma
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Idioma Preferido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _LanguageOption(
                                  title: 'Español',
                                  isSelected: _selectedLanguage == 'es',
                                  onTap: () => setState(() => _selectedLanguage = 'es'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _LanguageOption(
                                  title: 'English',
                                  isSelected: _selectedLanguage == 'en',
                                  onTap: () => setState(() => _selectedLanguage = 'en'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                    ),
                  ),
                  
                  // Título Pasaportes
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                      child: const Text(
                        'Selecciona tus Pasaportes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ),
                  ),

                  // Cuadrícula de Pasaportes
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 160,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final country = _countries[index];
                          final isSelected = _selectedPassports.contains(country);
                          return _PassportChip(
                            title: country,
                            isSelected: isSelected,
                            onTap: () => _togglePassport(country),
                          );
                        },
                        childCount: _countries.length,
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),

            // Footer con el Botón
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  )
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Text(
                          'Siguiente paso',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ).animate().slideY(begin: 1.0, end: 0, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PassportChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PassportChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 150.ms,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(CupertinoIcons.checkmark_alt, size: 16, color: AppColors.secondary),
              ),
          ],
        ),
      ),
    );
  }
}
