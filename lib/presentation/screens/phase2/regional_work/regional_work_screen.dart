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

class RegionalWorkScreen extends ConsumerStatefulWidget {
  const RegionalWorkScreen({super.key});

  @override
  ConsumerState<RegionalWorkScreen> createState() => _RegionalWorkScreenState();
}

class _RegionalWorkScreenState extends ConsumerState<RegionalWorkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Validador de Códigos Postales
  final _postcodeController = TextEditingController(text: '4870');
  String _selectedIndustry = 'tourism_hospitality';
  PostcodeInfo? _searchResult;
  bool _hasSearched = false;

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
      _hasSearched = true;
    });
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
            Tab(text: isEn ? '📍 Postcode Checker' : '📍 Validador Códigos'),
            Tab(text: isEn ? '🗓️ Work Log ($totalDays/88)' : '🗓️ Contador ($totalDays/88)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // SUBMÓDULO 1: VALIDADOR DE CÓDIGOS POSTALES
          _buildPostcodeValidatorTab(isEn, subclass),

          // SUBMÓDULO 2: TRACKER DE DÍAS Y EXPORTACIÓN FORMULARIO 1263
          _buildWorkLogTab(isEn, isPremium, jobs, totalDays, userEmail, subclass),
        ],
      ),
    );
  }

  Widget _buildPostcodeValidatorTab(bool isEn, String subclass) {
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
        const SizedBox(height: 18),

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
                  labelText: isEn ? '4-Digit Postcode' : 'Código Postal (ej: 4870)',
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

        // Selector de Industria
        Text(
          isEn ? 'Industry of Employment' : 'Industria del Empleo',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildIndustryChoice('tourism_hospitality', isEn ? '☕ Hospitality / Tourism' : '☕ Hostelería y Turismo'),
            _buildIndustryChoice('agriculture', isEn ? '🌾 Agriculture / Farming' : '🌾 Agricultura y Cosecha'),
            _buildIndustryChoice('construction', isEn ? '🏗️ Construction' : '🏗️ Construcción'),
          ],
        ),
        const SizedBox(height: 18),

        // Resultado de Elegibilidad
        if (_hasSearched) ...[
          if (_searchResult == null) ...[
            _buildAlertCard(
              isEligible: false,
              title: isEn ? 'Postcode Not Regional or Unknown' : 'Código Postal No Válido o Desconocido',
              message: isEn
                  ? 'The postcode ${_postcodeController.text} does not appear in official regional instruments (LIN 22/050) for regional work extensions.'
                  : 'El código ${_postcodeController.text} no califica como área regional elegible según las listas oficiales de Inmigración.',
            ),
          ] else ...[
            Builder(builder: (ctx) {
              final isEligible = _searchResult!.isEligible(subclass, _selectedIndustry);

              String detailMessage = '';
              if (isEligible) {
                detailMessage = isEn
                    ? 'Eligible! Work in ${_searchResult!.location} in this industry satisfies the specified regional work requirement.'
                    : '¡Válido! Trabajar en ${_searchResult!.location} en este sector cuenta oficialmente para los 88 días.';
              } else {
                if (subclass == '462' && _selectedIndustry == 'tourism_hospitality') {
                  detailMessage = isEn
                      ? 'Ineligible! Under Subclass 462, Tourism & Hospitality only counts in Northern Australia or Remote areas. ${_searchResult!.location} is not in an eligible northern zone.'
                      : '¡No elegible! En Subclase 462, hostelería SOLO cuenta en el Norte de Australia o Zonas Remotas. ${_searchResult!.location} no está en zona norte elegible.';
                } else {
                  detailMessage = isEn
                      ? 'This industry is not approved for regional work in postcode ${_searchResult!.code}.'
                      : 'Esta industria no está aprobada para renovar visado en el código postal ${_searchResult!.code}.';
                }
              }

              return _buildAlertCard(
                isEligible: isEligible,
                title: '${_searchResult!.code} - ${_searchResult!.location}',
                message: detailMessage,
              );
            }),
          ],
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildWorkLogTab(bool isEn, bool isPremium, List<RegionalJobEntry> jobs, int totalDays, String applicantEmail, String visaSubclass) {
    final progress = (totalDays / 88.0).clamp(0.0, 1.0);

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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEn ? '2nd Year Visa Progress' : 'Progreso 2º Año de Visa',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  Text(
                    '$totalDays / 88 ${isEn ? "days" : "días"}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primary),
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
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                totalDays >= 88
                    ? (isEn ? '🎉 Goal reached! Ready to lodge your 2nd year visa.' : '🎉 ¡Meta alcanzada! Listo para solicitar tu 2º año.')
                    : (isEn ? '${88 - totalDays} days remaining to complete.' : 'Faltan ${88 - totalDays} días para completar la extensión.'),
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
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
            onPressed: () => _showAddJobDialog(isEn),
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

  void _showAddJobDialog(bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEn ? 'Add Regional Job' : 'Añadir Empleo Regional', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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

  Widget _buildIndustryChoice(String id, String label) {
    final isSelected = _selectedIndustry == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      ),
      onSelected: (val) {
        setState(() => _selectedIndustry = id);
        _executePostcodeSearch(_postcodeController.text);
      },
    );
  }

  Widget _buildAlertCard({required bool isEligible, required String title, required String message}) {
    final color = isEligible ? AppColors.secondary : AppColors.statusClosed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isEligible ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.xmark_seal_fill, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
