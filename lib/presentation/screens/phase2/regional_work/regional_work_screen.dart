import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  : (isEn ? '🗓️ Work Log ($totalDays/88)' : '🗓️ Contador ($totalDays/88)'),
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

        // MATRIZ COMPLETA DE ELEGIBILIDAD POR INDUSTRIA (LIN 22/050)
        Text(
          isEn ? 'Industry Eligibility Matrix (LIN 22/050)' : 'Matriz de Elegibilidad por Industria (LIN 22/050)',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          isEn
              ? 'Real-time breakdown of which jobs qualify in this postcode under your active visa subclass.'
              : 'Desglose oficial de qué sectores computan legalmente en esta zona para tu visado.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        _buildIndustryEligibilityMatrix(isEn, subclass, _searchResult),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildIndustryEligibilityMatrix(bool isEn, String subclass, PostcodeInfo? postcode) {
    final industries = [
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

    return Column(
      children: industries.map((ind) {
        final isEligible = ind['eligible'] as bool;
        final icon = ind['icon'] as String;
        final name = ind['name'] as String;
        final desc = ind['desc'] as String;
        final tip = ind['legalTip'] as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEligible ? AppColors.secondary.withValues(alpha: 0.35) : AppColors.cardBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isEligible
                          ? AppColors.secondary.withValues(alpha: 0.12)
                          : AppColors.statusClosed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isEligible
                            ? AppColors.secondary.withValues(alpha: 0.4)
                            : AppColors.statusClosed.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      isEligible ? (isEn ? 'ELIGIBLE' : 'VÁLIDO') : (isEn ? 'INELIGIBLE' : 'NO VÁLIDO'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(
                '⚖️ $tip',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isEligible ? AppColors.secondary : AppColors.statusClosed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkLogTab(bool isEn, bool isPremium, List<RegionalJobEntry> jobs, int totalDays, String applicantEmail, String visaSubclass) {
    final maxTarget = isPremium ? 88 : 10;
    final progress = (totalDays / maxTarget.toDouble()).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Tarjeta de progreso 88 Días
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
                        : (isEn ? '2nd Year Visa Progress' : 'Progreso 2º Año de Visa'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                  ),
                  Text(
                    !isPremium ? '$totalDays / 10' : '$totalDays / 88 ${isEn ? "days" : "días"}',
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
                        ? (isEn ? '🔒 Free trial limit reached! Unlock the complete 88 days with Premium.' : '🔒 ¡Límite gratuito de 10 días alcanzado! Desbloquea los 88 días con Premium.')
                        : (isEn ? '${10 - totalDays} free trial days remaining to log.' : 'Te quedan ${10 - totalDays} días de prueba gratuita por registrar.'))
                    : (totalDays >= 88
                        ? (isEn ? '🎉 Goal reached! Ready to lodge your 2nd year visa.' : '🎉 ¡Meta alcanzada! Listo para solicitar tu 2º año.')
                        : (isEn ? '${88 - totalDays} days remaining to complete.' : 'Faltan ${88 - totalDays} días para completar la extensión.')),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              // Banner Promocional Freemium para Desbloquear los 88 Días
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
                              ? 'Log all 88 days and generate official Form 1263 immigration PDF dossiers with Premium.'
                              : 'Registra los 88 días al completo y genera el dossier oficial del Formulario 1263 con Premium.',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => showPhase2PaywallBottomSheet(
                          context: context,
                          featureTitle: isEn ? '88-Day Tracker & Form 1263' : 'Contador 88 Días y Form 1263',
                          featureBenefit: isEn
                              ? 'Track all 88 days, verify employer ABNs, and export official Form 1263 immigration dossiers.'
                              : 'Registra los 88 días al completo y descarga el Formulario 1263 oficial listo para ImmiAccount.',
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
                      ? 'You have recorded 10 free trial days. Upgrade to Premium to log the complete 88 days and generate your Form 1263 dossier.'
                      : 'Has registrado los 10 días de prueba gratuitos. Pasa a Premium para registrar los 88 días completos y generar el Formulario 1263 oficial.',
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
                  featureTitle: isEn ? 'Form 1263 Immigration Dossier' : 'Dossier Formulario 1263',
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
              );

              await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Form_1263_Dossier.pdf');
            },
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
                      ? 'Free tier includes tracking up to 10 days. Upgrade to Premium to log the complete 88 days and export official Form 1263 PDF dossiers.'
                      : 'Has intentado superar los 10 días de la versión gratuita. Pasa a Premium para registrar los 88 días completos y generar el Formulario 1263 oficial.',
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
