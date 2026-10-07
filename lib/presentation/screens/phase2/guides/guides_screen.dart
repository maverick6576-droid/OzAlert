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
import 'package:ozvisa_alert/presentation/widgets/phase2/phase2_app_bar.dart';

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  String _selectedCategory = 'banking';
  int _selectedSubTab = 0; // 0 = Guía Paso a Paso, 1 = Comparativa, 2 = Servicios & Promos

  // Estado de la Calculadora de Ahorro / Pérdida en Australia
  bool _calcDeductBoots = true;
  bool _calcSuperDasp = true;
  bool _calcBondRisk = true;
  bool _calcMedicareTreaty = true;
  bool _calcEarlyTaxReturn = true;
  bool _calcBankSpread = true;

  // Seguimiento de pasos expandidos (Divulgación Progresiva)
  final Set<int> _expandedSteps = {};

  int get _calculatedLossAmount {
    int total = 0;
    if (_calcDeductBoots) total += 500;
    if (_calcSuperDasp) total += 1850;
    if (_calcBondRisk) total += 1500;
    if (_calcMedicareTreaty) total += 600;
    if (_calcEarlyTaxReturn) total += 800;
    if (_calcBankSpread) total += 450;
    return total;
  }

  final List<Map<String, String>> _categories = const [
    {'id': 'savings', 'label': '💰 Hacks Ahorro Pro', 'labelEn': '💰 Pro Money Hacks'},
    {'id': 'visa_renewal', 'label': '🦘 2ª y 3ª Visa', 'labelEn': '🦘 2nd & 3rd Visa'},
    {'id': 'departure', 'label': '🛫 Salida de Australia', 'labelEn': '🛫 Leaving Australia'},
    {'id': 'banking', 'label': '🏦 Bancos', 'labelEn': '🏦 Banking'},
    {'id': 'telecom', 'label': '📱 SIM & Red', 'labelEn': '📱 Mobile & SIM'},
    {'id': 'insurance', 'label': '🏥 Seguros', 'labelEn': '🏥 Insurance'},
    {'id': 'housing', 'label': '🏠 Alquiler', 'labelEn': '🏠 Housing'},
    {'id': 'tax', 'label': '🧾 Impuestos', 'labelEn': '🧾 Tax & Super'},
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
      appBar: Phase2AppBar(
        title: isEn ? 'Guides & Reviews' : 'Guías & Comparativas',
        isEn: isEn,
        infoTopic: _selectedCategory,
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
                      Expanded(
                        child: Text(
                          isEn ? 'Return to checklist to mark step done' : 'Volver al checklist para marcar la tarea',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Pestañas horizontales de categorías con diseño limpio
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
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12.5,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        width: 1.2,
                      ),
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

          // Sub-tabs segmentadas: compactas para evitar recortes de texto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _buildSubTabItem(
                    index: 0,
                    label: isEn ? '📘 Guide' : '📘 Guía',
                    sublabel: isEn ? 'Step-by-step' : 'Paso a paso',
                  ),
                  _buildSubTabItem(
                    index: 1,
                    label: isEn ? '⚖️ Compare' : '⚖️ Comparativa',
                    sublabel: isEn ? 'Features' : 'Detalles',
                  ),
                  _buildSubTabItem(
                    index: 2,
                    label: isEn ? '🎁 Deals' : '🎁 Promos B2B',
                    sublabel: isEn ? 'Coupons' : 'Descuentos',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Contenido principal dinámico
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
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem({
    required int index,
    required String label,
    required String sublabel,
  }) {
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: isSelected
                ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                : null,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                sublabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white.withValues(alpha: 0.85) : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. VISTA DE GUÍA PASO A PASO ---
  Widget _buildStepsView(CategoryGuide guide, bool isEn) {
    final isSavings = guide.id == 'savings';
    final isDeparture = guide.id == 'departure';
    final isVisaRenewal = guide.id == 'visa_renewal';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (isSavings || isDeparture) ...[
          _buildInteractiveMoneyCalculator(isEn),
          const SizedBox(height: 14),
        ],

        // Cabecera descriptiva de la categoría
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn ? guide.titleEn : guide.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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

        if (isSavings || isDeparture || isVisaRenewal) ...[
          // Paso 1 visible para todos (Free preview)
          if (guide.steps.isNotEmpty) _buildStepCard(guide.steps.first, isEn),
          const SizedBox(height: 4),

          // Pasos restantes protegidos con candado Premium
          if (guide.steps.length > 1)
            PremiumFeatureGate(
              featureTitle: isDeparture
                  ? (isEn ? 'Departure Cash Recovery' : 'Protocolo Pro de Salida')
                  : (isVisaRenewal
                      ? (isEn ? '2nd & 3rd Year Visa Dossier' : 'Expediente Pro 2ª y 3ª Visa')
                      : (isEn ? 'Pro Money Hacks' : 'Hacks Pro de Ahorro Masivo')),
              featureBenefit: isDeparture
                  ? (isEn
                      ? 'Unlock full guides for DASP early release trick, Early Tax Return, and 100% rental bond recovery.'
                      : 'Desbloquea las guías completas para liberar el DASP de inmediato, Early Tax Return y blindar tu fianza al 100%.')
                  : (isVisaRenewal
                      ? (isEn
                          ? 'Unlock step-by-step audit-proof guides for 88 days, 179 days, and section 56 RFI responses.'
                          : 'Desbloquea la guía paso a paso para blindar tus 88 días, 179 días y superar requerimientos s56 de Inmigración.')
                      : (isEn
                          ? 'Unlock full guides for DASP Super refund, Medicare RHCA free public health, and state bond lodgement guarantees.'
                          : 'Desbloquea las guías completas para reclamar la Superannuation (DASP), tarjeta Medicare gratuita y protección oficial de fianza.')),
              child: Column(
                children: guide.steps.skip(1).map((s) => _buildStepCard(s, isEn)).toList(),
              ),
            ),
        ] else ...[
          // Listado de pasos estándar
          ...guide.steps.map((s) => _buildStepCard(s, isEn)),
          const SizedBox(height: 16),
          _buildTaxHackBanner(isEn),
        ],
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildInteractiveMoneyCalculator(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.money_dollar_circle_fill, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? '⚠️ Money at Risk Calculator' : '⚠️ Calculadora de Dinero en Juego',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    Text(
                      isEn ? 'Cash often lost by WHV newcomers' : 'Dinero que se suele perder por desconocimiento',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Totalizador de dinero en riesgo con diseño de alto impacto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'TOTAL RECLAIMABLE / SHIELDED' : 'TOTAL RECLAMABLE / PROTEGIDO',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn ? 'Based on your selected options' : 'Según las opciones marcadas debajo',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$$_calculatedLossAmount AUD',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            isEn ? 'Select your situations to calculate:' : 'Marca tu situación para auditar tu caso:',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),

          _buildCalcToggleRow(
            title: isEn ? 'DASP: 12% Superannuation Exit Refund' : 'DASP: Devolución 12% Superannuation al salir',
            amount: '+\$1,850 AUD',
            value: _calcSuperDasp,
            onChanged: (val) => setState(() => _calcSuperDasp = val),
          ),
          _buildCalcToggleRow(
            title: isEn ? 'Official Bond Lodgement (Bond Board)' : 'Fianza blindada en organismo oficial estatal',
            amount: '+\$1,500 AUD',
            value: _calcBondRisk,
            onChanged: (val) => setState(() => _calcBondRisk = val),
          ),
          _buildCalcToggleRow(
            title: isEn ? 'Reciprocal Medicare (Free GP bulk-billing)' : 'Medicare Recíproco (Médico GP público gratis)',
            amount: '+\$600 AUD',
            value: _calcMedicareTreaty,
            onChanged: (val) => setState(() => _calcMedicareTreaty = val),
          ),
          _buildCalcToggleRow(
            title: isEn ? 'ATO Tax Deductions (Boots, gear, RSA)' : 'Deducciones ATO (Botas, cursos y ropa)',
            amount: '+\$500 AUD',
            value: _calcDeductBoots,
            onChanged: (val) => setState(() => _calcDeductBoots = val),
          ),
          _buildCalcToggleRow(
            title: isEn ? 'Early Tax Return: Claim withholdings before July' : 'Early Tax Return: Devolución IRPF anticipada',
            amount: '+\$800 AUD',
            value: _calcEarlyTaxReturn,
            onChanged: (val) => setState(() => _calcEarlyTaxReturn = val),
          ),
          _buildCalcToggleRow(
            title: isEn ? 'Wise Transfer: Avoid 4% hidden bank SWIFT markup' : 'Transferencia Wise: Evita el 4% de spread bancario',
            amount: '+\$450 AUD',
            value: _calcBankSpread,
            onChanged: (val) => setState(() => _calcBankSpread = val),
          ),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_shield_fill, color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Pro guides explain exactly how to claim and shield every single dollar.'
                        : 'Las guías Pro te explican con precisión cómo blindar y recuperar cada dólar.',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcToggleRow({
    required String title,
    required String amount,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: value ? AppColors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value ? AppColors.cardBorder : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                value ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                color: value ? AppColors.secondary : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: value ? FontWeight.w700 : FontWeight.w500,
                    color: value ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: value ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(GuideStep step, bool isEn) {
    final isExpanded = _expandedSteps.contains(step.number);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isExpanded ? AppColors.primary.withValues(alpha: 0.4) : AppColors.cardBorder,
        ),
      ),
      elevation: 0,
      color: AppColors.surface,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedSteps.remove(step.number);
            } else {
              _expandedSteps.add(step.number);
            }
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: isExpanded ? AppColors.primary : AppColors.secondary,
                    child: Text(
                      '${step.number}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEn ? step.titleEn : step.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  Icon(
                    isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),

              // Contenido con divulgación progresiva (solo visible si se expande)
              if (isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 10),
                Text(
                  isEn ? step.descriptionEn : step.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
                ),
                if ((isEn ? step.tipEn : step.tip).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isEn ? step.tipEn : step.tip,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 36),
                    Expanded(
                      child: Text(
                        isEn ? 'Tap to view step-by-step instructions ▾' : 'Toca para ver instrucciones paso a paso ▾',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
        const SizedBox(height: 36),
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
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y Tagline
            Text(
              item.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 12),

            // Atributos clave en formato tabla limpia con anchos seguros
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
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
                  if (displayKey == 'monthlyFee') displayKey = isEn ? 'Monthly Fee' : 'Comisión';
                  if (displayKey == 'branchNetwork') displayKey = isEn ? 'Network' : 'Oficinas';
                  if (displayKey == 'onlineOpening') displayKey = isEn ? 'Online Opening' : 'Apertura';
                  if (displayKey == 'networkType') displayKey = isEn ? 'Network' : 'Red Móvil';
                  if (displayKey == 'farmCoverage') displayKey = isEn ? 'Farm Signal' : 'En Granjas';
                  if (displayKey == 'plans') displayKey = isEn ? 'Plans' : 'Tarifa';
                  if (displayKey == 'coverageType') displayKey = isEn ? 'Coverage' : 'Cobertura';
                  if (displayKey == 'ambulanceCover') displayKey = isEn ? 'Ambulance' : 'Ambulancia';
                  if (displayKey == 'pricing') displayKey = isEn ? 'Price' : 'Precio';
                  if (displayKey == 'security') displayKey = isEn ? 'Safety' : 'Seguridad';
                  if (displayKey == 'fundType') displayKey = isEn ? 'Structure' : 'Tipo Fondo';
                  if (displayKey == 'fees') displayKey = isEn ? 'Fees' : 'Comisiones';
                  if (displayKey == 'format') displayKey = isEn ? 'Format' : 'Modalidad';
                  if (displayKey == 'cost') displayKey = isEn ? 'Cost' : 'Precio';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 85,
                          child: Text(
                            displayKey,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
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
            Text(
              isEn ? '✓ Key Strengths' : '✓ Puntos Fuertes',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
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
              Text(
                isEn ? '✗ Important Caveats' : '✗ A Tener en Cuenta',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusClosed),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${isEn ? "Verdict" : "Veredicto"}: ${isEn ? item.verdictEn : item.verdict}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
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
            const SizedBox(height: 36),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
      elevation: 0,
      color: AppColors.surface,
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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
                  children: [
                    const Icon(CupertinoIcons.tag_fill, size: 15, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${isEn ? "Code" : "Código"}: ${partner.promoCode}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                    ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
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
                Expanded(
                  child: Text(
                    isEn ? 'Pro Tax Deductions Guide' : 'Guía Pro de Deducciones Fiscales',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isEn
                  ? 'How to claim back expenses from your farm, hospitality or construction jobs at end of financial year.'
                  : 'Cómo desgravar gastos de herramientas, visados y cursos de formación en la declaración de impuestos.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'savings';
                });
              },
              icon: const Icon(CupertinoIcons.sparkles, size: 14),
              label: Text(
                isEn ? 'Open Pro Savings Hacks (+ \$3,500 AUD)' : 'Ver Hacks Pro de Ahorro (+ \$3.500 AUD)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
