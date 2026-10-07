import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../../domain/models/phase2/regional_work_log.dart';
import '../../../../domain/models/phase2/postcode_info.dart';
import '../../../widgets/phase2/paywall_bottom_sheet.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/phase2_app_bar.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/official_sources_modal.dart';
import 'package:ozvisa_alert/presentation/widgets/phase2/australia_regional_map_widget.dart';

class RegionalWorkScreen extends ConsumerStatefulWidget {
  const RegionalWorkScreen({super.key});

  @override
  ConsumerState<RegionalWorkScreen> createState() => _RegionalWorkScreenState();
}

class _RegionalWorkScreenState extends ConsumerState<RegionalWorkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _targetVisaYear = 2; // 2 = 2º Año (88 días), 3 = 3r Año (179 días)

  // Validador de Códigos Postales
  final _postcodeController = TextEditingController(text: '4870');
  final String _selectedIndustry = 'agriculture';
  PostcodeInfo? _searchResult;

  // Controladores de nuevo empleo
  final _employerNameController = TextEditingController();
  final _abnController = TextEditingController();
  final _daysController = TextEditingController();
  final _hoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Búsqueda inicial por defecto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executePostcodeSearch('4870');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postcodeController.dispose();
    _employerNameController.dispose();
    _abnController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _executePostcodeSearch(String code) {
    final repo = ref.read(postcodeRepositoryProvider);
    final result = repo.findPostcode(code);
    setState(() {
      _searchResult = result;
    });
  }

  String _deduceStateFromPostcode(String code) {
    final clean = code.trim();
    if (clean.isEmpty) return 'QLD';
    final first = clean[0];
    switch (first) {
      case '0':
        return 'NT';
      case '2':
        return 'NSW';
      case '3':
        return 'VIC';
      case '4':
        return 'QLD';
      case '5':
        return 'SA';
      case '6':
        return 'WA';
      case '7':
        return 'TAS';
      default:
        return 'QLD';
    }
  }

  void _selectStateSample(String state) {
    String samplePostcode;
    switch (state.toUpperCase()) {
      case 'QLD':
        samplePostcode = '4870'; // Cairns
        break;
      case 'NSW':
        samplePostcode = '2481'; // Byron Bay
        break;
      case 'VIC':
        samplePostcode = '3550'; // Bendigo
        break;
      case 'WA':
        samplePostcode = '6280'; // Busselton / Margaret River
        break;
      case 'SA':
        samplePostcode = '5251'; // Mount Barker
        break;
      case 'TAS':
        samplePostcode = '7250'; // Launceston
        break;
      case 'NT':
        samplePostcode = '0800'; // Darwin
        break;
      default:
        samplePostcode = '4870';
    }
    _postcodeController.text = samplePostcode;
    _executePostcodeSearch(samplePostcode);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale?.languageCode == 'en';
    final profile = ref.watch(userProfileProvider).value;
    final userEmail = ref.watch(authStateProvider).value?.email ?? 'Applicant';
    final subclass = profile?.visaSubclass ?? '462';
    final isPremium = profile?.isPremium ?? false;

    final jobs = ref.watch(regionalJobsProvider);
    final totalDays = jobs.fold<int>(0, (sum, j) => sum + j.totalDaysCounted);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Phase2AppBar(
        title: isEn ? '88 Days Visa Renewal' : 'Visa 88 Días / 6 Meses',
        isEn: isEn,
        infoTopic: 'regional',
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(text: isEn ? '📍 Postcode & Map' : '📍 Mapa & Códigos'),
            Tab(
              text: !isPremium
                  ? (isEn ? '🗓️ Log ($totalDays/10 Free)' : '🗓️ Contador ($totalDays/10 Gratis)')
                  : (isEn
                      ? '🗓️ Work Log ($totalDays/${_targetVisaYear == 2 ? 88 : 179})'
                      : '🗓️ Contador ($totalDays/${_targetVisaYear == 2 ? 88 : 179})'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // SUBMÓDULO 1: VALIDADOR DE CÓDIGOS POSTALES Y MAPA INTERACTIVO
          _buildPostcodeValidatorTab(isEn, subclass),

          // SUBMÓDULO 2: TRACKER DE DÍAS Y EXPORTACIÓN FORMULARIO 1263
          _buildWorkLogTab(isEn, isPremium, jobs, totalDays, userEmail, subclass),
        ],
      ),
    );
  }

  Widget _buildPostcodeValidatorTab(bool isEn, String subclass) {
    final currentState = _searchResult?.state ?? _deduceStateFromPostcode(_postcodeController.text);
    final currentZone = _searchResult?.zone ?? (_searchResult != null ? 'regional' : 'unknown');

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Selector / Banner de Subclase con acceso directo a normativa
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(CupertinoIcons.shield_lefthalf_fill, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEn ? 'Visa Subclass: $subclass' : 'Subclase Activa: $subclass',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                          ),
                        ),
                        InkWell(
                          onTap: () => showOfficialSourcesModal(context, isEn: isEn, initialTopic: 'regional'),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.info_circle_fill, size: 15, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  isEn ? 'Rules' : 'Norma',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subclass == '462'
                          ? (isEn
                              ? 'Under 462, Tourism/Hospitality counts ONLY in Northern Australia or Remote areas.'
                              : 'Para 462, hostelería cuenta SOLO en Norte de Australia o Zonas Remotas.')
                          : (isEn
                              ? 'Under 417, Hospitality does not qualify (Farming/Construction only).'
                              : 'Para 417, hostelería no computa (sólo campo o construcción).'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Campo de búsqueda de Código Postal
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _postcodeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: isEn ? '4-Digit Postcode' : 'Código Postal Australiano (ej: 4870)',
                  labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  counterText: '',
                  prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.secondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cardBorder)),
                ),
                onSubmitted: _executePostcodeSearch,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () => _executePostcodeSearch(_postcodeController.text),
              child: Text(isEn ? 'Check' : 'Validar', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // MAPA REGIONAL DE AUSTRALIA
        AustraliaRegionalMapWidget(
          activeState: currentState,
          activeZone: currentZone,
          activeLocation: _searchResult?.location,
          isEn: isEn,
          onStateTap: (st) => _selectStateSample(st),
        ),
        const SizedBox(height: 18),

        // RESUMEN EJECUTIVO DE ELEGIBILIDAD POR INDUSTRIA (LIN 22/050)
        _buildCompactIndustrySummaryCard(isEn, subclass, _searchResult),

        const SizedBox(height: 36),
      ],
    );
  }

  List<Map<String, dynamic>> _getIndustriesList(bool isEn, String subclass, PostcodeInfo? postcode) {
    return [
      {
        'id': 'agriculture',
        'icon': '🌾',
        'name': isEn ? 'Plant & Animal Cultivation' : 'Agricultura & Ganadería',
        'desc': isEn
            ? 'Fruit picking, packing shed, harvesting, pruning, cattle, shearing.'
            : 'Recolección, empaquetado, siembra, poda, cuidado de ganado y esquileo.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'agriculture'),
        'legalTip': isEn
            ? 'Fully eligible in regional postcodes for both Subclass 462 and 417.'
            : '100% elegible en códigos regionales para subclases 462 y 417.',
      },
      {
        'id': 'construction',
        'icon': '🏗️',
        'name': isEn ? 'Construction & Building' : 'Construcción & Obras',
        'desc': isEn
            ? 'Residential, commercial building, structural trades with White Card.'
            : 'Obra residencial, comercial, reformas, pintura y peón con White Card.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'construction'),
        'legalTip': isEn
            ? 'Eligible in designated regional areas under LIN 22/050.'
            : 'Válido en áreas regionales designadas bajo el instrumento LIN 22/050.',
      },
      {
        'id': 'tourism_hospitality',
        'icon': '☕',
        'name': isEn ? 'Tourism & Hospitality' : 'Hostelería & Turismo',
        'desc': isEn
            ? 'Cafes, bars, hotels, tour guides, restaurant all-rounder.'
            : 'Cafeterías, bares, hoteles, guías turísticos, camareros y cocina.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'tourism_hospitality'),
        'legalTip': subclass == '462'
            ? (postcode?.isEligible(subclass, 'tourism_hospitality') == true
                ? (isEn ? 'ELIGIBLE: Located in Northern/Remote Australia zone.' : 'VÁLIDO: Ubicado en la Zona Norte / Remota aprobada.')
                : (isEn ? 'INELIGIBLE: Under 462, hospitality ONLY qualifies in Northern/Remote Australia.' : 'NO VÁLIDO: En 462 la hostelería SOLO cuenta en el Norte o Zonas Remotas.'))
            : (isEn ? 'INELIGIBLE: Subclass 417 does not include hospitality under current legislation.' : 'NO VÁLIDO: La Subclase 417 no admite hostelería según la ley vigente.'),
      },
      {
        'id': 'forestry',
        'icon': '🌲',
        'name': isEn ? 'Tree Farming & Forestry' : 'Silvicultura & Tala',
        'desc': isEn
            ? 'Planting, maintaining, felling trees in plantations and sawmills.'
            : 'Plantación, tala y procesado de madera en serrerías regionales.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'forestry_fishing'),
        'legalTip': isEn
            ? 'Eligible across approved regional postcodes.'
            : 'Válido en todos los códigos regionales aprobados.',
      },
      {
        'id': 'fishing',
        'icon': '🎣',
        'name': isEn ? 'Fishing & Pearling' : 'Pesca & Extracción de Perlas',
        'desc': isEn
            ? 'Commercial fishing, pearling operations, hatchery maintenance.'
            : 'Pesca comercial marítima, criaderos y extracción de perlas.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'forestry_fishing'),
        'legalTip': isEn
            ? 'Eligible in regional maritime operations.'
            : 'Válido en explotaciones marítimas regionales.',
      },
      {
        'id': 'recovery',
        'icon': '🚒',
        'name': isEn ? 'Bushfire & Flood Recovery' : 'Recuperación de Desastres',
        'desc': isEn
            ? 'Reconstruction and recovery work in declared natural disaster zones.'
            : 'Reconstrucción en áreas declaradas de incendio o inundación.',
        'eligible': postcode != null && (postcode.zone == 'northern' || postcode.zone.contains('regional') || postcode.zone == 'remote'),
        'legalTip': isEn
            ? 'Eligible in disaster-declared government postcodes.'
            : 'Elegible en zonas declaradas de catástrofe por el gobierno.',
      },
    ];
  }

  Widget _buildCompactIndustrySummaryCard(bool isEn, String subclass, PostcodeInfo? postcode) {
    final industries = _getIndustriesList(isEn, subclass, postcode);
    final eligibleCount = industries.where((i) => i['eligible'] as bool).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏛️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Industry Eligibility (LIN 22/050)' : 'Elegibilidad por Industria',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: (eligibleCount > 0 ? AppColors.secondary : AppColors.statusClosed).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isEn ? '$eligibleCount/${industries.length} Valid' : '$eligibleCount/${industries.length} Válidos',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: eligibleCount > 0 ? AppColors.secondary : AppColors.statusClosed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isEn
                ? 'Quick overview for postcode ${_postcodeController.text} under Visa Subclass $subclass:'
                : 'Resumen rápido para CP ${_postcodeController.text} bajo Subclase $subclass:',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: industries.map((ind) {
              final isEligible = ind['eligible'] as bool;
              final icon = ind['icon'] as String;
              final shortName = (ind['name'] as String).split('&').first.trim();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isEligible
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : AppColors.statusClosed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isEligible
                        ? AppColors.secondary.withValues(alpha: 0.3)
                        : AppColors.statusClosed.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      shortName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isEligible ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isEligible ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                      size: 11,
                      color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(CupertinoIcons.square_list_fill, size: 16),
              label: Text(
                isEn ? 'View Full Rules for All 8 Industries' : 'Ver Normativa de las 8 Industrias (LIN 22/050)',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () => _showAllIndustriesModal(context, isEn, subclass, postcode),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllIndustriesModal(BuildContext context, bool isEn, String subclass, PostcodeInfo? postcode) {
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
                            isEn ? 'Industry Matrix (LIN 22/050)' : 'Matriz de Industrias (LIN 22/050)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            isEn
                                ? 'Postcode ${_postcodeController.text} • Visa Subclass $subclass'
                                : 'Código Postal ${_postcodeController.text} • Subclase $subclass',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      _buildIndustryEligibilityMatrix(isEn, subclass, postcode),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(CupertinoIcons.link, size: 15, color: AppColors.primary),
                          label: Text(
                            isEn ? 'Consult LIN 22/050 Official Legislation' : 'Consultar Normativa Oficial LIN 22/050',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () async {
                            final uri = Uri.parse('https://www.legislation.gov.au/Details/F2022L00445');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndustryEligibilityMatrix(bool isEn, String subclass, PostcodeInfo? postcode) {
    final industries = _getIndustriesList(isEn, subclass, postcode);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: industries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final ind = industries[index];
        final isEligible = ind['eligible'] as bool;
        final icon = ind['icon'] as String;
        final name = ind['name'] as String;

        return InkWell(
          onTap: () => _showIndustryDetailsModal(context, ind, isEn, isEligible, subclass),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEligible
                    ? AppColors.secondary.withValues(alpha: 0.4)
                    : AppColors.statusClosed.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 22)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? AppColors.secondary.withValues(alpha: 0.12)
                            : AppColors.statusClosed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEligible ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                            size: 11,
                            color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isEligible ? (isEn ? 'VALID' : 'SÍ VALE') : (isEn ? 'INVALID' : 'NO VALE'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                Row(
                  children: [
                    const Icon(CupertinoIcons.info_circle, size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      isEn ? 'Tap for rules' : 'Toca para norma',
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showIndustryDetailsModal(BuildContext context, Map<String, dynamic> ind, bool isEn, bool isEligible, String subclass) {
    final icon = ind['icon'] as String;
    final name = ind['name'] as String;
    final desc = ind['desc'] as String;
    final tip = ind['legalTip'] as String;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEligible
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.statusClosed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isEligible ? (isEn ? '✓ ELIGIBLE (LIN 22/050)' : '✓ VÁLIDO (LIN 22/050)') : (isEn ? '✗ INELIGIBLE' : '✗ NO VÁLIDO'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isEn ? 'Roles & Activities Included:' : 'Puestos y tareas comprendidas:',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isEligible
                      ? AppColors.secondary.withValues(alpha: 0.3)
                      : AppColors.statusClosed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isEligible ? CupertinoIcons.shield_fill : CupertinoIcons.exclamationmark_shield_fill,
                    size: 16,
                    color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(CupertinoIcons.link, size: 15, color: AppColors.primary),
                label: Text(
                  isEn ? 'Consult LIN 22/050 Official Legislation' : 'Consultar Normativa Oficial LIN 22/050',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final uri = Uri.parse('https://www.legislation.gov.au/Details/F2022L00445');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(isEn ? 'Got It' : 'Entendido', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkLogTab(bool isEn, bool isPremium, List<RegionalJobEntry> jobs, int totalDays, String applicantEmail, String visaSubclass) {
    final targetRequirement = _targetVisaYear == 2 ? 88 : 179;
    final maxTarget = isPremium ? targetRequirement : 10;
    final progress = (totalDays / maxTarget.toDouble()).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Selector Adaptativo: 2º Año (88 Días) vs 3r Año (179 Días / 6 Meses)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _targetVisaYear = 2),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _targetVisaYear == 2 ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _targetVisaYear == 2
                          ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEn ? '2nd Year Visa' : '2º Año de Visa',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _targetVisaYear == 2 ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          isEn ? '88 Days Requirement' : 'Requisito: 88 Días',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _targetVisaYear == 2 ? Colors.white.withValues(alpha: 0.85) : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _targetVisaYear = 3),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _targetVisaYear == 3 ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _targetVisaYear == 3
                          ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEn ? '3rd Year Visa' : '3r Año de Visa',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _targetVisaYear == 3 ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          isEn ? '179 Days (6 Months)' : 'Requisito: 179 Días (6 Meses)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _targetVisaYear == 3 ? Colors.white.withValues(alpha: 0.85) : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Tarjeta de progreso 88 Días / 179 Días
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    !isPremium
                        ? (isEn ? 'Free Trial Progress (10-Day Cap)' : 'Progreso Gratuito (Límite 10 Días)')
                        : (_targetVisaYear == 2
                            ? (isEn ? '2nd Year Visa Progress' : 'Progreso 2º Año de Visa')
                            : (isEn ? '3rd Year Visa Progress' : 'Progreso 3r Año de Visa')),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                  ),
                  Text(
                    !isPremium ? '$totalDays / 10' : '$totalDays / $targetRequirement ${isEn ? "days" : "días"}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: !isPremium ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(!isPremium ? AppColors.secondary : AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                !isPremium
                    ? (totalDays >= 10
                        ? (isEn ? '🔒 Free trial limit reached! Unlock the complete $targetRequirement days with Premium.' : '🔒 ¡Límite gratuito de 10 días alcanzado! Desbloquea los $targetRequirement días con Premium.')
                        : (isEn ? '${10 - totalDays} free trial days remaining to log.' : 'Te quedan ${10 - totalDays} días de prueba gratuita por registrar.'))
                    : (totalDays >= targetRequirement
                        ? (_targetVisaYear == 2
                            ? (isEn ? '🎉 Goal reached! Ready to lodge your 2nd year visa.' : '🎉 ¡Meta alcanzada! Listo para solicitar tu 2º año.')
                            : (isEn ? '🎉 Goal reached! Ready to lodge your 3rd year visa.' : '🎉 ¡Meta alcanzada! Listo para solicitar tu 3r año.'))
                        : (_targetVisaYear == 2
                            ? (isEn ? '${88 - totalDays} days remaining to complete.' : 'Faltan ${88 - totalDays} días para completar la extensión.')
                            : (isEn ? '${179 - totalDays} days remaining to complete.' : 'Faltan ${179 - totalDays} días para completar la extensión.'))),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              // Banner Promocional Freemium para Desbloquear los Días Completos
              if (!isPremium) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.lock_shield_fill, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEn
                              ? 'Log all $targetRequirement days and generate official Form 1263 immigration PDF dossiers with Premium.'
                              : 'Registra los $targetRequirement días al completo y genera el dossier oficial del Formulario 1263 con Premium.',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => showPhase2PaywallBottomSheet(
                          context: context,
                          featureTitle: isEn
                              ? (_targetVisaYear == 2 ? '88-Day Tracker & Form 1263' : '179-Day Tracker & Form 1263')
                              : (_targetVisaYear == 2 ? 'Contador 88 Días y Form 1263' : 'Contador 179 Días y Form 1263'),
                          featureBenefit: isEn
                              ? 'Track all $targetRequirement days, verify employer ABNs, and export official Form 1263 immigration dossiers.'
                              : 'Registra los $targetRequirement días al completo y descarga el Formulario 1263 oficial listo para ImmiAccount.',
                        ),
                        child: Text(isEn ? 'Unlock' : 'Desbloquear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botón Añadir Empleo
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(CupertinoIcons.plus_circle_fill, color: AppColors.secondary, size: 18),
            label: Text(
              isEn ? 'Add Regional Job Entry' : 'Añadir Registro de Trabajo',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.secondary),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
            onPressed: () {
              if (!isPremium && totalDays >= 10) {
                showPhase2PaywallBottomSheet(
                  context: context,
                  featureTitle: isEn ? '10-Day Free Limit Reached' : 'Límite Gratuito de 10 Días',
                  featureBenefit: isEn
                      ? 'You have recorded 10 free trial days. Upgrade to Premium to log the complete $targetRequirement days and generate your Form 1263 dossier.'
                      : 'Has registrado los 10 días de prueba gratuitos. Pasa a Premium para registrar los $targetRequirement días completos y generar el Formulario 1263 oficial.',
                );
                return;
              }
              _showAddJobDialog(isEn, isPremium, totalDays);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Lista de Empleos Registrados
        if (jobs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Text(
                isEn ? 'No jobs recorded yet. Tap above to add your first job.' : 'Aún no has registrado ningún trabajo regional.',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          )
        else
          ...jobs.map((job) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.cardBorder)),
            elevation: 0,
            color: AppColors.surface,
            child: ListTile(
              title: Text(job.employerBusinessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                '${job.workSiteLocation} (${job.workSitePostcode}) • ${job.totalDaysCounted} días',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              trailing: IconButton(
                icon: const Icon(CupertinoIcons.trash, color: AppColors.statusClosed, size: 18),
                onPressed: () => ref.read(regionalJobsProvider.notifier).removeJob(job.id),
              ),
            ),
          )),

        const SizedBox(height: 20),

        // Botón Exportar Dossier Formulario 1263 (Con Paywall)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.doc_checkmark_fill, size: 18),
            label: Text(
              isEn ? 'Export Form 1263 PDF Dossier' : 'Generar Formulario 1263 Oficial (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () async {
              if (!isPremium) {
                showPhase2PaywallBottomSheet(
                  context: context,
                  featureTitle: isEn
                      ? (_targetVisaYear == 2 ? 'Form 1263 Immigration Dossier (2nd Year)' : 'Form 1263 Immigration Dossier (3rd Year)')
                      : (_targetVisaYear == 2 ? 'Dossier Formulario 1263 (2º Año)' : 'Dossier Formulario 1263 (3r Año)'),
                  featureBenefit: isEn
                      ? 'Generate an audit-proof Form 1263 PDF dossier with ABNs, hours, and pay slips ready for ImmiAccount.'
                      : 'Genera el dossier en PDF del Formulario 1263 con ABNs, horas y recibos listo para adjuntar en ImmiAccount.',
                );
                return;
              }

              if (jobs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEn ? 'Add at least one job first' : 'Añade al menos un trabajo primero')),
                );
                return;
              }

              final pdfBytes = await PdfGeneratorService.generateRegionalDossier(
                applicantName: applicantEmail,
                passportNumber: 'PA1234567',
                visaSubclass: visaSubclass,
                jobs: jobs,
                totalDays: totalDays,
                targetYear: _targetVisaYear,
              );

              final pdfFileName = _targetVisaYear == 2 ? 'Form_1263_2ndYear_Dossier.pdf' : 'Form_1263_3rdYear_Dossier.pdf';
              await PdfGeneratorService.shareOrPrintPdf(pdfBytes, pdfFileName);
            },
          ),
        ),
        const SizedBox(height: 14),

        // Tarjeta de Aversión a la Pérdida: Riesgo de auditoría y tasa de $650 AUD
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.statusClosed.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppColors.statusClosed, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Immigration Audit Protection' : 'Protección Frente a Auditorías de Inmigración',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn
                          ? 'Home Affairs audits ~23% of 2nd year applications. An invalid ABN or postcode leads to refusal and loss of the non-refundable \$650 AUD visa fee.'
                          : 'Inmigración audita ~23% de solicitudes de 2º año. Un ABN o código erróneo provoca denegación inmediata y la pérdida de la tasa oficial de \$650 AUD.',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showAddJobDialog(bool isEn, bool isPremium, int currentTotalDays) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEn ? 'Add Regional Job' : 'Registrar Nuevo Empleo Regional', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _employerNameController,
                decoration: InputDecoration(
                  labelText: isEn ? 'Business Name' : 'Nombre de la Empresa',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _abnController,
                decoration: InputDecoration(
                  labelText: isEn ? 'ABN (11 Digits)' : 'ABN (11 Dígitos)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isEn ? 'Days Counted' : 'Días Totales',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isEn ? 'Total Hours' : 'Horas Totales',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'Cancelar', style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final days = int.tryParse(_daysController.text) ?? 1;
              final hours = double.tryParse(_hoursController.text) ?? 38.0;

              // Verificación de límite de 10 días para usuarios gratuitos
              if (!isPremium && (currentTotalDays + days > 10)) {
                Navigator.pop(ctx);
                showPhase2PaywallBottomSheet(
                  context: context,
                  featureTitle: isEn ? '10-Day Free Limit Reached' : 'Límite Gratuito de 10 Días',
                  featureBenefit: isEn
                      ? 'Free tier includes tracking up to 10 days. Upgrade to Premium to log the complete ${_targetVisaYear == 2 ? 88 : 179} days and export official Form 1263 PDF dossiers.'
                      : 'Has intentado superar los 10 días de la versión gratuita. Pasa a Premium para registrar los ${_targetVisaYear == 2 ? 88 : 179} días completos y generar el Formulario 1263 oficial.',
                );
                return;
              }

              if (_employerNameController.text.isNotEmpty) {
                final entry = RegionalJobEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  employerBusinessName: _employerNameController.text,
                  employerAbn: _abnController.text.isNotEmpty ? _abnController.text : '12 345 678 901',
                  workSitePostcode: _postcodeController.text,
                  workSiteLocation: _searchResult?.location ?? 'Regional Area',
                  industry: _selectedIndustry,
                  startDate: DateTime.now().subtract(Duration(days: days)),
                  endDate: DateTime.now(),
                  totalDaysCounted: days,
                  totalHours: hours,
                  grossEarningsAud: hours * 33.05,
                );

                ref.read(regionalJobsProvider.notifier).addJob(entry);
                Navigator.pop(ctx);
                _employerNameController.clear();
                _abnController.clear();
                _daysController.clear();
                _hoursController.clear();
              }
            },
            child: Text(isEn ? 'Save' : 'Guardar', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
