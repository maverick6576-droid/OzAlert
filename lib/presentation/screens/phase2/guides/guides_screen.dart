import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/affiliate_link_service.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../providers/locale_provider.dart';
import '../../../../domain/models/phase2/affiliate_partner.dart';
import '../../../../domain/models/phase2/guide_data.dart';
import '../../../widgets/phase2/premium_feature_gate.dart';

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  String _selectedCategory = 'banking';
  int _selectedSubTab = 0; // 0 = Guía Paso a Paso, 1 = Comparativa, 2 = Servicios & Promos

  final List<Map<String, String>> _categories = const [
    {'id': 'banking', 'label': '🏦 Bancos', 'labelEn': '🏦 Banking'},
    {'id': 'telecom', 'label': '📱 SIM & Red', 'labelEn': '📱 Mobile & SIM'},
    {'id': 'insurance', 'label': '🏥 Seguros', 'labelEn': '🏥 Insurance'},
    {'id': 'housing', 'label': '🏠 Alquiler', 'labelEn': '🏠 Housing'},
    {'id': 'tax', 'label': '🧾 Impuestos & TFN', 'labelEn': '🧾 Tax & Super'},
    {'id': 'certifications', 'label': '📜 Cursos & RSA', 'labelEn': '📜 Certificates'},
  ];

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(phase2NavigationProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';

    // Redirección directa desde checklist de Aterrizaje
    if (navState.activeGuideCategory != null && navState.activeGuideCategory != _selectedCategory) {
      _selectedCategory = navState.activeGuideCategory!;
    }

    final guideAsync = ref.watch(guideCategoryProvider(_selectedCategory));
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      if (selected) {
                        setState(() {
                          _selectedCategory = c['id']!;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Sub-tabs segmentadas: Guía Paso a Paso | Comparativa | Servicios & Promos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _buildSubTabItem(index: 0, label: isEn ? '📘 Step Guide' : '📘 Guía Paso a Paso'),
                  _buildSubTabItem(index: 1, label: isEn ? '⚖️ Comparison' : '⚖️ Comparativa'),
                  _buildSubTabItem(index: 2, label: isEn ? '🎁 Services & B2B' : '🎁 Servicios & B2B'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Contenido principal dinámico según la sub-tab activa
          Expanded(
            child: guideAsync.when(
              data: (guide) {
                if (guide == null) {
                  return Center(
                    child: Text(
                      isEn ? 'Information coming soon' : 'Información en preparación',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                if (_selectedSubTab == 0) {
                  return _buildStepsView(guide, isEn);
                } else if (_selectedSubTab == 1) {
                  return _buildComparisonsView(guide, isEn);
                } else {
                  return _buildPartnersView(partnersAsync, isEn);
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem({required int index, required String label}) {
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. VISTA DE GUÍA PASO A PASO ---
  Widget _buildStepsView(CategoryGuide guide, bool isEn) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Cabecera descriptiva de la guía
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn ? guide.titleEn : guide.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                isEn ? guide.subtitleEn : guide.subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Listado de pasos numerados
        ...guide.steps.map((s) => _buildStepCard(s, isEn)),

        const SizedBox(height: 16),
        _buildTaxHackBanner(isEn),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStepCard(GuideStep step, bool isEn) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.secondary,
                  child: Text(
                    '${step.number}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEn ? step.titleEn : step.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isEn ? step.descriptionEn : step.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
            ),
            if ((isEn ? step.tipEn : step.tip).isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEn ? step.tipEn : step.tip,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 2. VISTA DE COMPARATIVAS ---
  Widget _buildComparisonsView(CategoryGuide guide, bool isEn) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        ...guide.comparisons.map((c) => _buildComparisonCard(c, isEn)),
        const SizedBox(height: 16),
        _buildTaxHackBanner(isEn),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildComparisonCard(ServiceComparison item, bool isEn) {
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
            // Título y Tagline
            Text(
              item.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isEn ? item.taglineEn : item.tagline,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 12),

            // Atributos clave en formato tabla
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: item.keyAttributes.entries.map((entry) {
                  // Filtramos para mostrar versión en inglés si procede
                  if (isEn && !entry.key.endsWith('En') && item.keyAttributes.containsKey('${entry.key}En')) {
                    return const SizedBox.shrink();
                  }
                  if (!isEn && entry.key.endsWith('En')) {
                    return const SizedBox.shrink();
                  }

                  String displayKey = entry.key.replaceAll('En', '');
                  if (displayKey == 'monthlyFee') displayKey = isEn ? 'Monthly Fee' : 'Comisión mensual';
                  if (displayKey == 'branchNetwork') displayKey = isEn ? 'Branch Network' : 'Red de Oficinas';
                  if (displayKey == 'onlineOpening') displayKey = isEn ? 'Online Opening' : 'Apertura Online';
                  if (displayKey == 'networkType') displayKey = isEn ? 'Network' : 'Red Móvil';
                  if (displayKey == 'farmCoverage') displayKey = isEn ? 'Farm Reach' : 'Cobertura Granja';
                  if (displayKey == 'plans') displayKey = isEn ? 'Plan Pricing' : 'Tarifa / Planes';
                  if (displayKey == 'coverageType') displayKey = isEn ? 'Cover Type' : 'Tipo Cobertura';
                  if (displayKey == 'ambulanceCover') displayKey = isEn ? 'Ambulance' : 'Ambulancia';
                  if (displayKey == 'pricing') displayKey = isEn ? 'Pricing' : 'Precio / Coste';
                  if (displayKey == 'security') displayKey = isEn ? 'Trust Level' : 'Nivel Seguridad';
                  if (displayKey == 'fundType') displayKey = isEn ? 'Fund Structure' : 'Tipo de Fondo';
                  if (displayKey == 'fees') displayKey = isEn ? 'Fees' : 'Comisiones';
                  if (displayKey == 'format') displayKey = isEn ? 'Course Format' : 'Modalidad';
                  if (displayKey == 'cost') displayKey = isEn ? 'Cost' : 'Precio';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayKey,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Ventajas (Pros)
            const Text(
              '✓ Puntos Fuertes',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
            const SizedBox(height: 4),
            ...(isEn ? item.prosEn : item.pros).map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(CupertinoIcons.checkmark_alt, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(p, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),

            // Desventajas (Cons)
            if ((isEn ? item.consEn : item.cons).isNotEmpty) ...[
              const Text(
                '✗ Puntos a Considerar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusClosed),
              ),
              const SizedBox(height: 4),
              ...(isEn ? item.consEn : item.cons).map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.xmark, size: 14, color: AppColors.statusClosed),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(c, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
            ],

            // Veredicto final
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Veredicto: ${isEn ? item.verdictEn : item.verdict}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. VISTA DE SERVICIOS & B2B PROMOS ---
  Widget _buildPartnersView(AsyncValue<List<AffiliatePartner>> partnersAsync, bool isEn) {
    return partnersAsync.when(
      data: (partners) {
        if (partners.isEmpty) {
          return Center(
            child: Text(
              isEn ? 'No services found for this category' : 'No hay servicios disponibles en esta categoría',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            ...partners.map((p) => _buildPartnerCard(p, isEn)),
            const SizedBox(height: 16),
            _buildTaxHackBanner(isEn),
            const SizedBox(height: 32),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
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

            // Tarjeta de cupón si tiene promoCode (desde Firebase o default)
            if (partner.promoCode != null && partner.promoCode!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.tag_fill, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Código Promo: ${partner.promoCode}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEn ? '(Auto-copied)' : '(Se copia al pulsar)',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                  partner.promoCode != null && partner.promoCode!.isNotEmpty
                      ? (isEn ? 'Apply Code & Open Official Site' : 'Aplicar Descuento & Abrir Web Oficial')
                      : (isEn ? 'Open Official Link' : 'Ir a la Web Oficial'),
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

  Widget _buildTaxHackBanner(bool isEn) {
    return PremiumFeatureGate(
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
    );
  }
}
