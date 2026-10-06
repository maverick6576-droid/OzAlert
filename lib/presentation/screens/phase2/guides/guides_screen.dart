import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/affiliate_link_service.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../providers/locale_provider.dart';
import '../../../../domain/models/phase2/affiliate_partner.dart';
import '../../../widgets/phase2/premium_feature_gate.dart';

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  String _selectedCategory = 'banking';

  final List<Map<String, String>> _categories = const [
    {'id': 'banking', 'label': '🏦 Bancos', 'labelEn': '🏦 Banking'},
    {'id': 'telecom', 'label': '📱 SIM / Red', 'labelEn': '📱 SIM / Mobile'},
    {'id': 'insurance', 'label': '🏥 Seguros', 'labelEn': '🏥 Insurance'},
    {'id': 'housing', 'label': '🏠 Alquiler', 'labelEn': '🏠 Housing'},
  ];

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(phase2NavigationProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';

    // Si viene redirigido con una categoría activa desde Aterrizaje
    if (navState.activeGuideCategory != null && navState.activeGuideCategory != _selectedCategory) {
      _selectedCategory = navState.activeGuideCategory!;
    }

    final partnersAsync = ref.watch(affiliateCategoryProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isEn ? 'Directory & Guides' : 'Guías & Comparativas',
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Banner de retorno al checklist si venimos de un Smart Link
          if (navState.activeGuideCategory != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: InkWell(
                onTap: () => ref.read(phase2NavigationProvider.notifier).returnToLanding(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.arrow_left, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        isEn ? 'Return to checklist to mark step done' : 'Volver al checklist para marcar la tarea',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Pestañas horizontales de categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _categories.map((c) {
                final isSelected = c['id'] == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      isEn ? c['labelEn']! : c['label']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = c['id']!);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Listado dinámico de partners y guías
          Expanded(
            child: partnersAsync.when(
              data: (partners) {
                if (partners.isEmpty) {
                  return Center(
                    child: Text(
                      isEn ? 'No partners found for this category' : 'No hay información disponible',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    ...partners.map((p) => _buildPartnerCard(p, isEn)),
                    const SizedBox(height: 16),

                    // Bloque Premium: Secret Hacks
                    PremiumFeatureGate(
                      featureTitle: isEn ? 'Tax Return Secrets' : 'Secret Hacks Fiscales',
                      featureBenefit: isEn
                          ? 'Deduct work boots, RSA courses and gear on your ATO tax return to get up to \$1,000 AUD refund.'
                          : 'Aprende a deducir botas de seguridad, cursos RSA y ropa de trabajo en la ATO para recuperar hasta \$1.000 AUD.',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_rounded, color: AppColors.warning),
                                const SizedBox(width: 8),
                                Text(
                                  isEn ? 'Pro Tax Deductions Guide' : 'Guía Pro de Deducciones Fiscales',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEn
                                  ? 'How to claim back expenses from your farm, hospitality or construction jobs at end of financial year.'
                                  : 'Cómo desgravar gastos de herramientas, visados y cursos de formación en la declaración de impuestos.',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(AffiliatePartner partner, bool isEn) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isEn ? partner.badgeTextEn : partner.badgeText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              partner.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),

            Text(
              isEn ? partner.descriptionEn : partner.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),

            if (partner.promoCode != null && partner.promoCode!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.tag_fill, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Código: ${partner.promoCode}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 16),
                label: Text(
                  isEn ? 'Open Official Link' : 'Ir a la Web Oficial',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  AffiliateLinkService.openPartnerLink(
                    context,
                    partner,
                    languageCode: isEn ? 'en' : 'es',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
