import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/affiliate_link_service.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../providers/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/localization/guide_translations.dart';
import '../../../../domain/models/phase2/affiliate_partner.dart';
import '../../../../domain/models/phase2/guide_data.dart';
import '../../../widgets/phase2/premium_feature_gate.dart';
import '../../../widgets/phase2/official_sources_modal.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/phase2_app_bar.dart';

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  int _selectedThemeIndex = 0; // 0 = Llegada, 1 = Empleo, 2 = Fiscal & Auto, 3 = Regional & Salida
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

  static const List<Map<String, dynamic>> _themes = [
    {
      'id': 'arrival',
      'label': '🛬 Llegada',
      'labelEn': '🛬 Arrival',
      'categories': [
        {'id': 'banking', 'label': '🏦 Bancos & Wise', 'labelEn': '🏦 Banks & Wise'},
        {'id': 'telecom', 'label': '📱 SIM & Red', 'labelEn': '📱 Mobile & SIM'},
        {'id': 'housing', 'label': '🏠 Alquiler & Fianza', 'labelEn': '🏠 Housing & Bond'},
        {'id': 'insurance', 'label': '🏥 Medicare & Salud', 'labelEn': '🏥 Healthcare'},
      ]
    },
    {
      'id': 'employment',
      'label': '💼 Empleo',
      'labelEn': '💼 Employment',
      'categories': [
        {'id': 'certifications', 'label': '📜 White Card & RSA', 'labelEn': '📜 Certificates'},
        {'id': 'tax', 'label': '🧾 TFN & Super (12%)', 'labelEn': '🧾 Tax & Super'},
      ]
    },
    {
      'id': 'tax_medicare',
      'label': '🏛️ Fiscal & Auto',
      'labelEn': '🏛️ Tax & Cars',
      'categories': [
        {'id': 'savings', 'label': '💰 Hacks de Ahorro', 'labelEn': '💰 Pro Money Hacks'},
        {'id': 'international_license', 'label': '🪪 Carnet Internacional', 'labelEn': '🪪 International Permit'},
        {'id': 'australian_license', 'label': '🚗 Carnet Australiano', 'labelEn': '🚗 Aussie Driver Licence'},
      ]
    },
    {
      'id': 'regional_work',
      'label': '🚜 Regional & Salida',
      'labelEn': '🚜 Regional & Exit',
      'categories': [
        {'id': 'visa_renewal', 'label': '🌾 88 Días (2ª Visa)', 'labelEn': '🌾 88 Days (2nd Visa)'},
        {'id': 'visa_renewal_179', 'label': '⭐ 179 Días (3ª Visa)', 'labelEn': '⭐ 179 Days (3rd Visa)'},
        {'id': 'departure', 'label': '🛫 Vuelta & DASP', 'labelEn': '🛫 Exit & DASP'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(phase2NavigationProvider);
    final locale = ref.watch(localeProvider);
    final lang = locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final isEn = lang != 'es';

    // Redirección directa desde checklist de Aterrizaje
    if (navState.activeGuideCategory != null && navState.activeGuideCategory != _selectedCategory) {
      _selectedCategory = navState.activeGuideCategory!;
      for (int i = 0; i < _themes.length; i++) {
        final cats = _themes[i]['categories'] as List<Map<String, String>>;
        if (cats.any((c) => c['id'] == _selectedCategory)) {
          _selectedThemeIndex = i;
          break;
        }
      }
    }

    final guideAsync = ref.watch(guideCategoryProvider(_selectedCategory));
    final partnersAsync = ref.watch(affiliateCategoryProvider(_selectedCategory));
    final currentTheme = _themes[_selectedThemeIndex.clamp(0, _themes.length - 1)];
    final currentCategories = currentTheme['categories'] as List<Map<String, String>>;
    final currentCategoryItem = currentCategories.firstWhere(
      (c) => c['id'] == _selectedCategory,
      orElse: () => currentCategories.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Phase2AppBar(
        title: AppStrings.guidesAppBarTitle(lang),
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
                          AppStrings.guideReturnChecklist(lang),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 1. TARJETA EJECUTIVA DE CONTEXTO: ESTÁS CONSULTANDO [TEMA]
          _buildActiveTopicHeaderCard(lang, isEn, currentTheme, currentCategoryItem),

          // 2. SUB-TABS SEGMENTADAS DE 1 SOLA LÍNEA (Paso a Paso / Comparativa / Descuentos & Apps)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _buildSubTabItem(
                    index: 0,
                    label: AppStrings.guideSubTab(lang, 0),
                  ),
                  _buildSubTabItem(
                    index: 1,
                    label: AppStrings.guideSubTab(lang, 1),
                  ),
                  _buildSubTabItem(
                    index: 2,
                    label: AppStrings.guideSubTab(lang, 2),
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
                      AppStrings.guideComingSoon(lang),
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                if (_selectedSubTab == 0) {
                  return _buildStepsView(guide, lang, isEn);
                } else if (_selectedSubTab == 1) {
                  return _buildComparisonsView(guide, lang, isEn);
                } else {
                  return _buildPartnersView(partnersAsync, lang, isEn);
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

  // 1. TARJETA EJECUTIVA DE CONTEXTO
  Widget _buildActiveTopicHeaderCard(
    String lang,
    bool isEn,
    Map<String, dynamic> currentTheme,
    Map<String, String> currentCategoryItem,
  ) {
    final themeLabel = AppStrings.guideThemeTitle(lang, currentTheme['id'] as String);
    final categoryLabel = AppStrings.guideCategoryLabel(lang, currentCategoryItem['id']!);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.guideStagePrefix(lang) + themeLabel.toUpperCase(),
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  categoryLabel,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _showGuidesCatalogModal(context, lang, isEn),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.square_grid_2x2_fill, size: 13, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    AppStrings.guideAllTopics(lang),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(CupertinoIcons.chevron_down, size: 11, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. MODAL EXPLORADOR DE TODAS LAS GUÍAS AGRUPADAS POR ETAPA
  void _showGuidesCatalogModal(BuildContext context, String lang, bool isEn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.guideDirectoryTitle(lang),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            AppStrings.guideDirectorySubtitle(lang),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _themes.length,
                  itemBuilder: (context, themeIdx) {
                    final theme = _themes[themeIdx];
                    final themeLabel = AppStrings.guideThemeTitle(lang, theme['id'] as String);
                    final categories = theme['categories'] as List<Map<String, String>>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            themeLabel.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        ...categories.map((cat) {
                          final isCurrent = cat['id'] == _selectedCategory;
                          final label = AppStrings.guideCategoryLabel(lang, cat['id']!);
                          final desc = AppStrings.guideCategoryDescription(lang, cat['id']!);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCurrent ? AppColors.primary : AppColors.cardBorder,
                                width: isCurrent ? 1.5 : 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedThemeIndex = themeIdx;
                                    _selectedCategory = cat['id']!;
                                  });
                                  Navigator.pop(ctx);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    label,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800,
                                                      color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                if (isCurrent)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      AppStrings.guideActiveBadge(lang),
                                                      style: const TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.w900,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              desc,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: AppColors.textSecondary,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        CupertinoIcons.chevron_right,
                                        size: 14,
                                        color: isCurrent ? AppColors.primary : AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildSubTabItem({
    required int index,
    required String label,
  }) {
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // 1. BANNER FLOTANTE INTELIGENTE: AUDITORÍA DE RIESGO FINANCIERO
  Widget _buildFinancialRiskFloatingBanner(String lang, bool isEn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '⚠️ AUD \$5,700',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.calcBannerTitle(lang),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                ),
                Text(
                  AppStrings.calcBannerSubtitle(lang),
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showCalculatorModal(context, lang, isEn),
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.calcAuditButton(lang),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(width: 2),
                  const Icon(CupertinoIcons.chevron_right, color: Colors.white, size: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCalculatorModal(BuildContext context, String lang, bool isEn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.calcModalTitle(lang),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildInteractiveMoneyCalculator(lang, isEn, setModalState),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 1. VISTA DE GUÍA PASO A PASO ---
  Widget _buildStepsView(CategoryGuide guide, String lang, bool isEn) {
    final isSavings = guide.id == 'savings';
    final isDeparture = guide.id == 'departure';
    final isVisaRenewal = guide.id == 'visa_renewal';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (isSavings || isDeparture) ...[
          _buildFinancialRiskFloatingBanner(lang, isEn),
          const SizedBox(height: 12),
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
                GuideTranslations.getCategoryTitle(guide.id, lang, guide.title, guide.titleEn),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                GuideTranslations.getCategorySubtitle(guide.id, lang, guide.subtitle, guide.subtitleEn),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15, color: AppColors.secondary),
                  label: Text(
                    AppStrings.guideConsultLegal(lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.secondary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  onPressed: () {
                    showOfficialSourcesModal(context, lang: lang, isEn: isEn, initialTopic: guide.id);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (isSavings || isDeparture || isVisaRenewal) ...[
          // Paso 1 visible para todos (Free preview)
          if (guide.steps.isNotEmpty) _buildStepCard(guide.steps.first, guide.id, lang, isEn),
          const SizedBox(height: 4),

          // Pasos restantes protegidos con candado Premium
          if (guide.steps.length > 1)
            PremiumFeatureGate(
              featureTitle: GuideTranslations.getPaywallTitle(
                isDeparture ? 'departure' : (isVisaRenewal ? 'visa_renewal' : 'savings'),
                lang,
              ),
              featureBenefit: GuideTranslations.getPaywallBenefit(
                isDeparture ? 'departure' : (isVisaRenewal ? 'visa_renewal' : 'savings'),
                lang,
              ),
              child: Column(
                children: guide.steps.skip(1).map((s) => _buildStepCard(s, guide.id, lang, isEn)).toList(),
              ),
            ),
        ] else ...[
          // Listado de pasos estándar
          ...guide.steps.map((s) => _buildStepCard(s, guide.id, lang, isEn)),
          const SizedBox(height: 16),
          _buildTaxHackBanner(lang, isEn),
        ],
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildInteractiveMoneyCalculator(String lang, bool isEn, [void Function(void Function())? modalSetState]) {
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
                      AppStrings.calcTitle(lang),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    Text(
                      AppStrings.calcSubtitle(lang),
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
                        AppStrings.calcTotalReclaimable(lang),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.calcBasedOn(lang),
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
            AppStrings.calcSelectSituations(lang),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),

          _buildCalcToggleRow(
            title: AppStrings.calcDaspTitle(lang),
            amount: '+\$1,850 AUD',
            value: _calcSuperDasp,
            onChanged: (val) {
              setState(() => _calcSuperDasp = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: AppStrings.calcBondTitle(lang),
            amount: '+\$1,500 AUD',
            value: _calcBondRisk,
            onChanged: (val) {
              setState(() => _calcBondRisk = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: AppStrings.calcMedicareTitle(lang),
            amount: '+\$600 AUD',
            value: _calcMedicareTreaty,
            onChanged: (val) {
              setState(() => _calcMedicareTreaty = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: AppStrings.calcDeductBoots(lang),
            amount: '+\$500 AUD',
            value: _calcDeductBoots,
            onChanged: (val) {
              setState(() => _calcDeductBoots = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: AppStrings.calcEarlyTax(lang),
            amount: '+\$800 AUD',
            value: _calcEarlyTaxReturn,
            onChanged: (val) {
              setState(() => _calcEarlyTaxReturn = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: AppStrings.calcWiseTitle(lang),
            amount: '+\$450 AUD',
            value: _calcBankSpread,
            onChanged: (val) {
              setState(() => _calcBankSpread = val);
              modalSetState?.call(() {});
            },
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
                    AppStrings.calcProTip(lang),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 14, color: AppColors.primary),
              label: Text(
                AppStrings.calcConsultOfficial(lang),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              onPressed: () {
                showOfficialSourcesModal(context, lang: lang, isEn: isEn, initialTopic: 'tax');
              },
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

  Widget _buildStepCard(GuideStep step, String guideId, String lang, bool isEn) {
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
                      GuideTranslations.getStepTitle(guideId, step.number, lang, step.title, step.titleEn),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  if (step.officialUrl != null && step.officialUrl!.isNotEmpty) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: GuideTranslations.getOpenUrlTooltip(lang),
                      icon: const Icon(CupertinoIcons.arrow_up_right_circle_fill, size: 20, color: AppColors.primary),
                      onPressed: () {
                        UrlLauncherService.openUrl(context, step.officialUrl!);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
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
                  GuideTranslations.getStepDescription(guideId, step.number, lang, step.description, step.descriptionEn),
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
                            GuideTranslations.getStepTip(guideId, step.number, lang, step.tip, step.tipEn),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (step.officialUrl != null && step.officialUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15),
                      label: Text(
                        GuideTranslations.getStepUrlLabel(guideId, step.number, lang, step.officialUrlLabel, step.officialUrlLabelEn) ??
                            GuideTranslations.getDefaultStepUrlLabel(lang),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, height: 1.3),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        UrlLauncherService.openUrl(context, step.officialUrl!);
                      },
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
                        GuideTranslations.getStepTapHint(lang),
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
  Widget _buildComparisonsView(CategoryGuide guide, String lang, bool isEn) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        ...guide.comparisons.map((c) => _buildComparisonCard(guide.id, c, lang, isEn)),
        const SizedBox(height: 16),
        _buildTaxHackBanner(lang, isEn),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildComparisonCard(String guideId, ServiceComparison item, String lang, bool isEn) {
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
                GuideTranslations.getComparisonTagline(guideId, item.id, lang, item.tagline, item.taglineEn),
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

                  String displayKey = GuideTranslations.getAttributeLabel(entry.key, lang);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 96,
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
              AppStrings.compStrengths(lang),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
            const SizedBox(height: 4),
            ...GuideTranslations.getComparisonPros(guideId, item.id, lang, item.pros, item.prosEn).map((p) => Padding(
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
            Builder(
              builder: (context) {
                final cons = GuideTranslations.getComparisonCons(guideId, item.id, lang, item.cons, item.consEn);
                if (cons.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.compWeaknesses(lang),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusClosed),
                    ),
                    const SizedBox(height: 4),
                    ...cons.map((c) => Padding(
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
                );
              },
            ),

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
                      '${AppStrings.compVerdict(lang)} ${GuideTranslations.getComparisonVerdict(guideId, item.id, lang, item.verdict, item.verdictEn)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            // Botón oficial de referencia a la web
            if (item.officialUrl != null && item.officialUrl!.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15),
                  label: Text(
                    GuideTranslations.getComparisonUrlLabel(guideId, item.id, lang, item.officialUrlLabel, item.officialUrlLabelEn) ??
                        GuideTranslations.getDefaultCompUrlLabel(lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    UrlLauncherService.openUrl(context, item.officialUrl!);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 3. VISTA DE SERVICIOS & B2B PROMOS ---
  Widget _buildPartnersView(AsyncValue<List<AffiliatePartner>> partnersAsync, String lang, bool isEn) {
    return partnersAsync.when(
      data: (partners) {
        // Filtro estricto: Solo mostrar partners con código de descuento / beneficio B2B real
        final activeDeals = partners
            .where((p) => p.isActive && p.promoCode != null && p.promoCode!.isNotEmpty)
            .toList();

        if (activeDeals.isEmpty) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildComingSoonDealsCard(lang, isEn),
              const SizedBox(height: 16),
              _buildTaxHackBanner(lang, isEn),
              const SizedBox(height: 36),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            ...activeDeals.map((p) => _buildPartnerCard(p, lang, isEn)),
            const SizedBox(height: 16),
            _buildTaxHackBanner(lang, isEn),
            const SizedBox(height: 36),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildComingSoonDealsCard(String lang, bool isEn) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.surfaceElevated,
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.sparkles,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        GuideTranslations.getExclusiveCommunityBadge(lang),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      GuideTranslations.getB2BDealsTitle(lang),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.dealsExclusiveTitle(lang),
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            GuideTranslations.getB2BDealsDesc(lang),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 14),
          _buildComingSoonPerkItem(
            icon: CupertinoIcons.shield_fill,
            color: const Color(0xFF0D9488),
            title: GuideTranslations.getPerkTitle(1, lang),
            desc: GuideTranslations.getPerkDesc(1, lang),
          ),
          const SizedBox(height: 10),
          _buildComingSoonPerkItem(
            icon: CupertinoIcons.money_dollar_circle_fill,
            color: AppColors.secondary,
            title: GuideTranslations.getPerkTitle(2, lang),
            desc: GuideTranslations.getPerkDesc(2, lang),
          ),
          const SizedBox(height: 10),
          _buildComingSoonPerkItem(
            icon: CupertinoIcons.doc_checkmark_fill,
            color: AppColors.warning,
            title: GuideTranslations.getPerkTitle(3, lang),
            desc: GuideTranslations.getPerkDesc(3, lang),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonPerkItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerCard(AffiliatePartner partner, String lang, bool isEn) {
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
                        '${GuideTranslations.getPartnerCodeLabel(lang)}: ${partner.promoCode}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                    ),
                    Text(
                      GuideTranslations.getPartnerAutoCopied(lang),
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
                      ? GuideTranslations.getPartnerApplyCode(lang)
                      : GuideTranslations.getPartnerOpenSite(lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, height: 1.3),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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

  Widget _buildTaxHackBanner(String lang, bool isEn) {
    return PremiumFeatureGate(
      featureTitle: GuideTranslations.getTaxHackBannerTitle(lang),
      featureBenefit: GuideTranslations.getTaxHackBannerBenefit(lang),
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
                    GuideTranslations.getTaxHackGuideTitle(lang),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              GuideTranslations.getTaxHackGuideDesc(lang),
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'savings';
                      });
                    },
                    icon: const Icon(CupertinoIcons.sparkles, size: 14),
                    label: Text(
                      GuideTranslations.getTaxHackSavingsBtn(lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      UrlLauncherService.openUrl(
                        context,
                        'https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/deductions-you-can-claim',
                      );
                    },
                    icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 14, color: AppColors.primary),
                    label: Text(
                      GuideTranslations.getTaxHackAtoBtn(lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
