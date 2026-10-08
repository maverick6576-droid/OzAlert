import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/affiliate_link_service.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../providers/locale_provider.dart';
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
  int _selectedThemeIndex = 0; // 0 = Llegada, 1 = Trabajo & Ahorro, 2 = Visa & Retorno
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
        {'id': 'insurance', 'label': '🏥 Medicare & Salud', 'labelEn': '🏥 Healthcare'},
        {'id': 'housing', 'label': '🏠 Alquiler & Fianza', 'labelEn': '🏠 Housing & Bond'},
      ]
    },
    {
      'id': 'work',
      'label': '💼 Trabajo & Ahorro',
      'labelEn': '💼 Work & Tax',
      'categories': [
        {'id': 'tax', 'label': '🧾 TFN & Super (12%)', 'labelEn': '🧾 Tax & Super'},
        {'id': 'certifications', 'label': '📜 White Card & RSA', 'labelEn': '📜 Certificates'},
        {'id': 'savings', 'label': '💰 Hacks de Ahorro', 'labelEn': '💰 Pro Money Hacks'},
      ]
    },
    {
      'id': 'visa_departure',
      'label': '🔄 Visa & Retorno',
      'labelEn': '🔄 Visa & Exit',
      'categories': [
        {'id': 'visa_renewal', 'label': '🦘 2ª y 3ª Visa', 'labelEn': '🦘 2nd & 3rd Visa'},
        {'id': 'departure', 'label': '🛫 Vuelta & DASP', 'labelEn': '🛫 Exit & DASP'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(phase2NavigationProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';

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

          // 1. TARJETA EJECUTIVA DE CONTEXTO: ESTÁS CONSULTANDO [TEMA]
          _buildActiveTopicHeaderCard(isEn, currentTheme, currentCategoryItem),

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
                    label: isEn ? '📘 Steps' : '📘 Pasos',
                  ),
                  _buildSubTabItem(
                    index: 1,
                    label: isEn ? '⚖️ Compare' : '⚖️ Comparar',
                  ),
                  _buildSubTabItem(
                    index: 2,
                    label: isEn ? '🎁 Deals' : '🎁 Descuentos',
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

  // 1. TARJETA EJECUTIVA DE CONTEXTO
  Widget _buildActiveTopicHeaderCard(
    bool isEn,
    Map<String, dynamic> currentTheme,
    Map<String, String> currentCategoryItem,
  ) {
    final themeLabel = isEn ? (currentTheme['labelEn'] as String) : (currentTheme['label'] as String);
    final categoryLabel = isEn ? currentCategoryItem['labelEn']! : currentCategoryItem['label']!;

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
                  (isEn ? 'STAGE: ' : 'ETAPA: ') + themeLabel.toUpperCase(),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              showOfficialSourcesModal(context, isEn: isEn, initialTopic: _selectedCategory);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6.5),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.info_circle_fill, size: 13, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    isEn ? 'Official' : 'Oficial',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _showGuidesCatalogModal(context, isEn),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6.5),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.square_grid_2x2_fill, size: 13, color: AppColors.textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    isEn ? 'All (9)' : 'Ver todas',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(CupertinoIcons.chevron_down, size: 10, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. MODAL EXPLORADOR DE TODAS LAS GUÍAS AGRUPADAS POR ETAPA
  void _showGuidesCatalogModal(BuildContext context, bool isEn) {
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
                            isEn ? 'Guides & Reviews Directory' : 'Catálogo de Guías & Revisiones',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            isEn
                                ? '9 essential topics organized by your journey stage'
                                : '9 temas esenciales ordenados por etapa de tu estancia',
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
                    final themeLabel = isEn ? (theme['labelEn'] as String) : (theme['label'] as String);
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
                          final label = isEn ? cat['labelEn']! : cat['label']!;
                          final desc = _getCategoryDescription(cat['id']!, isEn);

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
                                                      isEn ? 'ACTIVE' : 'ACTIVA',
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

  String _getCategoryDescription(String catId, bool isEn) {
    switch (catId) {
      case 'banking':
        return isEn
            ? 'Fee-free Australian bank accounts and low-spread Wise international transfers.'
            : 'Cuentas bancarias sin comisiones de apertura y transferencias con Wise.';
      case 'telecom':
        return isEn
            ? 'Telstra vs Optus mobile coverage, eSIMs and prepaid newcomer plans.'
            : 'Comparativa de cobertura entre Telstra, Optus y SIMs prepago.';
      case 'insurance':
        return isEn
            ? 'Reciprocal Medicare free healthcare card and OVHC private insurance.'
            : 'Tarjeta Medicare gratuita (convenio RHCA) y seguros de salud.';
      case 'housing':
        return isEn
            ? 'Finding rooms on Flatmates, lease agreements and official state bond lodgement.'
            : 'Buscar habitación en Flatmates, contratos e ingreso oficial de fianza.';
      case 'tax':
        return isEn
            ? 'TFN & ABN registration, tax withholding rates and statutory 12% super.'
            : 'Solicitud de TFN, ABN, retenciones IRPF y el 12% de Superannuation.';
      case 'certifications':
        return isEn
            ? 'Mandatory certificates: White Card for construction and state RSA for bar/cafe.'
            : 'Cursos obligatorios oficiales: White Card de obra y RSA de hostelería.';
      case 'savings':
        return isEn
            ? 'ATO tax deduction tricks, grocery hacks and massive cash-saving strategies.'
            : 'Estrategias y deducciones de impuestos ATO para ahorrar miles de dólares.';
      case 'visa_renewal':
        return isEn
            ? '2nd and 3rd year requirements: 88 regional days and audit-proof dossier.'
            : 'Requisitos para 2º y 3r año: 88 días regionales y expediente blindado.';
      case 'departure':
        return isEn
            ? 'Exit checklist: DASP Superannuation refund, bond recovery and early tax return.'
            : 'Protocolo de salida: reclamar Superannuation (DASP), fianza e impuestos.';
      default:
        return isEn ? 'Comprehensive guide with step-by-step instructions.' : 'Guía completa con instrucciones paso a paso.';
    }
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
  Widget _buildFinancialRiskFloatingBanner(bool isEn) {
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
                  isEn ? 'Money at Risk in Australia' : 'Dinero en juego en Australia',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isEn ? 'Super, Bond, Taxes & Medicare' : 'Super, Fianza, Tax y Medicare',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showCalculatorModal(context, isEn),
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
                    isEn ? 'Audit' : 'Auditar',
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

  void _showCalculatorModal(BuildContext context, bool isEn) {
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
                        Text(
                          isEn ? 'Money Audit & Simulator' : 'Auditoría & Simulador de Dinero',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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
                      child: _buildInteractiveMoneyCalculator(isEn, setModalState),
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
  Widget _buildStepsView(CategoryGuide guide, bool isEn) {
    final isSavings = guide.id == 'savings';
    final isDeparture = guide.id == 'departure';
    final isVisaRenewal = guide.id == 'visa_renewal';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (isSavings || isDeparture) ...[
          _buildFinancialRiskFloatingBanner(isEn),
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
                isEn ? guide.titleEn : guide.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                isEn ? guide.subtitleEn : guide.subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15, color: AppColors.secondary),
                  label: Text(
                    isEn ? 'Consult Official Legal Regulations' : 'Consultar Normativa Oficial y Fuentes Legales',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.secondary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  onPressed: () {
                    showOfficialSourcesModal(context, isEn: isEn, initialTopic: guide.id);
                  },
                ),
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

  Widget _buildInteractiveMoneyCalculator(bool isEn, [void Function(void Function())? modalSetState]) {
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
            onChanged: (val) {
              setState(() => _calcSuperDasp = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: isEn ? 'Official Bond Lodgement (Bond Board)' : 'Fianza blindada en organismo oficial estatal',
            amount: '+\$1,500 AUD',
            value: _calcBondRisk,
            onChanged: (val) {
              setState(() => _calcBondRisk = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: isEn ? 'Reciprocal Medicare (Free GP bulk-billing)' : 'Medicare Recíproco (Médico GP público gratis)',
            amount: '+\$600 AUD',
            value: _calcMedicareTreaty,
            onChanged: (val) {
              setState(() => _calcMedicareTreaty = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: isEn ? 'ATO Tax Deductions (Boots, gear, RSA)' : 'Deducciones ATO (Botas, cursos y ropa)',
            amount: '+\$500 AUD',
            value: _calcDeductBoots,
            onChanged: (val) {
              setState(() => _calcDeductBoots = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: isEn ? 'Early Tax Return: Claim withholdings before July' : 'Early Tax Return: Devolución IRPF anticipada',
            amount: '+\$800 AUD',
            value: _calcEarlyTaxReturn,
            onChanged: (val) {
              setState(() => _calcEarlyTaxReturn = val);
              modalSetState?.call(() {});
            },
          ),
          _buildCalcToggleRow(
            title: isEn ? 'Wise Transfer: Avoid 4% hidden bank SWIFT markup' : 'Transferencia Wise: Evita el 4% de spread bancario',
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
                    isEn
                        ? 'Pro guides explain exactly how to claim and shield every single dollar.'
                        : 'Las guías Pro te explican con precisión cómo blindar y recuperar cada dólar.',
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
                isEn ? 'Consult Official Sources (ATO & Home Affairs)' : 'Consultar Fuentes Oficiales (ATO e Inmigración)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                showOfficialSourcesModal(context, isEn: isEn, initialTopic: 'tax');
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
                  if (step.officialUrl != null && step.officialUrl!.isNotEmpty) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: isEn ? 'Open Official Link' : 'Abrir Web Oficial',
                      icon: const Icon(CupertinoIcons.arrow_up_right_circle_fill, size: 20, color: AppColors.primary),
                      onPressed: () async {
                        final uri = Uri.parse(step.officialUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
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
                if (step.officialUrl != null && step.officialUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15),
                      label: Text(
                        (isEn ? step.officialUrlLabelEn : step.officialUrlLabel) ??
                            (isEn ? 'Consult Official Source' : 'Consultar Fuente Oficial'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final uri = Uri.parse(step.officialUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
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

            // Botón oficial de referencia a la web
            if (item.officialUrl != null && item.officialUrl!.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15),
                  label: Text(
                    (isEn ? item.officialUrlLabelEn : item.officialUrlLabel) ??
                        (isEn ? 'Consult Official Website' : 'Consultar Web Oficial'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final uri = Uri.parse(item.officialUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
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
                      ? (isEn ? 'Apply Code & Open Site' : 'Aplicar Código & Abrir Web')
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
                      isEn ? 'Savings Guide' : 'Guía de Ahorro',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    onPressed: () async {
                      final uri = Uri.parse('https://www.ato.gov.au/individuals-and-families/income-deductions-offsets-and-records/deductions-you-can-claim');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 14, color: AppColors.primary),
                    label: Text(
                      isEn ? 'Official ATO Web' : 'Web Oficial ATO',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
