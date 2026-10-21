import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/news_notifications_provider.dart';
import '../../providers/user_provider.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    final isEn = currentLocale.languageCode == 'en';
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.settingsLanguage,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _LanguageTile(
            title: l10n.settingsLanguageSpanish,
            isSelected: currentLocale.languageCode == 'es',
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('es'));
            },
          ),
          const SizedBox(height: 8),
          _LanguageTile(
            title: l10n.settingsLanguageEnglish,
            isSelected: currentLocale.languageCode == 'en',
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('en'));
            },
          ),
          const SizedBox(height: 32),
          Text(
            l10n.settingsNotifications,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final newsEnabled = ref.watch(newsNotificationsProvider);
              return SwitchListTile.adaptive(
                title: Text(l10n.settingsNewsNotifs),
                value: newsEnabled,
                activeColor: AppColors.primary,
                tileColor: AppColors.surface,
                onChanged: (bool value) {
                  ref.read(newsNotificationsProvider.notifier).toggle(value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            isEn ? 'App Phase' : 'Fase de la aplicación',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: AppColors.surface,
            title: Text(
              isEn ? 'Switch to Phase 2 (I got my visa!)' : 'Pasar a la Fase 2 (¡Ya tengo mi visado!)',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: Text(
              isEn
                  ? 'Unlock Arrival Checklist, Guides, 88-Day Validator, Pay Calculator & Aussie CV'
                  : 'Desbloquea Checklist de Aterrizaje, Guías en Australia, 88 Días, Sueldo y CV',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            trailing: const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary, size: 20),
            onTap: () => _confirmSwitchToPhase2(context, ref, profile, isEn),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.settingsLegal,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: AppColors.surface,
            title: Text(l10n.settingsPrivacyPolicy),
            trailing: const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary, size: 20),
            onTap: () => _launchUrl('https://ozvisa-alert-prod.web.app/privacy.html'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: AppColors.surface,
            title: Text(l10n.settingsTerms),
            trailing: const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary, size: 20),
            onTap: () => _launchUrl('https://ozvisa-alert-prod.web.app/terms.html'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              ref.invalidate(userProfileProvider);
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
            child: Text(
              l10n.settingsLogout,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return CupertinoAlertDialog(
                    title: Text(l10n.settingsDeleteAccountConfirmTitle),
                    content: Text(l10n.settingsDeleteAccountConfirmMessage),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(l10n.settingsDeleteAccountCancelButton),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () async {
                          Navigator.of(dialogContext).pop(); // Cierra el dialog
                          try {
                            await ref.read(authControllerProvider.notifier).deleteAccount();
                            ref.invalidate(userProfileProvider);
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                            }
                          } catch (e) {
                            debugPrint('Error borrando cuenta: $e');
                          }
                        },
                        child: Text(l10n.settingsDeleteAccountConfirmButton),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: Colors.redAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
              ),
            ),
            child: Text(
              l10n.settingsDeleteAccount,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSwitchToPhase2(BuildContext context, WidgetRef ref, dynamic profile, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEn ? 'Switch to Phase 2?' : '¿Pasar a la Fase 2?'),
        content: Text(
          isEn
              ? 'You will access the Australia mode (Arrival Checklist, Guides, 88-Day Validator, Pay Calculator & Aussie CV). You can return to Phase 1 anytime.'
              : 'Activarás el modo Australia (Checklist de Aterrizaje, Guías, Validador de 88 Días, Sueldo y CV). Podrás volver a la Fase 1 en cualquier momento.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEn ? 'Cancel' : 'Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.of(context).maybePop();
              if (profile != null) {
                await ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(currentPhase: 2));
              }
              NotificationService().syncPassportSubscriptions([]);
              NotificationService().syncPhaseNewsSubscription(2);
            },
            child: Text(
              isEn ? 'Enter Phase 2' : 'Entrar a Fase 2',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(CupertinoIcons.checkmark_alt, color: AppColors.primary)
          : null,
    );
  }
}
