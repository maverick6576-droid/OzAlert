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

    if (uid != null && uid.isNotEmpty) {
      Future.microtask(() {
        ref.read(regionalJobsProvider.notifier).loadForUser(uid: uid, isPremium: isPremium);
      });
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
        // Cabecera Explicativa Oficial: Actualizada con Specified Subclass 462 Work (Home Affairs)
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
                            isEn
                                ? 'Official Home Affairs Postcode & Industry Validator'
                                : 'Validador Oficial de Códigos y Zonas (Home Affairs)',
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
                          ? 'Updated with official Specified Subclass 462 Work tables (Tables 1 to 6, including 5 April 2025 disaster recovery updates): check any postcode for Tourism & Hospitality (North/Remote), Agriculture & Construction (Regional), Fishing & Forestry (North), Bushfire/Flood Recovery and Healthcare.'
                          : 'Actualizado con las Tablas 1 a 6 de Specified Subclass 462 Work del Department of Home Affairs (incluyendo la reforma del 5 de abril de 2025): comprueba al instante cualquier código postal para Turismo/Hostelería (Norte y Remoto), Agricultura/Construcción (Regional), Pesca/Silvicultura (Norte), Recuperación de Incendios/Inundaciones y Salud.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subclass == '462'
                            ? (isEn
                                ? 'Subclass 462: 8 approved industries • Tourism/Hospitality counts in Northern & Remote/Very Remote Australia (Tables 1, 2 & 3). Mining is 417 only.'
                                : 'Subclase 462: 8 sectores oficiales • Hostelería/Turismo computa en el Norte y Zonas Remotas/Muy Remotas (Tablas 1, 2 y 3). Minería es exclusiva de 417.')
                            : (isEn
                                ? 'Subclass 417: Agriculture, Construction, Mining, Fishing & Forestry in Regional Australia.'
                                : 'Subclase 417: Agricultura, Construcción, Minería, Pesca y Silvicultura en Australia Regional.'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.3),
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

        // RESUMEN EJECUTIVO DE ELEGIBILIDAD POR INDUSTRIA (Home Affairs Specified Work)
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
                    ? 'Enter any 4-digit postcode or tap the map to check official Home Affairs rules.'
                    : 'Introduce un código postal de 4 dígitos o pulsa en el mapa para validar la normativa de Home Affairs.',
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
    final fishForestValid = result.isEligible(subclass, 'fishing');
    final bushfireValid = result.isEligible(subclass, 'bushfire_recovery');
    final floodValid = result.isEligible(subclass, 'flood_recovery');

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
                      '${_getStateFullName(result.state, isEn)} • Zona: ${isNorthern ? (isEn ? 'Northern Australia (Table 3)' : 'Norte de Australia (Tabla 3)') : isRemote ? (isEn ? 'Remote / Very Remote (Tables 1 & 2)' : 'Remota / Muy Remota (Tablas 1 y 2)') : isRegional ? (isEn ? 'Regional Australia (Table 4)' : 'Australia Regional (Tabla 4)') : (isEn ? 'Metropolitan / Non-Regional' : 'Área Metropolitana / No Regional')}',
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
                      : (isEn ? '✕ METRO' : '✕ METRO'),
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
                label: isEn ? 'Hospitality & Tourism' : 'Hostelería y Turismo',
                isValid: hospValid,
                note: subclass == '417' ? (isEn ? '462 only' : 'Solo 462') : (!isNorthern && !isRemote ? (isEn ? 'North/Remote only' : 'Solo Norte/Remoto') : null),
              ),
              _buildSearchChip(
                icon: '🎣',
                label: isEn ? 'Fishing & Forestry' : 'Pesca y Silvicultura',
                isValid: fishForestValid,
                note: subclass == '462' && !isNorthern ? (isEn ? 'North only' : 'Solo Norte') : null,
              ),
              if (bushfireValid)
                _buildSearchChip(
                  icon: '🔥',
                  label: isEn ? 'Bushfire (Table 5)' : 'Incendios (Tabla 5)',
                  isValid: true,
                ),
              if (floodValid)
                _buildSearchChip(
                  icon: '🌊',
                  label: isEn ? 'Flood/Disaster (Table 6)' : 'Inundaciones (Tabla 6)',
                  isValid: true,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isRegional
                ? (isEn
                    ? 'Official eligible regional postcode under Home Affairs Specified Work tables. Days worked in valid industries count towards your 88 or 179 days.'
                    : 'Código postal regional oficial de Home Affairs. Los días trabajados en las industrias marcadas en verde computan para tus 88 o 179 días.')
                : ((bushfireValid || floodValid)
                    ? (isEn
                        ? 'Metropolitan postcode: regular farming/hospitality/construction DOES NOT count here, EXCEPT declared Disaster/Bushfire Recovery (Tables 5/6) or COVID-19 Healthcare.'
                        : 'Código metropolitano: agricultura, obra u hostelería ordinaria NO computan aquí, EXCEPTO recuperación oficial de desastres/incendios (Tablas 5/6) o salud COVID-19.')
                    : (isEn
                        ? 'Metropolitan area: standard work performed here DOES NOT count towards 88/179 day visa renewal (only critical COVID-19 medical work applies nationwide).'
                        : 'Zona metropolitana: el trabajo ordinario aquí NO computa para renovar tus 88/179 días (únicamente salud crítica COVID-19 aplica en todo el país).')),
            style: TextStyle(
              fontSize: 11,
              color: isRegional ? AppColors.textSecondary : const Color(0xFFC0392B),
              fontWeight: isRegional ? FontWeight.normal : FontWeight.w600,
              height: 1.35,
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
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isValid ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
            size: 12,
            color: color,
          ),
          if (note != null) ...[
            const SizedBox(width: 3),
            Flexible(
              child: Text('($note)', style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w600)),
            ),
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
    return [
      {
        'id': 'tourism_hospitality',
        'icon': '☕',
        'name': isEn ? 'Tourism & Hospitality' : 'Turismo y Hostelería',
        'tableRef': isEn ? 'Tables 1, 2 & 3 (Northern & Remote/Very Remote)' : 'Tablas 1, 2 y 3 (Norte y Zonas Remotas / Muy Remotas)',
        'desc': isEn
            ? '• Accommodation: hotels, motels, B&Bs, backpacker hostels, caravan parks, camping grounds, commercial housekeeping, boarding houses & reception centres.\n• Food & Beverage: cafes, restaurants, takeaway food services, catering, pubs, taverns, bars and hospitality clubs.\n• Tourist Services: tour guides/operators, outdoor adventure or dive instructors, tourist transport/bus drivers, gallery/museum workers, travel agencies & event/entertainment venues.'
            : '• Alojamiento: hoteles, moteles, B&B, hostels de mochileros, caravan parks, campings, housekeeping comercial y centros de recepción.\n• Comida y Bebida: cafeterías, restaurantes, comida para llevar, catering, pubs, tabernas, bares y clubes de hostelería.\n• Servicios Turísticos: guías y operadores de tours, instructores de buceo o aventura, transporte/autobuses turísticos, museos/galerías, agencias de viajes y eventos.',
        'exclusions': isEn
            ? 'Does NOT include: wineries/breweries/distilleries that do not predominantly provide tourist services; general cleaning, retail, transport or security companies not primarily serving tourists; schools/student residences.'
            : 'NO incluye: bodegas, cervecerías o destilerías que no presten principalmente servicios turísticos (ej. cata/cellar door); empresas generales de limpieza, tiendas, transporte o seguridad; residencias estudiantiles.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'tourism_hospitality'),
        'legalTip': subclass == '462'
            ? (postcode?.isEligible(subclass, 'tourism_hospitality') == true
                ? (isEn
                    ? 'ELIGIBLE: Postcode is in Northern Australia (Table 3) or Remote / Very Remote Australia (Tables 1 & 2).'
                    : 'VÁLIDO: El código postal pertenece al Norte de Australia (Tabla 3) o a Australia Remota / Muy Remota (Tablas 1 y 2).')
                : (isEn
                    ? 'INELIGIBLE HERE: For Subclass 462, tourism & hospitality ONLY qualifies in Northern Australia (Table 3) or Remote & Very Remote Australia (Tables 1 & 2).'
                    : 'NO VÁLIDO AQUÍ: En la Subclase 462, turismo y hostelería SOLO computa en el Norte de Australia (Tabla 3) o en áreas Remotas y Muy Remotas (Tablas 1 y 2).'))
            : (isEn
                ? 'NOTE (417): Verify Northern/Remote postcode eligibility under your subclass.'
                : 'NOTA (417): En nuestro filtro diferenciamos la ventaja clave de la Subclase 462 en Norte y Zonas Remotas.'),
      },
      {
        'id': 'agriculture',
        'icon': '🌾',
        'name': isEn ? 'Plant & Animal Cultivation' : 'Cultivo de Plantas y Ganadería',
        'tableRef': isEn ? 'Tables 3 & 4 (Northern & Regional Australia)' : 'Tablas 3 y 4 (Norte de Australia y Australia Regional)',
        'desc': isEn
            ? '• Harvesting and/or packing fruit and vegetable crops.\n• Pruning and trimming vines and trees (must be commercial horticultural activities and your primary task).\n• General crop maintenance, cultivating/propagating plants or fungi.\n• Maintaining animals for commercial sale or bodily produce, horse breeding/stud farming, cattle herding & feedlots.\n• Immediate processing of animal products (shearing, butchery, packing, tanning) and manufacturing dairy products from raw material.\n• Conservation, environmental reforestation and zoo plant/animal cultivation.'
            : '• Cosecha (picking) y/o empaquetado (packing) de frutas y verduras.\n• Poda y recorte de viñedos y árboles (debe ser horticultura comercial y tu tarea principal, no jardinería doméstica).\n• Mantenimiento general de cultivos, propagación de plantas u hongos.\n• Cría de animales para venta comercial o sus productos, cría de caballos, pastoreo de ganado (cattle herding) y feedlots.\n• Procesamiento inmediato de productos animales (esquila, carnicería primaria, empaquetado, curtido) y fabricación de lácteos desde materia prima.\n• Conservación ambiental, reforestación y cuidado de fauna/flora en zoológicos.',
        'exclusions': isEn
            ? 'Does NOT include: secondary processing (winemaking, brewing, distillation, milling, manufacturing small goods, or retail of dairy/butchery products) or domestic garden maintenance.'
            : 'NO incluye: procesamiento secundario (elaboración de vino, cerveza, destilación, molienda, embutidos o venta minorista de lácteos/carnicería) ni jardinería doméstica.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'agriculture'),
        'legalTip': postcode?.isEligible(subclass, 'agriculture') == true
            ? (isEn
                ? 'ELIGIBLE: Postcode is approved in Northern Australia (Table 3) or Regional Australia (Table 4) for both 462 and 417.'
                : 'VÁLIDO: Código postal aprobado en Norte de Australia (Tabla 3) o Australia Regional (Tabla 4) para subclases 462 y 417.')
            : (isEn
                ? 'INELIGIBLE HERE: Metropolitan postcode outside Table 3 and Table 4.'
                : 'NO VÁLIDO AQUÍ: Código postal metropolitano fuera de las Tablas 3 y 4.'),
      },
      {
        'id': 'construction',
        'icon': '🏗️',
        'name': isEn ? 'Construction' : 'Construcción y Obras',
        'tableRef': isEn ? 'Tables 3 & 4 (Northern & Regional Australia)' : 'Tablas 3 y 4 (Norte de Australia y Australia Regional)',
        'desc': isEn
            ? '• Residential and non-residential building construction.\n• Heavy and civil engineering construction.\n• Land development and site preparation services.\n• Building structure, installation and completion services: landscaping on construction sites, painting new buildings, erecting fences on construction sites, scaffolding, and site support/cleaning services.'
            : '• Construcción de edificios residenciales y no residenciales.\n• Ingeniería civil y construcción pesada.\n• Urbanización de terrenos y preparación de solares.\n• Estructura, instalación y acabado de obra: paisajismo en solares en construcción, pintura de obra nueva, vallado de obras, andamiaje (scaffolding) y servicios de apoyo/limpieza de obra.',
        'exclusions': isEn
            ? 'Does NOT include: ship or boat building; manufacturing materials used in construction (such as steel or concrete manufacturing); mining operations.'
            : 'NO incluye: construcción naval o de barcos; fabricación en planta de materiales de construcción (como acero u hormigón); ni operaciones mineras.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'construction'),
        'legalTip': postcode?.isEligible(subclass, 'construction') == true
            ? (isEn
                ? 'ELIGIBLE: Approved in Northern Australia (Table 3) and Regional Australia (Table 4).'
                : 'VÁLIDO: Aprobado en Norte de Australia (Tabla 3) y Australia Regional (Tabla 4).')
            : (isEn
                ? 'INELIGIBLE HERE: Metropolitan postcode outside Table 3 and Table 4.'
                : 'NO VÁLIDO AQUÍ: Código postal metropolitano fuera de las Tablas 3 y 4.'),
      },
      {
        'id': 'fishing',
        'icon': '🎣',
        'name': isEn ? 'Fishing & Pearling' : 'Pesca y Perlas',
        'tableRef': subclass == '462'
            ? (isEn ? 'Table 3 ONLY (Northern Australia)' : 'SOLO Tabla 3 (Norte de Australia)')
            : (isEn ? 'Tables 3 & 4 (Regional Australia)' : 'Tablas 3 y 4 (Australia Regional)'),
        'desc': isEn
            ? '• Conducting operations relating directly to taking or catching fish and other aquatic species.\n• Taking or culturing pearls or pearl shell.'
            : '• Operaciones directamente relacionadas con la captura o pesca comercial de peces y otras especies acuáticas.\n• Extracción o cultivo de perlas y nácar (pearling).',
        'exclusions': isEn
            ? 'For Subclass 462, Fishing & Pearling is strictly restricted to Northern Australia (Table 3: all of NT, plus approved northern postcodes in QLD and WA).'
            : 'Para la Subclase 462, la pesca y cultivo de perlas solo es válida en el Norte de Australia (Tabla 3: todo NT y códigos del norte de QLD y WA).',
        'eligible': postcode != null && postcode.isEligible(subclass, 'fishing'),
        'legalTip': subclass == '462'
            ? (postcode?.isEligible(subclass, 'fishing') == true
                ? (isEn ? 'ELIGIBLE: Located in Northern Australia (Table 3).' : 'VÁLIDO: Ubicado en el Norte de Australia (Tabla 3).')
                : (isEn ? 'INELIGIBLE HERE: Under Subclass 462, fishing & pearling ONLY counts in Northern Australia (Table 3).' : 'NO VÁLIDO AQUÍ: En la Subclase 462, pesca y perlas SOLO computa en el Norte de Australia (Tabla 3).'))
            : (postcode?.isEligible(subclass, 'fishing') == true
                ? (isEn ? 'ELIGIBLE: Approved across Regional Australia for Subclass 417.' : 'VÁLIDO: Aprobado en Australia Regional para Subclase 417.')
                : (isEn ? 'INELIGIBLE HERE: Metropolitan area.' : 'NO VÁLIDO AQUÍ: Área metropolitana.')),
      },
      {
        'id': 'forestry',
        'icon': '🌲',
        'name': isEn ? 'Tree Farming & Felling' : 'Silvicultura y Tala',
        'tableRef': subclass == '462'
            ? (isEn ? 'Table 3 ONLY (Northern Australia)' : 'SOLO Tabla 3 (Norte de Australia)')
            : (isEn ? 'Tables 3 & 4 (Regional Australia)' : 'Tablas 3 y 4 (Australia Regional)'),
        'desc': isEn
            ? '• Planting or tending trees in a plantation or forest that are intended to be felled.\n• Felling trees in a plantation or forest.\n• Transporting felled trees or parts of trees from the plantation/forest to where they are first milled or processed.'
            : '• Plantación o cuidado de árboles en plantaciones o bosques destinados a la tala.\n• Tala de árboles en plantaciones o bosques.\n• Transporte de troncos talados desde el bosque hasta su primera serrería o planta de procesado.',
        'exclusions': isEn
            ? 'For Subclass 462, Tree Farming & Felling is strictly restricted to Northern Australia (Table 3).'
            : 'Para la Subclase 462, la silvicultura y tala de árboles solo es válida en el Norte de Australia (Tabla 3).',
        'eligible': postcode != null && postcode.isEligible(subclass, 'forestry'),
        'legalTip': subclass == '462'
            ? (postcode?.isEligible(subclass, 'forestry') == true
                ? (isEn ? 'ELIGIBLE: Located in Northern Australia (Table 3).' : 'VÁLIDO: Ubicado en el Norte de Australia (Tabla 3).')
                : (isEn ? 'INELIGIBLE HERE: Under Subclass 462, tree farming & felling ONLY counts in Northern Australia (Table 3).' : 'NO VÁLIDO AQUÍ: En la Subclase 462, silvicultura y tala SOLO computa en el Norte de Australia (Tabla 3).'))
            : (postcode?.isEligible(subclass, 'forestry') == true
                ? (isEn ? 'ELIGIBLE: Approved across Regional Australia for Subclass 417.' : 'VÁLIDO: Aprobado en Australia Regional para Subclase 417.')
                : (isEn ? 'INELIGIBLE HERE: Metropolitan area.' : 'NO VÁLIDO AQUÍ: Área metropolitana.')),
      },
      {
        'id': 'bushfire_recovery',
        'icon': '🔥',
        'name': isEn ? 'Bushfire Recovery' : 'Recuperación de Incendios',
        'tableRef': isEn ? 'Table 5 (Bushfire Declared Areas - post 31 Jul 2019)' : 'Tabla 5 (Áreas Declaradas de Incendio - desde 31 jul 2019)',
        'desc': isEn
            ? '• Paid or volunteer recovery work carried out after 31 July 2019 in Table 5 declared areas (updated 5 April 2025).\n• Construction, farming, or any work in association with restitution/restoration of land, property, farm animals or wildlife.\n• Providing support services or assistance to people living, working or volunteering in affected areas.'
            : '• Trabajo remunerado o voluntario realizado tras el 31 de julio de 2019 en las zonas declaradas de la Tabla 5 (actualizada el 5 de abril de 2025).\n• Construcción, agricultura o cualquier labor de restitución y restauración de tierras, propiedades, ganado o fauna silvestre.\n• Servicios de apoyo y asistencia a personas que viven, trabajan o son voluntarias en las zonas afectadas.',
        'exclusions': isEn
            ? 'Does NOT include: hospitality, cleaning or administrative work for a business that is not directly affected by a bushfire or where work is not a direct consequence of bushfire damage.'
            : 'NO incluye: trabajo de hostelería, limpieza o administración para negocios que no hayan sido afectados directamente por el incendio forestal.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'bushfire_recovery'),
        'legalTip': postcode?.isEligible(subclass, 'bushfire_recovery') == true
            ? (isEn
                ? 'ELIGIBLE (Table 5): This postcode is an official Bushfire Declared Area.'
                : 'VÁLIDO (Tabla 5): Este código postal está incluido en la Tabla 5 oficial de zonas declaradas de incendio.')
            : (isEn
                ? 'INELIGIBLE HERE: Postcode is not listed in Table 5 (Bushfire declared areas).'
                : 'NO VÁLIDO AQUÍ: Este código postal no figura en la Tabla 5 de zonas declaradas por incendio.'),
      },
      {
        'id': 'flood_recovery',
        'icon': '🌊',
        'name': isEn ? 'Flood & Disaster Recovery' : 'Inundaciones y Desastres',
        'tableRef': isEn ? 'Table 6 (Natural Disaster Declared Areas - post 31 Dec 2021)' : 'Tabla 6 (Zonas de Desastre Natural - desde 31 dic 2021)',
        'desc': isEn
            ? '• Paid or volunteer recovery work from 31 Dec 2021 in areas affected by flood, cyclone or severe weather (Table 6, effective 5 April 2025).\n• Clean-up, rubbish transport, building demolition, trench digging, tree removal and earth moving.\n• Construction/repair of buildings, roads, footpaths, bridges, utilities and fences.\n• Charity, administrative, call-centre, customer service, coordination & delivery support for affected communities.\n• Caring for, transporting and rehabilitating affected animals.\n• In ImmiAccount select "flood recovery - paid" or "flood recovery - volunteer".'
            : '• Trabajo remunerado o voluntario desde el 31 de diciembre de 2021 en zonas afectadas por inundaciones, ciclones o clima severo (Tabla 6, vigente desde el 5 de abril de 2025).\n• Limpieza general, retirada de escombros, demolición, excavación de zanjas, retirada de árboles y movimiento de tierras.\n• Reparación o reconstrucción de viviendas, carreteras, puentes, suministros y vallas.\n• Apoyo caritativo, administrativo, call-centre, atención al afectado, coordinación y entregas en comunidades damnificadas, así como rescate de animales.\n• En ImmiAccount debes seleccionar "flood recovery - paid" o "flood recovery - volunteer".',
        'exclusions': isEn
            ? 'Does NOT include: hospitality, cleaning or administrative work for a business not affected by a natural disaster.'
            : 'NO incluye: hostelería, limpieza o administración en empresas que no hayan sido afectadas por el desastre natural.',
        'eligible': postcode != null && postcode.isEligible(subclass, 'flood_recovery'),
        'legalTip': postcode?.isEligible(subclass, 'flood_recovery') == true
            ? (isEn
                ? 'ELIGIBLE (Table 6): This postcode is an official Natural Disaster Declared Area.'
                : 'VÁLIDO (Tabla 6): Este código postal está incluido en la Tabla 6 oficial de zonas declaradas por desastre natural / inundación.')
            : (isEn
                ? 'INELIGIBLE HERE: Postcode is not listed in Table 6 (Natural disaster declared areas).'
                : 'NO VÁLIDO AQUÍ: Este código postal no figura en la Tabla 6 de desastres naturales.'),
      },
      {
        'id': 'healthcare_covid',
        'icon': '🏥',
        'name': isEn ? 'COVID-19 Healthcare & Medical' : 'Salud y Sector Médico COVID-19',
        'tableRef': isEn ? 'Anywhere in Australia (All Postcodes - post 31 Jan 2020)' : 'En toda Australia (Todos los CP - desde 31 ene 2020)',
        'desc': isEn
            ? '• Medical treatment, nursing, contact tracing, testing and research directly involved in the response to COVID-19.\n• Support services such as cleaning of medical and healthcare facilities and equipment directly involved in responding to COVID-19.'
            : '• Tratamiento médico, enfermería, rastreo de contactos, pruebas diagnósticas e investigación en respuesta directa al COVID-19.\n• Servicios de soporte como limpieza de centros médicos, hospitales y equipamiento sanitario vinculados a la respuesta COVID-19.',
        'exclusions': isEn
            ? 'Does NOT include: General Allied Health (physiotherapy, speech pathology, chiropractic), mental health not related to COVID-19, aged/disability care not responding to a COVID-19 outbreak, medical/vet manufacturing, medical reception/admin, or cleaning non-medical facilities.'
            : 'NO incluye: fisioterapia, logopedia, quiropráctica, cuidado de mayores/discapacidad sin brote de COVID-19, fabricación farmacéutica, recepción/administración médica ni limpieza de centros no médicos.',
        'eligible': true,
        'legalTip': isEn
            ? 'ELIGIBLE NATIONWIDE: Critical COVID-19 medical and healthcare work qualifies anywhere in Australia (including metropolitan cities).'
            : 'VÁLIDO EN TODA AUSTRALIA: El trabajo sanitario crítico COVID-19 computa en cualquier código postal de Australia (incluidas capitales metropolitanas).',
      },
      if (subclass == '417')
        {
          'id': 'mining',
          'icon': '⛏️',
          'name': isEn ? 'Mining (Subclass 417 Only)' : 'Minería (Solo Subclase 417)',
          'tableRef': isEn ? 'Tables 3 & 4 (Regional Australia - 417 Only)' : 'Tablas 3 y 4 (Australia Regional - Exclusivo 417)',
          'desc': isEn
              ? '• Coal mining, oil and gas extraction, metal ore mining, construction material mining, exploración and mining support services.'
              : '• Extracción de carbón, petróleo y gas, minerales metálicos, canteras, exploración y servicios de soporte minero.',
          'exclusions': isEn
              ? 'IMPORTANT: Mining is ONLY approved for Working Holiday Subclass 417. It is NOT an eligible industry for Work and Holiday Subclass 462.'
              : 'IMPORTANTE: La minería está aprobada ÚNICAMENTE para la Subclase 417. NO es una industria válida para la Subclase 462 según Home Affairs.',
          'eligible': postcode != null && postcode.isEligible(subclass, 'mining'),
          'legalTip': postcode?.isEligible(subclass, 'mining') == true
              ? (isEn ? 'ELIGIBLE: Approved for Subclass 417 in Regional Australia.' : 'VÁLIDO: Aprobado para la Subclase 417 en Australia Regional.')
              : (isEn ? 'INELIGIBLE: Metropolitan area.' : 'NO VÁLIDO: En áreas metropolitanas.'),
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
              Expanded(
                child: Row(
                  children: [
                    const Text('🏛️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEn ? 'Official Industry Eligibility (Home Affairs)' : 'Elegibilidad por Industria (Home Affairs)',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                ? 'Approved industries for postcode ${_postcodeController.text} under Visa Subclass $subclass (tap any sector in the guide below for full role lists and exclusions):'
                : 'Sectores aprobados para el CP ${_postcodeController.text} bajo la Subclase $subclass (incluye las 8 industrias oficiales de Specified Subclass 462 Work):',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: industries.map((ind) {
              final isEligible = ind['eligible'] as bool;
              final icon = ind['icon'] as String;
              final fullName = ind['name'] as String;
              return InkWell(
                onTap: () => _showIndustryDetailsModal(context, ind, isEn, isEligible, subclass),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isEligible ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isEligible ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                        size: 12,
                        color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.sparkles, size: 15, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Home Affairs Flexibility Rule: Work supporting the ongoing operations of a specified industry (such as administrative or cleaning support services at an eligible farm, hotel or construction site) in an eligible postcode may be accepted.'
                        : 'Criterio de Flexibilidad de Home Affairs: El trabajo de apoyo a las operaciones de una industria elegible (como soporte administrativo o limpieza dentro de una granja, hotel u obra en un código postal válido) también puede ser aceptado.',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(CupertinoIcons.doc_text_search, size: 16),
              label: Text(
                isEn
                    ? 'View All Industries, Tables 1–6 & Official Rules'
                    : 'Ver Detalle de Industrias, Tablas 1–6 y Normativa',
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
          height: MediaQuery.of(context).size.height * 0.90,
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
                            isEn ? 'Specified Subclass 462 Work (Home Affairs)' : 'Trabajo Especificado Subclase 462 (Home Affairs)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            isEn
                                ? 'Postcode ${_postcodeController.text} • Visa Subclass $subclass • Tables 1 to 6'
                                : 'Código Postal ${_postcodeController.text} • Subclase $subclass • Tablas 1 a 6',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIndustryEligibilityMatrix(isEn, subclass, postcode),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn
                                  ? '📋 Key Official Rules (Specified Subclass 462 Work)'
                                  : '📋 Resumen Oficial de Requisitos (Home Affairs)',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEn
                                  ? '• 2nd Visa: Minimum 3 months (88 calendar days) of specified work.\n• 3rd Visa: Minimum 6 months (179 calendar days) of specified work on or after 1 July 2019.\n• Full-time equivalent: Working the standard full-time days/hours for that industry in a week (e.g. 5 days / 35–38h) counts as 7 calendar days.\n• Paid work & payslips: All specified work must be paid in accordance with Australian workplace law (except approved Bushfire/Flood recovery volunteer work).\n• Mining Note: Mining is ONLY eligible for Subclass 417, NOT Subclass 462.'
                                  : '• 2º Visado: Mínimo 3 meses (88 días naturales) de trabajo especificado.\n• 3r Visado: Mínimo 6 meses (179 días naturales) de trabajo especificado.\n• Regla de Semana Completa: Si trabajas la jornada semanal completa estándar de la industria (ej. 5 días / 35–38h), computan los 7 días de la semana.\n• Trabajo Remunerado: Debe pagarse según la ley australiana con nóminas/payslips (solo se admite voluntariado en recuperación oficial de incendios o inundaciones).\n• Nota sobre Minería: La minería SOLO computa para la Subclase 417, NO para la Subclase 462.',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(CupertinoIcons.link, size: 15, color: AppColors.primary),
                          label: Text(
                            isEn
                                ? 'Open Official Home Affairs Specified 462 Work Page'
                                : 'Abrir Web Oficial de Home Affairs (Specified 462 Work)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            UrlLauncherService.openUrl(
                              context,
                              'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/specified-462-work',
                            );
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
        childAspectRatio: 1.22,
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
                    Expanded(
                      child: Text(
                        isEn ? 'Tap for rules & roles' : 'Toca para ver puestos',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
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
    final tableRef = (ind['tableRef'] as String?) ?? '';
    final desc = ind['desc'] as String;
    final exclusions = (ind['exclusions'] as String?) ?? '';
    final tip = ind['legalTip'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          child: SingleChildScrollView(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          if (tableRef.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              tableRef,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? AppColors.secondary.withValues(alpha: 0.15)
                            : AppColors.statusClosed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isEligible ? (isEn ? '✓ ELIGIBLE' : '✓ VÁLIDO') : (isEn ? '✗ INELIGIBLE' : '✗ NO VÁLIDO'),
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
                  isEn ? 'Approved Roles & Activities (Home Affairs):' : 'Puestos y Actividades Aprobadas (Home Affairs):',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.45),
                ),
                if (exclusions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppColors.statusClosed.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusClosed.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? '⚠️ Official Exclusions (Does Not Count):' : '⚠️ Exclusiones Oficiales (No Computa):',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.statusClosed),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exclusions,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
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
                      isEn
                          ? 'Verify on Official Home Affairs Website'
                          : 'Consultar Web Oficial de Home Affairs (Specified 462 Work)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      UrlLauncherService.openUrl(
                        context,
                        'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/specified-462-work',
                      );
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
            {'id': 'agriculture', 'label': isEn ? '🌾 Plant & Animal Cultivation' : '🌾 Cultivo de Plantas y Ganadería'},
            {'id': 'tourism_hospitality', 'label': isEn ? '☕ Hospitality & Tourism' : '☕ Hostelería y Turismo'},
            {'id': 'construction', 'label': isEn ? '🏗️ Construction' : '🏗️ Construcción y Obras'},
            {'id': 'forestry_fishing', 'label': isEn ? '🎣 Fishing, Pearling & Forestry' : '🎣 Pesca, Perlas y Silvicultura'},
            {'id': 'bushfire_recovery', 'label': isEn ? '🔥 Bushfire Recovery (Table 5)' : '🔥 Recuperación de Incendios (Tabla 5)'},
            {'id': 'flood_recovery', 'label': isEn ? '🌊 Flood & Disaster Recovery (Table 6)' : '🌊 Inundaciones y Desastres (Tabla 6)'},
            {'id': 'healthcare_covid', 'label': isEn ? '🏥 COVID-19 Healthcare & Medical' : '🏥 Salud y Sector Médico COVID-19'},
            if (visaSubclass == '417')
              {'id': 'mining', 'label': isEn ? '⛏️ Mining (417 Only)' : '⛏️ Minería (Solo 417)'},
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
