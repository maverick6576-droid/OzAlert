import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/passport_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/user_provider.dart';
import '../../../../core/constants/app_constants.dart';

class TestAlertButton extends ConsumerStatefulWidget {
  const TestAlertButton({super.key});

  @override
  ConsumerState<TestAlertButton> createState() => _TestAlertButtonState();
}

class _TestAlertButtonState extends ConsumerState<TestAlertButton> {
  bool _isLoading = false;

  Future<void> _handleTestAlert() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final userProfileState = ref.read(userProfileProvider);
    final userProfile = userProfileState.value;
    final passports = userProfile?.passports ?? [];
    
    final selectedCountryNames = passports.isNotEmpty ? passports.join(' y ') : 'España';
    final firstCountryName = passports.isNotEmpty ? passports.first : 'España';
    
    final selectedCountry = AppConstants.supportedCountries.firstWhere(
      (c) => c.name == firstCountryName,
      orElse: () => AppConstants.supportedCountries.first,
    );

    final notificationService = ref.read(notificationServiceProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.bell_fill, color: AppColors.statusOpen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '⚡ Enviando alerta de prueba para $selectedCountryNames... Llegará en 2 segundos.',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    await notificationService.sendTestAlert(
      countryName: selectedCountryNames,
      countryCode: selectedCountry.code,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTestAlert,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(
                      CupertinoIcons.bell_circle_fill,
                      color: Colors.white,
                      size: 24,
                    ),
                const SizedBox(width: 12),
                const Text(
                  'Probar Alerta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(delay: 200.ms, duration: 300.ms);
  }
}
