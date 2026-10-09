import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/url_launcher_service.dart';
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
    // Búsqueda inicial por defecto sin snackbar molesto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executePostcodeSearch('4870', showFeedback: false);
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

  void _executePostcodeSearch(String code, {bool showFeedback = true}) {
    final clean = code.trim().replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) return;
    FocusScope.of(context).unfocus();
    final repo = ref.read(postcodeRepositoryProvider);
    final result = repo.findPostcode(clean);
    setState(() {
      _searchResult = result;
    });

    if (showFeedback && mounted) {
      final isRegional = result != null && result.zone != 'metro' && result.zone != 'unknown';
      final isEn = ref.read(localeProvider)?.languageCode == 'en';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result != null && isRegional) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Searched: CP $clean • ${result.location} (Eligible Regional Zone)'
                        : 'Búsqueda: CP $clean • ${result.location} (Zona Regional Oficial)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Searched: CP $clean • ${result.location} (Metro / Ineligible)'
                        : 'Búsqueda: CP $clean • ${result.location} (Zona Metro / No Elegible)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD9534F),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(CupertinoIcons.info_circle_fill, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Searched: $clean (Format invalid, must be 4 digits)'
                        : 'Búsqueda: $clean (Formato no válido, debe tener 4 dígitos)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF64748B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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
    final authUser = ref.watch(authStateProvider).value;
    final userEmail = authUser?.email ?? 'Applicant';
    final uid = authUser?.uid;
    final subclass = profile?.visaSubclass ?? '462';
    final isPremium = profile?.isPremium ?? false;

    if (isPremium && uid != null) {
      ref.read(regionalJobsProvider.notifier).loadForUser(uid: uid, isPremium: isPremium);
    }

    final allJobs = ref.watch(regionalJobsProvider);
    final jobs = allJobs.where((j) => j.targetVisaYear == _targetVisaYear).toList();
    final totalDays = jobs.fold<int>(0, (sum, j) => sum + j.totalDaysCounted);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: Phase2AppBar(
        title: isEn ? '88 Days Regional' : '88 Días Regionales',
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
                  ? (isEn ? '🗓️ 88 Days ($totalDays/10)' : '🗓️ 88 Días ($totalDays/10)')
                  : (isEn
                      ? (_targetVisaYear == 2 ? '🗓️ 88 Days ($totalDays/88)' : '🗓️ 3rd Year ($totalDays/179)')
                      : (_targetVisaYear == 2 ? '🗓️ 88 Días ($totalDays/88)' : '🗓️ 3r Año ($totalDays/179)')),
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
          _buildWorkLogTab(isEn, isPremium, jobs, totalDays, userEmail, subclass, uid: uid),
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
        // Cabecera Explicativa Oficial: Finalidad del Validador de Códigos y Zonas
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
                radius: 17,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.primary, size: 20),
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
                            isEn ? 'Postcode & Industry Eligibility' : 'Validador Oficial de Códigos y Zonas',
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
                                const Icon(CupertinoIcons.info_circle_fill, size: 14, color: AppColors.secondary),
                                const SizedBox(width: 3),
                                Text(
                                  isEn ? 'Rules' : 'Normativa',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn
                          ? 'Verify if any Australian postcode and industry meet legal criteria to renew your visa (88 days for 2nd year or 179 days for 3rd year) under immigration instrument LIN 22/050.'
                          : 'Comprueba al instante si tu código postal e industria cumplen los requisitos legales para renovar tu visado (88 días para 2º año o 179 días para 3º) según la normativa oficial LIN 22/050 de Inmigración.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subclass == '462'
                            ? (isEn
                                ? 'Subclass 462: Tourism/Hospitality counts ONLY in Northern or Remote Australia.'
                                : 'Subclase 462: Hostelería y Turismo computan SOLO en Norte o Zonas Remotas.')
                            : (isEn
                                ? 'Subclass 417: Hospitality does NOT qualify (Farming/Construction only).'
                                : 'Subclase 417: Hostelería NO computa (únicamente campo o construcción).'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
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
        const SizedBox(height: 12),

        // TARJETA DE RESULTADO DE BÚSQUEDA DESTACADA (Feedback visual inmediato)
        _buildSearchFeedbackCard(isEn, subclass, _searchResult),
        const SizedBox(height: 14),

        // MAPA REGIONAL DE AUSTRALIA
        AustraliaRegionalMapWidget(
          activeState: currentState,
          activeZone: currentZone,
          activeLocation: _searchResult?.location,
          activePostcode: _postcodeController.text,
          isEn: isEn,
          onRegionSelected: (postcode, state) {
            _postcodeController.text = postcode;
            _executePostcodeSearch(postcode);
          },
          onStateTap: (st) => _selectStateSample(st),
        ),
        const SizedBox(height: 18),

        // RESUMEN EJECUTIVO DE ELEGIBILIDAD POR INDUSTRIA (LIN 22/050)
        _buildCompactIndustrySummaryCard(isEn, subclass, _searchResult),

        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildSearchFeedbackCard(bool isEn, String subclass, PostcodeInfo? result) {
    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.search, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isEn
                    ? 'Enter any 4-digit postcode or tap the map to check LIN 22/050 rules.'
                    : 'Introduce un código postal o pulsa en el mapa para validar la normativa.',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    final isRegional = result.zone != 'metro' && result.zone != 'unknown';
    final isNorthern = result.zone == 'northern';
    final isRemote = result.zone == 'remote';
    final agriValid = result.isEligible(subclass, 'agriculture');
    final constValid = result.isEligible(subclass, 'construction');
    final hospValid = result.isEligible(subclass, 'tourism_hospitality');

    final primaryThemeColor = isRegional ? AppColors.secondary : const Color(0xFFD9534F);

    return Container(
      decoration: BoxDecoration(
        color: primaryThemeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryThemeColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryThemeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRegional ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.exclamationmark_triangle_fill,
                  size: 20,
                  color: primaryThemeColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CP ${result.code} — ${result.location}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_getStateFullName(result.state, isEn)} • Zona: ${isNorthern ? (isEn ? 'Northern Australia' : 'Norte de Australia') : isRemote ? (isEn ? 'Remote Zone (LIN 22/050)' : 'Zona Remota (LIN 22/050)') : isRegional ? (isEn ? 'Regional Australia' : 'Australia Regional') : (isEn ? 'Metropolitan Area' : 'Área Metropolitana')}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: primaryThemeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryThemeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isRegional
                      ? (isEn ? '✓ REGIONAL' : '✓ REGIONAL VÁLIDO')
                      : (isEn ? '✕ METRO' : '✕ METRO NO VÁLIDO'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSearchChip(
                icon: '🌾',
                label: isEn ? 'Agriculture' : 'Agricultura',
                isValid: agriValid,
              ),
              _buildSearchChip(
                icon: '🏗️',
                label: isEn ? 'Construction' : 'Construcción',
                isValid: constValid,
              ),
              _buildSearchChip(
                icon: '☕',
                label: isEn ? 'Hospitality' : 'Hostelería',
                isValid: hospValid,
                note: subclass == '417' ? (isEn ? '417: No' : '417: No') : (!isNorthern && !isRemote ? (isEn ? 'North/Remote only' : 'Solo Norte/Remoto') : null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isRegional
                ? (isEn
                    ? 'Eligible regional postcode under LIN 22/050 for renewing your visa.'
                    : 'Código postal regional oficial según LIN 22/050. Los días trabajados aquí computan para tus 88 o 179 días.')
                : (isEn
                    ? 'Metropolitan area: work performed here DOES NOT count towards 88/179 day visa renewal.'
                    : 'Zona metropolitana: los días trabajados aquí NO computan para renovar tu visado bajo la ley LIN 22/050.'),
            style: TextStyle(
              fontSize: 11,
              color: isRegional ? AppColors.textSecondary : const Color(0xFFC0392B),
              fontWeight: isRegional ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip({
    required String icon,
    required String label,
    required bool isValid,
    String? note,
  }) {
    final color = isValid ? AppColors.secondary : AppColors.statusClosed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 4),
          Icon(
            isValid ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
            size: 12,
            color: color,
          ),
          if (note != null) ...[
            const SizedBox(width: 3),
            Text('($note)', style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  String _getStateFullName(String code, bool isEn) {
    switch (code.toUpperCase()) {
      case 'QLD':
        return 'Queensland (QLD)';
      case 'NSW':
        return isEn ? 'New South Wales (NSW)' : 'Nueva Gales del Sur (NSW)';
      case 'VIC':
        return 'Victoria (VIC)';
      case 'WA':
        return isEn ? 'Western Australia (WA)' : 'Australia Occidental (WA)';
      case 'SA':
        return isEn ? 'South Australia (SA)' : 'Australia Meridional (SA)';
      case 'TAS':
        return 'Tasmania (TAS)';
      case 'NT':
        return isEn ? 'Northern Territory (NT)' : 'Territorio del Norte (NT)';
      case 'ACT':
        return isEn ? 'Australian Capital Territory (ACT)' : 'Territorio Capital (ACT)';
      default:
        return code;
    }
  }

  List<Map<String, dynamic>> _getIndustriesList(bool isEn, String subclass, PostcodeInfo? postcode) {
    final isRegional = postcode != null && postcode.zone != 'metro' && postcode.zone != 'unknown';

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
        'id': 'mining',
        'icon': '⛏️',
        'name': isEn ? 'Mining & Resources' : 'Minería & Recursos',
        'desc': isEn
            ? 'Coal mining, mineral extraction, exploration, FIFO site operations.'
            : 'Extracción mineral, sondeos, explotación de canteras y operaciones FIFO.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'mining'),
        'legalTip': subclass == '462'
            ? (postcode?.isEligible(subclass, 'mining') == true
                ? (isEn ? 'ELIGIBLE: Approved for Subclass 462 in Northern Australia.' : 'VÁLIDO: Aprobado para Subclase 462 en Norte de Australia.')
                : (isEn ? 'INELIGIBLE: Under 462, mining only qualifies in Northern Australia.' : 'NO VÁLIDO: Para 462, minería sólo califica en Norte de Australia.'))
            : (postcode?.isEligible(subclass, 'mining') == true
                ? (isEn ? 'ELIGIBLE: Approved for Subclass 417 in regional areas.' : 'VÁLIDO: Aprobado para Subclase 417 en zonas regionales.')
                : (isEn ? 'INELIGIBLE: In metropolitan areas.' : 'NO VÁLIDO: En áreas metropolitanas.')),
      },
      {
        'id': 'forestry',
        'icon': '🌲',
        'name': isEn ? 'Tree Farming & Forestry' : 'Silvicultura & Tala',
        'desc': isEn
            ? 'Planting, maintaining, felling trees in plantations and sawmills.'
            : 'Plantación, tala y procesado de madera en serrerías regionales.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'forestry'),
        'legalTip': subclass == '462'
            ? (postcode?.isEligible(subclass, 'forestry') == true
                ? (isEn ? 'ELIGIBLE: Tree farming approved in Northern Australia for 462.' : 'VÁLIDO: Silvicultura aprobada en Norte de Australia para 462.')
                : (isEn ? 'INELIGIBLE: Under 462, forestry requires Northern Australia location.' : 'NO VÁLIDO: En 462 requiere ubicación en Norte de Australia.'))
            : (postcode?.isEligible(subclass, 'forestry') == true
                ? (isEn ? 'ELIGIBLE: Tree farming approved across regional postcodes for 417.' : 'VÁLIDO: Aprobado en códigos regionales para 417.')
                : (isEn ? 'INELIGIBLE: Metropolitan areas.' : 'NO VÁLIDO: En áreas metropolitanas.')),
      },
      {
        'id': 'fishing',
        'icon': '🎣',
        'name': isEn ? 'Fishing & Pearling' : 'Pesca & Extracción de Perlas',
        'desc': isEn
            ? 'Commercial fishing, pearling operations, hatchery maintenance.'
            : 'Pesca comercial marítima, criaderos y extracción de perlas.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'fishing'),
        'legalTip': subclass == '462'
            ? (postcode?.isEligible(subclass, 'fishing') == true
                ? (isEn ? 'ELIGIBLE: Fishing/pearling approved in Northern Australia for 462.' : 'VÁLIDO: Pesca/perlas aprobada en Norte de Australia para 462.')
                : (isEn ? 'INELIGIBLE: Under 462, fishing requires Northern Australia location.' : 'NO VÁLIDO: En 462 requiere ubicación en Norte de Australia.'))
            : (postcode?.isEligible(subclass, 'fishing') == true
                ? (isEn ? 'ELIGIBLE: Fishing/pearling approved across regional postcodes for 417.' : 'VÁLIDO: Aprobado en códigos regionales para 417.')
                : (isEn ? 'INELIGIBLE: Metropolitan areas.' : 'NO VÁLIDO: En áreas metropolitanas.')),
      },
      {
        'id': 'bushfire_recovery',
        'icon': '🔥',
        'name': isEn ? 'Bushfire Recovery' : 'Recuperación de Incendios',
        'desc': isEn
            ? 'Construction, land remediation and recovery in declared bushfire disaster zones.'
            : 'Construcción, saneamiento y recuperación en áreas declaradas de incendio.',
        'eligible': isRegional,
        'legalTip': isEn
            ? 'Eligible in government-declared bushfire disaster postcodes (post-31 July 2019).'
            : 'Elegible en códigos declarados zona catastrófica por incendios forestales.',
      },
      {
        'id': 'flood_recovery',
        'icon': '🌊',
        'name': isEn ? 'Flood Recovery' : 'Recuperación de Inundaciones',
        'desc': isEn
            ? 'Cleaning, structural repair and volunteer support in declared flood zones.'
            : 'Limpieza, reconstrucción estructural y apoyo en zonas de inundación declaradas.',
        'eligible': isRegional,
        'legalTip': isEn
            ? 'Eligible in government-declared flood disaster postcodes (post-31 Dec 2021).'
            : 'Elegible en códigos declarados zona catastrófica por inundaciones oficiales.',
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
              icon: const Icon(CupertinoIcons.doc_text_search, size: 16),
              label: Text(
                isEn ? 'Official Legislation (LIN 22/050)' : 'Ver Normativa Oficial (LIN 22/050)',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
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
                          onPressed: () {
                            UrlLauncherService.openUrl(context, 'https://www.legislation.gov.au/Details/F2022L00445');
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
                onPressed: () {
                  UrlLauncherService.openUrl(context, 'https://www.legislation.gov.au/Details/F2022L00445');
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

  Widget _buildWorkLogTab(
    bool isEn,
    bool isPremium,
    List<RegionalJobEntry> jobs,
    int totalDays,
    String applicantEmail,
    String visaSubclass, {
    String? uid,
  }) {
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
              _showAddJobDialog(isEn, isPremium, totalDays, visaSubclass, uid: uid);
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
          ...jobs.map((job) {
            final avgHours = job.totalDaysCounted > 0 ? (job.totalHours / job.totalDaysCounted) : 0.0;
            final isHoursRisk = avgHours < 7.0;
            final isHoursExcess = avgHours > 16.0;
            final isAbnValid = job.employerAbn.replaceAll(RegExp(r'\s+'), '').length == 11;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: (isHoursRisk || !isAbnValid || isHoursExcess)
                      ? Colors.amber.withValues(alpha: 0.5)
                      : AppColors.cardBorder,
                ),
              ),
              elevation: 0,
              color: AppColors.surface,
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.employerBusinessName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    if (isHoursRisk)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isEn ? '⚠️ <7h/day risk' : '⚠️ <7h/d (Riesgo)',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      )
                    else if (!isAbnValid)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.statusClosed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isEn ? '⚠️ ABN issue' : '⚠️ ABN irregular',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.statusClosed),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isEn ? '✓ Compliant' : '✓ Conforme',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Text(
                      '${job.jobRole} • ${job.workSiteLocation} (${job.workSitePostcode})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${job.totalDaysCounted} días • ${job.totalHours.toStringAsFixed(1)}h (${avgHours.toStringAsFixed(1)}h/día) • ABN: ${job.employerAbn}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    Text(
                      'Bruto: \$${job.grossEarningsAud.toStringAsFixed(0)} AUD${job.isFullTimeWeekly ? ' • Full-Time (7d)' : ''}${job.hasPieceworkAgreement ? ' • Destajo/Piecework' : ''}${job.payslipFileRef != null && job.payslipFileRef!.isNotEmpty ? ' • Ref: ${job.payslipFileRef}' : ''}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(CupertinoIcons.trash, color: AppColors.statusClosed, size: 18),
                  onPressed: () => ref.read(regionalJobsProvider.notifier).removeJob(job.id, uid: uid, isPremium: isPremium),
                ),
              ),
            );
          }),

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

              _showDossierExportSheet(
                isEn: isEn,
                jobs: jobs,
                totalDays: totalDays,
                visaSubclass: visaSubclass,
                defaultEmail: applicantEmail,
              );
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

  void _showAddJobDialog(
    bool isEn,
    bool isPremium,
    int currentTotalDays,
    String visaSubclass, {
    String? uid,
  }) {
    String selectedIndustry = 'agriculture';
    DateTime startDate = DateTime.now().subtract(const Duration(days: 14));
    DateTime endDate = DateTime.now();
    final nameCtrl = TextEditingController();
    final abnCtrl = TextEditingController();
    final postcodeCtrl = TextEditingController(
      text: _postcodeController.text.isNotEmpty ? _postcodeController.text : '4870',
    );
    final roleCtrl = TextEditingController(text: isEn ? 'Fruit Picker / Farm Hand' : 'Recolector / Peón Agrícola');
    final locationCtrl = TextEditingController(
      text: _searchResult?.location ?? 'Cairns Regional Area',
    );
    final daysCtrl = TextEditingController(text: '10');
    final hoursCtrl = TextEditingController(text: '76');
    final grossPayCtrl = TextEditingController(text: '2511');
    final payslipRefCtrl = TextEditingController();
    bool isFullTimeWeekly = false;
    bool hasPieceworkAgreement = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          // --- VALIDADOR EN TIEMPO REAL ---
          final List<String> blockingErrors = [];
          final List<String> riskWarnings = [];

          // 1. Nombre de la empresa
          final nameClean = nameCtrl.text.trim();
          if (nameClean.isEmpty) {
            blockingErrors.add(isEn ? 'Employer / Business Name is required.' : 'El nombre de la empresa es obligatorio.');
          }

          // 2. ABN (11 dígitos numéricos)
          final abnClean = abnCtrl.text.replaceAll(RegExp(r'\s+'), '');
          if (abnClean.isEmpty) {
            blockingErrors.add(isEn ? 'ABN is required for Form 1263 verification.' : 'El ABN es obligatorio para el Formulario 1263.');
          } else if (abnClean.length != 11 || int.tryParse(abnClean) == null) {
            blockingErrors.add(isEn ? 'ABN must contain exactly 11 digits (e.g., 51 824 753 556).' : 'El ABN debe tener exactamente 11 dígitos numéricos (ej: 51 824 753 556).');
          }

          // 3. Código Postal & LIN 22/050
          final pCode = postcodeCtrl.text.trim();
          PostcodeInfo? resolvedPostcode;
          if (pCode.length != 4 || int.tryParse(pCode) == null) {
            blockingErrors.add(isEn ? 'Postcode must be a 4-digit Australian code.' : 'El código postal debe tener 4 dígitos australianos.');
          } else {
            final repo = ref.read(postcodeRepositoryProvider);
            resolvedPostcode = repo.findPostcode(pCode);
            if (resolvedPostcode == null) {
              blockingErrors.add(isEn
                  ? 'Postcode $pCode is NOT regional under LIN 22/050. Home Affairs will reject these days.'
                  : 'El código postal $pCode NO figura en las zonas regionales de LIN 22/050. Inmigración rechazará estos días.');
            } else {
              final isIndEligible = resolvedPostcode.isEligible(visaSubclass, selectedIndustry);
              if (!isIndEligible) {
                blockingErrors.add(isEn
                    ? 'Activity not valid for visa $visaSubclass in $pCode (e.g. hospitality only counts in Northern Australia).'
                    : 'La industria no es computable en $pCode para tu visado $visaSubclass (ej. hostelería solo computa en el Norte de Australia).');
              }
            }
          }

          // 4. Ubicación y Puesto
          if (locationCtrl.text.trim().isEmpty) {
            blockingErrors.add(isEn ? 'Work site location / town is required.' : 'La localidad o ubicación de la granja es obligatoria.');
          }
          if (roleCtrl.text.trim().isEmpty) {
            blockingErrors.add(isEn ? 'Job role / position is required.' : 'El puesto o rol desempeñado es obligatorio.');
          }

          // 5. Fechas y Span de Calendario
          final calendarSpan = endDate.difference(startDate).inDays + 1;
          if (startDate.isAfter(endDate)) {
            blockingErrors.add(isEn ? 'Start date cannot be after end date.' : 'La fecha de inicio no puede ser posterior a la de fin.');
          }
          if (endDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
            blockingErrors.add(isEn ? 'Future dates are not permitted. Only completed days count.' : 'No puedes indicar fechas futuras. Solo computan periodos ya trabajados.');
          }

          // 6. Días Computados
          final days = int.tryParse(daysCtrl.text.trim()) ?? 0;
          if (days <= 0) {
            blockingErrors.add(isEn ? 'Days counted must be greater than 0.' : 'Los días deben ser mayores a cero.');
          } else if (calendarSpan > 0 && days > calendarSpan) {
            blockingErrors.add(isEn
                ? 'Inconsistency: $days days entered in a span of only $calendarSpan calendar days.'
                : 'Inconsistencia: Has puesto $days días trabajados en un periodo de solo $calendarSpan días naturales.');
          } else if (!isPremium && (currentTotalDays + days > 10)) {
            blockingErrors.add(isEn
                ? 'Free Limit: Exceeds 10-day trial (${currentTotalDays + days}/10). Upgrade to Pro to unlock.'
                : 'Límite Free: Supera los 10 días de prueba (${currentTotalDays + days}/10). Requiere versión Pro.');
          }

          // 7. Horas Totales y Ratio Home Affairs
          final hours = double.tryParse(hoursCtrl.text.trim()) ?? 0.0;
          final double avgHoursPerDay = days > 0 ? (hours / days) : 0.0;
          if (hours <= 0) {
            blockingErrors.add(isEn ? 'Total hours must be greater than 0.' : 'Las horas totales deben ser mayores a cero.');
          } else if (days > 0) {
            if (avgHoursPerDay < 7.0) {
              riskWarnings.add(isEn
                  ? 'Home Affairs Risk (${avgHoursPerDay.toStringAsFixed(1)}h/day average): Standard full-time is 7–7.6h/day (35–38h/week). Below 7h/day risks being deemed part-time and refused.'
                  : 'Riesgo Home Affairs (media de ${avgHoursPerDay.toStringAsFixed(1)}h/día): Inmigración exige jornada completa estándar (7–7.6h/día o 35–38h/semana). Menos de 7h/día corre riesgo de ser catalogado como media jornada y anulado.');
            } else if (avgHoursPerDay > 16.0) {
              riskWarnings.add(isEn
                  ? 'Excessive Hours (${avgHoursPerDay.toStringAsFixed(1)}h/day): Declaring >16h daily triggers ATO anti-fraud audits.'
                  : 'Horas Inverosímiles (${avgHoursPerDay.toStringAsFixed(1)}h/día): Declarar más de 16h/día dispara auditorías de la ATO e Inmigración por sospecha de fraude.');
            }
          }

          final estGross = hours * 33.05;

          final industryOptions = [
            {'id': 'agriculture', 'label': isEn ? '🌱 Agriculture & Fruit' : '🌱 Agricultura & Fruta'},
            {'id': 'tourism_hospitality', 'label': isEn ? '☕ Hospitality & Tourism' : '☕ Hostelería & Turismo'},
            {'id': 'construction', 'label': isEn ? '🔨 Construction' : '🔨 Construcción'},
            {'id': 'mining', 'label': isEn ? '⛏️ Mining' : '⛏️ Minería'},
            {'id': 'forestry_fishing', 'label': isEn ? '🐟 Fishing & Forestry' : '🐟 Pesca & Silvicultura'},
          ];

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asa superior de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Título con insignia de auditoría inteligente
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(CupertinoIcons.shield_lefthalf_fill, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? 'Smart Regional Job Entry' : 'Registro Inteligente de Empleo',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                            ),
                            Text(
                              isEn ? 'Validated against LIN 22/050 & Fair Work' : 'Validado según LIN 22/050 y Fair Work',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Nombre de la empresa
                  TextField(
                    controller: nameCtrl,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      labelText: isEn ? 'Employer / Business Name *' : 'Nombre de la Empresa o Granja *',
                      hintText: isEn ? 'e.g. Queensland Berry Farms Pty Ltd' : 'ej: Queensland Berry Farms Pty Ltd',
                      prefixIcon: const Icon(CupertinoIcons.building_2_fill, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. ABN y Código Postal en la misma fila
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: abnCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setModalState(() {}),
                          decoration: InputDecoration(
                            labelText: isEn ? 'ABN (11 digits) *' : 'ABN (11 dígitos) *',
                            hintText: '51 824 753 556',
                            prefixIcon: const Icon(CupertinoIcons.number, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: postcodeCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            if (val.length == 4) {
                              final repo = ref.read(postcodeRepositoryProvider);
                              final found = repo.findPostcode(val);
                              if (found != null && locationCtrl.text.isEmpty) {
                                locationCtrl.text = found.location;
                              }
                            }
                            setModalState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: isEn ? 'Postcode *' : 'Cód. Postal *',
                            hintText: '4870',
                            prefixIcon: const Icon(CupertinoIcons.location_solid, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Localidad / Granja y Puesto Desempeñado (Editables por el usuario)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: locationCtrl,
                          onChanged: (_) => setModalState(() {}),
                          decoration: InputDecoration(
                            labelText: isEn ? 'Town / Work Location *' : 'Localidad / Granja *',
                            hintText: isEn ? 'e.g. Mareeba, QLD' : 'ej: Mareeba, QLD',
                            prefixIcon: const Icon(CupertinoIcons.location_circle_fill, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: roleCtrl,
                          onChanged: (_) => setModalState(() {}),
                          decoration: InputDecoration(
                            labelText: isEn ? 'Job Role / Position *' : 'Puesto / Rol Desempeñado *',
                            hintText: isEn ? 'e.g. Fruit Picker' : 'ej: Fruit Picker / Peón',
                            prefixIcon: const Icon(CupertinoIcons.briefcase_fill, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (resolvedPostcode != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '📍 ${resolvedPostcode.location} (${resolvedPostcode.state}) - Zona elegible LIN 22/050',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // 4. Selector de Industria
                  Text(
                    isEn ? 'Industry / Activity Sector:' : 'Sector de Actividad:',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedIndustry,
                        isExpanded: true,
                        items: industryOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['id'],
                            child: Text(
                              opt['label']!,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedIndustry = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Selector de Fechas (Inicio & Fin)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: modalContext,
                              initialDate: startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => startDate = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isEn ? 'Start Date' : 'Fecha Inicio', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  '${startDate.day}/${startDate.month}/${startDate.year}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: modalContext,
                              initialDate: endDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => endDate = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isEn ? 'End Date' : 'Fecha Fin', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  '${endDate.day}/${endDate.month}/${endDate.year}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 6. Días Computados y Horas Totales
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: daysCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setModalState(() {}),
                          decoration: InputDecoration(
                            labelText: isEn ? 'Days to Count *' : 'Días a Computar *',
                            hintText: '10',
                            prefixIcon: const Icon(CupertinoIcons.calendar, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: hoursCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final h = double.tryParse(val) ?? 0.0;
                            if (h > 0) {
                              grossPayCtrl.text = (h * 33.05).toStringAsFixed(0);
                            }
                            setModalState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: isEn ? 'Total Hours *' : 'Horas Totales *',
                            hintText: '76',
                            prefixIcon: const Icon(CupertinoIcons.clock, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 7. Salario Bruto Real y Referencia de Nóminas
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: grossPayCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setModalState(() {}),
                          decoration: InputDecoration(
                            labelText: isEn ? 'Gross Earnings (\$ AUD) *' : 'Salario Bruto Real (\$ AUD) *',
                            hintText: estGross.toStringAsFixed(0),
                            prefixIcon: const Icon(CupertinoIcons.money_dollar, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: payslipRefCtrl,
                          decoration: InputDecoration(
                            labelText: isEn ? 'Payslips Ref / Evidence' : 'Ref. Nóminas / Recibos',
                            hintText: isEn ? 'e.g. Payslips #1-4' : 'ej: Nóminas #1 a #4',
                            prefixIcon: const Icon(CupertinoIcons.doc_text, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (days > 0 && hours > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        isEn
                            ? 'Average: ${avgHoursPerDay.toStringAsFixed(1)}h/day • Fair Work benchmark (~33.05/h): \$${estGross.toStringAsFixed(0)} AUD'
                            : 'Media: ${avgHoursPerDay.toStringAsFixed(1)}h/día • Referencia legal Fair Work: \$${estGross.toStringAsFixed(0)} AUD',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // 8. Opciones avanzadas de Inmigración (Switches)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          title: Text(
                            isEn ? 'Full-Time Weekly Rule (5 days = 7 days count)' : 'Jornada Semanal Completa (5 días = 7 días computables)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            isEn
                                ? 'Under LIN 22/050, working >=35h in 5 days allows counting all 7 days of the week.'
                                : 'Según LIN 22/050, trabajar >=35h en 5 días permite computar los 7 días de la semana completa.',
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                          activeTrackColor: AppColors.secondary,
                          value: isFullTimeWeekly,
                          onChanged: (val) {
                            setModalState(() {
                              isFullTimeWeekly = val;
                              if (val && daysCtrl.text == '5') {
                                daysCtrl.text = '7';
                              }
                            });
                          },
                        ),
                        const Divider(height: 1, indent: 12, endIndent: 12),
                        SwitchListTile.adaptive(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          title: Text(
                            isEn ? 'Signed Piecework Agreement' : 'Contrato a Destajo Firmado (Piecework Agreement)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            isEn
                                ? 'Required by Fair Work for piece rate picking/packing jobs to ensure floor rate compliance.'
                                : 'Exigido por Fair Work en tareas a destajo para certificar el suelo legal salarial.',
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                          activeTrackColor: AppColors.secondary,
                          value: hasPieceworkAgreement,
                          onChanged: (val) => setModalState(() => hasPieceworkAgreement = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 9. PANEL INTELIGENTE DE DIAGNÓSTICO EN TIEMPO REAL
                  if (blockingErrors.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusClosed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.statusClosed.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppColors.statusClosed, size: 17),
                              const SizedBox(width: 6),
                              Text(
                                isEn ? 'Blocking Validation Issues Detected:' : 'Errores que Home Affairs Rechazará:',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.statusClosed),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...blockingErrors.map((err) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: AppColors.statusClosed, fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    err,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.statusClosed, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    )
                  else if (riskWarnings.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.exclamationmark_shield_fill, color: Colors.orange, size: 17),
                              const SizedBox(width: 6),
                              Text(
                                isEn ? 'Immigration Audit Warning:' : 'Aviso de Riesgo ante Inmigración:',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Colors.orange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...riskWarnings.map((warn) => Text(
                            warn,
                            style: const TextStyle(fontSize: 11.5, color: Colors.brown, height: 1.3),
                          )),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isEn
                                  ? '✓ Audit-Proof Entry: Verified LIN 22/050 code, 11-digit ABN, and full-time compliant shift (~${avgHoursPerDay.toStringAsFixed(1)}h/day).'
                                  : '✓ Registro Blindado: Código regional LIN 22/050 conforme, ABN válido de 11 dígitos y ratio horario legal (~${avgHoursPerDay.toStringAsFixed(1)}h/día).',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.secondary, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),

                  // 10. Botones Cancelar / Guardar Empleo
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            isEn ? 'Cancel' : 'Cancelar',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blockingErrors.isNotEmpty ? AppColors.textMuted : AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (blockingErrors.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.statusClosed,
                                  content: Text(
                                    blockingErrors.first,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                              return;
                            }

                            if (!isPremium && (currentTotalDays + days > 10)) {
                              Navigator.pop(ctx);
                              showPhase2PaywallBottomSheet(
                                context: context,
                                featureTitle: isEn ? '10-Day Free Limit Reached' : 'Límite Gratuito de 10 Días',
                                featureBenefit: isEn
                                    ? 'Free tier includes tracking up to 10 days. Upgrade to Premium to log all ${_targetVisaYear == 2 ? 88 : 179} days and export Form 1263.'
                                    : 'Superas los 10 días gratuitos. Pasa a Premium para registrar los ${_targetVisaYear == 2 ? 88 : 179} días completos y generar el Formulario 1263.',
                              );
                              return;
                            }

                            final userGross = double.tryParse(grossPayCtrl.text.trim()) ?? estGross;
                            final entry = RegionalJobEntry(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              targetVisaYear: _targetVisaYear,
                              employerBusinessName: nameClean,
                              employerAbn: abnClean,
                              workSitePostcode: pCode,
                              workSiteLocation: locationCtrl.text.trim().isNotEmpty
                                  ? locationCtrl.text.trim()
                                  : (resolvedPostcode?.location ?? 'Regional Area'),
                              industry: selectedIndustry,
                              jobRole: roleCtrl.text.trim().isNotEmpty
                                  ? roleCtrl.text.trim()
                                  : 'Specified Worker',
                              startDate: startDate,
                              endDate: endDate,
                              totalDaysCounted: days,
                              totalHours: hours,
                              grossEarningsAud: userGross,
                              isFullTimeWeekly: isFullTimeWeekly,
                              hasPieceworkAgreement: hasPieceworkAgreement,
                              payslipFileRef: payslipRefCtrl.text.trim().isNotEmpty
                                  ? payslipRefCtrl.text.trim()
                                  : null,
                            );

                            ref.read(regionalJobsProvider.notifier).addJob(
                              entry,
                              uid: uid,
                              isPremium: isPremium,
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.secondary,
                                content: Text(
                                  isEn ? '✓ Regional job entry recorded and audit-verified!' : '✓ Empleo regional registrado y validado para auditoría!',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            isEn ? 'Save & Audit Job' : 'Guardar y Validar Empleo',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDossierExportSheet({
    required bool isEn,
    required List<RegionalJobEntry> jobs,
    required int totalDays,
    required String visaSubclass,
    required String defaultEmail,
  }) {
    final defaultName = defaultEmail.contains('@') ? defaultEmail.split('@').first : defaultEmail;
    final nameCtrl = TextEditingController(text: defaultName);
    final passportCtrl = TextEditingController();
    final grantCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: defaultEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isFormValid = nameCtrl.text.trim().isNotEmpty && passportCtrl.text.trim().isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(CupertinoIcons.doc_text_fill, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn
                                  ? (_targetVisaYear == 2 ? 'Form 1263 Dossier (2nd Year)' : 'Form 1263 Dossier (3rd Year)')
                                  : (_targetVisaYear == 2 ? 'Dossier Formulario 1263 (2º Año)' : 'Dossier Formulario 1263 (3r Año)'),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                            ),
                            Text(
                              isEn
                                  ? 'Enter your official applicant details for ImmiAccount verification'
                                  : 'Introduce tus datos oficiales reales para la verificación en Inmigración',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      labelText: isEn ? 'Full Legal Name (as in Passport) *' : 'Nombre Legal Completo (según Pasaporte) *',
                      prefixIcon: const Icon(CupertinoIcons.person_fill, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passportCtrl,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      labelText: isEn ? 'Passport Number *' : 'Número de Pasaporte *',
                      hintText: isEn ? 'e.g. YB1234567' : 'ej: YB1234567',
                      prefixIcon: const Icon(CupertinoIcons.creditcard_fill, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: grantCtrl,
                          decoration: InputDecoration(
                            labelText: isEn ? 'Visa Grant No. (Optional)' : 'Nº Concesión Visado (Opcional)',
                            hintText: 'ej: 1398247012',
                            prefixIcon: const Icon(CupertinoIcons.shield_lefthalf_fill, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: isEn ? 'Australian Phone' : 'Teléfono Australiano',
                            hintText: '+61 412 345 678',
                            prefixIcon: const Icon(CupertinoIcons.phone_fill, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: isEn ? 'Contact Email (ImmiAccount)' : 'Email de Contacto (ImmiAccount)',
                      prefixIcon: const Icon(CupertinoIcons.mail_solid, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.lock_shield_fill, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isEn
                                ? 'No mock data is generated. The PDF table will contain only the verified jobs, exact ABNs and hours you entered.'
                                : 'Sin datos inventados. El PDF incluirá únicamente los empleos, ABNs reales y horas que has registrado.',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.secondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          child: Text(isEn ? 'Cancel' : 'Cancelar', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(CupertinoIcons.printer_fill, size: 18),
                          label: Text(isEn ? 'Generate Official PDF' : 'Generar PDF Oficial', style: const TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFormValid ? AppColors.primary : AppColors.textMuted,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: !isFormValid
                              ? null
                              : () async {
                                  Navigator.pop(sheetCtx);
                                  final pdfBytes = await PdfGeneratorService.generateRegionalDossier(
                                    applicantName: nameCtrl.text.trim(),
                                    passportNumber: passportCtrl.text.trim(),
                                    visaSubclass: visaSubclass,
                                    jobs: jobs,
                                    totalDays: totalDays,
                                    targetYear: _targetVisaYear,
                                    visaGrantNumber: grantCtrl.text.trim().isNotEmpty ? grantCtrl.text.trim() : null,
                                    contactEmail: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                                    contactPhone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                                  );
                                  final pdfFileName = _targetVisaYear == 2 ? 'Form_1263_2ndYear_Dossier.pdf' : 'Form_1263_3rdYear_Dossier.pdf';
                                  await PdfGeneratorService.shareOrPrintPdf(pdfBytes, pdfFileName);
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
