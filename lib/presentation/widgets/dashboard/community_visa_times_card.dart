import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/phase2/phase2_providers.dart';

final communityStatsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, countryCode) async {
  final repo = ref.watch(visaStatsRepositoryProvider);
  return repo.getCommunityVisaStats(countryCode);
});

class CommunityVisaTimesCard extends ConsumerWidget {
  const CommunityVisaTimesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final country = (profile?.passports.isNotEmpty ?? false) ? profile!.passports.first : 'ES';

    final statsAsync = ref.watch(communityStatsProvider(country));

    return statsAsync.when(
      data: (stats) {
        if (stats == null || stats['count'] == 0) {
          return const SizedBox.shrink(); // No mostrar si no hay datos comunitarios aún
        }

        final avg = stats['averageDays'];
        final min = stats['minDays'];
        final max = stats['maxDays'];
        final count = stats['count'];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.timer, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tiempos Reales de Concesión ($country)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Media de espera: $avg días (Mín: $min d | Máx: $max d)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Basado en $count visados reportados por la comunidad de OzAlert en los últimos 60 días.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
