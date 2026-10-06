import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../widgets/phase2/visa_dates_survey_dialog.dart';

class Phase2SettingsScreen extends ConsumerWidget {
  const Phase2SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isEn ? 'Settings' : 'Ajustes',
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Tarjeta de Perfil & Estado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(CupertinoIcons.person_fill, color: AppColors.primary, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Usuario OzAlert',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (profile?.isPremium ?? false) ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (profile?.isPremium ?? false) ? 'PRO ACTIVE' : 'FREE TIER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: (profile?.isPremium ?? false) ? AppColors.secondary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Subclass ${profile?.visaSubclass ?? "462"}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sección de Preferencias
          _buildSectionTitle(isEn ? 'PREFERENCES' : 'PREFERENCIAS'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.cardBorder)),
            child: Column(
              children: [
                // Idioma
                ListTile(
                  leading: const Icon(CupertinoIcons.globe, color: AppColors.secondary),
                  title: Text(isEn ? 'Language' : 'Idioma de la App'),
                  subtitle: Text(isEn ? 'English' : 'Español'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                  onTap: () {
                    final newLocale = isEn ? const Locale('es') : const Locale('en');
                    ref.read(localeProvider.notifier).setLocale(newLocale);
                  },
                ),
                const Divider(height: 1),

                // Subclase de visado
                ListTile(
                  leading: const Icon(CupertinoIcons.doc_plaintext, color: AppColors.primary),
                  title: Text(isEn ? 'Visa Subclass' : 'Subclase de Visado'),
                  subtitle: Text(profile?.visaSubclass == '417' ? 'Subclass 417 (Working Holiday)' : 'Subclass 462 (Work and Holiday)'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                  onTap: () async {
                    if (profile != null) {
                      final newSubclass = profile.visaSubclass == '462' ? '417' : '462';
                      await ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(visaSubclass: newSubclass));
                      ref.invalidate(userProfileProvider);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Encuesta de fechas de visado (si no la completó)
          if (!(profile?.datesSurveyCompleted ?? false)) ...[
            _buildSectionTitle(isEn ? 'COMMUNITY CONTRIBUTION' : 'COLABORACIÓN COMUNITARIA'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.5))),
              color: AppColors.secondary.withValues(alpha: 0.06),
              child: ListTile(
                leading: const Icon(Icons.celebration_rounded, color: AppColors.secondary),
                title: Text(
                  isEn ? 'Record your Visa Dates' : 'Registra tus Fechas de Visado',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  isEn ? 'Share wait times anonymously to help Phase 1 applicants.' : 'Comparte anónimamente cuánto tardaron en dártela para ayudar a los demás.',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                onTap: () => showVisaDatesSurveyDialogIfNeeded(context, ref),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // BOTÓN DE PÁNICO / RETORNO A FASE 1
          _buildSectionTitle(isEn ? 'PHASE SWITCHER' : 'CAMBIO DE FASE'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.cardBorder)),
            child: ListTile(
              leading: const Icon(CupertinoIcons.compass, color: AppColors.primary),
              title: Text(
                isEn ? 'Return to Phase 1 (Visa Radar)' : 'Volver a Fase 1 (Buscador de Visa)',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              subtitle: Text(
                isEn ? 'Monitor open quota spots and push alarms again.' : 'Reactivar el radar de cupos y alertas para familiares o acompañantes.',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(CupertinoIcons.arrow_2_squarepath, color: AppColors.primary),
              onTap: () => _confirmReturnToPhase1(context, ref, profile, isEn),
            ),
          ),
          const SizedBox(height: 16),

          // Cierre de Sesión
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.cardBorder)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.statusClosed),
              title: Text(
                isEn ? 'Log Out' : 'Cerrar Sesión',
                style: const TextStyle(color: AppColors.statusClosed, fontWeight: FontWeight.bold),
              ),
              onTap: () => ref.read(authRepositoryProvider).signOut(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.8),
      ),
    );
  }

  void _confirmReturnToPhase1(BuildContext context, WidgetRef ref, dynamic profile, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEn ? 'Return to Visa Search?' : '¿Volver al Buscador de Visa?'),
        content: Text(
          isEn
              ? 'Your interface will switch back to Phase 1 (Quota Radar). You can return to Phase 2 at any time.'
              : 'Tu pantalla volverá al Radar de cupos de la Fase 1. Podrás volver a la Fase 2 en cualquier momento desde los ajustes.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEn ? 'Cancel' : 'Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (profile != null) {
                await ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(currentPhase: 1));
                ref.invalidate(userProfileProvider);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isEn ? 'Switch to Phase 1' : 'Cambiar a Fase 1'),
          ),
        ],
      ),
    );
  }
}
