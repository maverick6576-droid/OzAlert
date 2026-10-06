import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/phase2/phase2_providers.dart';
import '../../../../domain/models/phase2/regional_work_log.dart';
import '../../../../domain/models/phase2/postcode_info.dart';
import '../../../widgets/phase2/paywall_bottom_sheet.dart';

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
    final subclass = profile?.visaSubclass ?? '462';
    final isPremium = profile?.isPremium ?? false;

    final jobs = ref.watch(regionalJobsProvider);
    final totalDays = jobs.fold<int>(0, (sum, j) => sum + j.totalDaysCounted);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isEn ? '88 Days Visa Renewal' : 'Visa 88 Días / 6 Meses',
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 22),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
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
          _buildWorkLogTab(isEn, isPremium, jobs, totalDays, profile?.uid ?? ''),
        ],
      ),
    );
  }

  Widget _buildPostcodeValidatorTab(bool isEn, String subclass) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Selector de Subclase
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.shield_lefthalf_fill, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Active Visa Subclass: $subclass' : 'Subclase de Visado Activa: $subclass',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      subclass == '462'
                          ? (isEn ? 'Hospitality eligible ONLY in Northern/Remote areas' : 'Hostelería válida SOLO en Norte/Zonas Remotas')
                          : (isEn ? 'Hospitality not eligible under 417' : 'Hostelería no elegible para 417'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                decoration: InputDecoration(
                  labelText: isEn ? '4-Digit Postcode (e.g., 4870)' : 'Código Postal (ej: 4870, 2481)',
                  counterText: '',
                  prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cardBorder)),
                ),
                onSubmitted: _executePostcodeSearch,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _executePostcodeSearch(_postcodeController.text),
              child: Text(isEn ? 'Check' : 'Validar', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Selector de Industria
        Text(isEn ? 'Industry of Employment:' : 'Industria del Empleo:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildIndustryChoice('tourism_hospitality', isEn ? '☕ Hospitality / Tourism' : '☕ Hostelería y Turismo'),
            _buildIndustryChoice('agriculture', isEn ? '🌾 Agriculture / Farming' : '🌾 Agricultura y Cosecha'),
            _buildIndustryChoice('construction', isEn ? '🏗️ Construction' : '🏗️ Construcción'),
          ],
        ),
        const SizedBox(height: 20),

        // Resultado de Elegibilidad
        if (_hasSearched) ...[
          if (_searchResult == null) ...[
            _buildAlertCard(
              isEligible: false,
              title: isEn ? 'Postcode Not Regional or Unknown' : 'Código Postal No Válido o Desconocido',
              message: isEn
                  ? 'The postcode ${_postcodeController.text} does not appear in official regional instruments (LIN 22/050) for regional work extensions.'
                  : 'El código ${_postcodeController.text} no califica como área regional elegible según Inmigración.',
            ),
          ] else ...[
            Builder(builder: (ctx) {
              final isEligible = _searchResult!.isEligible(subclass, _selectedIndustry);

              String detailMessage = '';
              if (isEligible) {
                detailMessage = isEn
                    ? 'Eligible! Work in ${_searchResult!.location} in this industry satisfies the specified work requirement.'
                    : '¡Válido! Trabajar en ${_searchResult!.location} en este sector cuenta oficialmente para los 88 días.';
              } else {
                if (subclass == '462' && _selectedIndustry == 'tourism_hospitality') {
                  detailMessage = isEn
                      ? 'Ineligible! Under Subclass 462, Tourism & Hospitality only counts in Northern Australia or Remote areas. ${_searchResult!.location} is not in eligible northern zone.'
                      : '¡No elegible! En Subclase 462, la hostelería SOLO cuenta en el Norte de Australia o Zonas Remotas. ${_searchResult!.location} no está en zona elegible.';
                } else {
                  detailMessage = isEn
                      ? 'This industry is not approved for regional work in postcode ${_searchResult!.code}.'
                      : 'Esta industria no está aprobada para renovar visado en el código ${_searchResult!.code}.';
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

  Widget _buildWorkLogTab(bool isEn, bool isPremium, List<RegionalJobEntry> jobs, int totalDays, String uid) {
    final progress = (totalDays / 88.0).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tarjeta de progreso 88 Días
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEn ? '2nd Year Visa Progress' : 'Progreso 2º Año de Visa',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '$totalDays / 88 ${isEn ? "days" : "días"}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
                backgroundColor: AppColors.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
              const SizedBox(height: 8),
              Text(
                totalDays >= 88
                    ? (isEn ? '🎉 Goal reached! Ready to lodge your 2nd year visa.' : '🎉 ¡Meta alcanzada! Listo para solicitar tu 2º año.')
                    : (isEn ? '${88 - totalDays} days remaining to complete.' : 'Faltan ${88 - totalDays} días para completar la extensión.'),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botón Añadir Empleo
        OutlinedButton.icon(
          icon: const Icon(CupertinoIcons.plus_circle_fill, color: AppColors.secondary),
          label: Text(isEn ? 'Add Regional Job Entry' : 'Añadir Registro de Trabajo'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => _showAddJobDialog(isEn),
        ),
        const SizedBox(height: 16),

        // Lista de Empleos Registrados
        if (jobs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                isEn ? 'No jobs recorded yet. Tap above to add your first job.' : 'Aún no has registrado ningún trabajo regional.',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ...jobs.map((job) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.cardBorder)),
            child: ListTile(
              title: Text(job.employerBusinessName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${job.workSiteLocation} (${job.workSitePostcode}) • ${job.totalDaysCounted} días'),
              trailing: IconButton(
                icon: const Icon(CupertinoIcons.trash, color: AppColors.statusClosed, size: 20),
                onPressed: () => ref.read(regionalJobsProvider.notifier).removeJob(job.id),
              ),
            ),
          )),

        const SizedBox(height: 20),

        // Exportación de Formulario 1263 con bloqueo Freemium
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(isPremium ? CupertinoIcons.doc_text_fill : CupertinoIcons.lock_fill),
            label: Text(
              isEn ? 'Export Official Form 1263 & Immi Dossier (PDF)' : 'Descargar Formulario 1263 y Expediente (PDF)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPremium ? AppColors.secondary : AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              if (!isPremium) {
                showPhase2PaywallBottomSheet(
                  context: context,
                  featureTitle: isEn ? 'Official Form 1263 Immi Dossier' : 'Expediente Oficial Formulario 1263',
                  featureBenefit: isEn
                      ? 'Export an audit-ready PDF compiling all employer ABNs, postcodes and signed declarations for ImmiAccount.'
                      : 'Genera el expediente oficial en PDF con todos los ABNs, códigos postales y nóminas compiladas para subir a Inmigración sin riesgo de denegación.',
                );
                return;
              }

              // Usuario Premium
              final pdfBytes = await PdfGeneratorService.generateRegionalDossier(
                applicantName: 'Mochilero OzAlert',
                passportNumber: 'ES9928374',
                visaSubclass: '462',
                jobs: jobs,
                totalDays: totalDays,
              );
              await PdfGeneratorService.shareOrPrintPdf(pdfBytes, 'Form1263_Evidence_Dossier.pdf');
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
        title: Text(isEn ? 'Record Regional Employment' : 'Registrar Empleo Regional'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _employerNameController, decoration: InputDecoration(labelText: isEn ? 'Business Name' : 'Nombre de la Empresa')),
            TextField(controller: _abnController, decoration: const InputDecoration(labelText: 'ABN (11 dígitos)')),
            TextField(controller: _daysController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isEn ? 'Days Counted' : 'Días a computar')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEn ? 'Cancel' : 'Cancelar')),
          ElevatedButton(
            onPressed: () {
              final days = int.tryParse(_daysController.text) ?? 1;
              ref.read(regionalJobsProvider.notifier).addJob(
                RegionalJobEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  employerBusinessName: _employerNameController.text.trim().isNotEmpty ? _employerNameController.text.trim() : 'Farm / Venue',
                  employerAbn: _abnController.text.trim(),
                  workSitePostcode: _postcodeController.text.trim(),
                  workSiteLocation: _searchResult?.location ?? 'Regional Area',
                  industry: _selectedIndustry,
                  startDate: DateTime.now().subtract(Duration(days: days)),
                  endDate: DateTime.now(),
                  totalDaysCounted: days,
                  totalHours: days * 7.6,
                  grossEarningsAud: days * 250.0,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(isEn ? 'Save' : 'Guardar'),
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
      selectedColor: AppColors.secondary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
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
          Icon(isEligible ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.xmark_seal_fill, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
