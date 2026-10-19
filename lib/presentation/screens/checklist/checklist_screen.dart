import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../domain/models/checklist_item.dart';
import '../../providers/checklist_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../settings/settings_screen.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  // 0 = Checklist de Visado, 1 = Guías de Solicitud
  int _activeMainTab = 0;

  // Estado de la vista Checklist (4 etapas desplegables)
  int _selectedStageIndex = 0;

  // Estado de la vista Guías de Solicitud
  int _selectedGuideThemeIndex = 0;
  String _selectedGuideCategory = 'immiaccount_apply';
  int _selectedGuideSubTab = 0; // 0 = Pasos, 1 = Comparar, 2 = Enlaces Oficiales
  bool _cameFromChecklistSmartLink = false;
  final Set<int> _expandedGuideSteps = {};

  static const List<Map<String, dynamic>> _guideThemes = [
    {
      'id': 'preparation',
      'label': '🛂 1. Cuenta, Identidad y Elegibilidad',
      'labelEn': '🛂 1. Account, Identity & Eligibility',
      'categories': [
        {
          'id': 'immiaccount_apply',
          'label': '💻 Solicitud en ImmiAccount Paso a Paso',
          'labelEn': '💻 ImmiAccount Step-by-Step Application',
        },
        {
          'id': 'identity_documents',
          'label': '🛂 Pasaporte y Documentos de Identidad',
          'labelEn': '🛂 Passport & Identity Documents',
        },
      ],
    },
    {
      'id': 'academic_english',
      'label': '🎓 2. Inglés y Requisitos de Estudios',
      'labelEn': '🎓 2. English & Education Requirements',
      'categories': [
        {
          'id': 'english_language',
          'label': '🗣️ Nivel de Inglés (PTE, IELTS, TOEFL, CAE)',
          'labelEn': '🗣️ Functional English (PTE, IELTS, TOEFL, CAE)',
        },
        {
          'id': 'education',
          'label': '🎓 Títulos y Estudios Exigidos por País',
          'labelEn': '🎓 Education Requirements by Country',
        },
      ],
    },
    {
      'id': 'funds_legal',
      'label': '🏦 3. Fondos, Antecedentes y Traducciones',
      'labelEn': '🏦 3. Funds, Police Check & Translations',
      'categories': [
        {
          'id': 'enough_money',
          'label': '💰 Demostrar Fondos (\$5.000 AUD + Vuelo)',
          'labelEn': '💰 Proof of Funds (\$5,000 AUD + Flight)',
        },
        {
          'id': 'character_health',
          'label': '🛡️ Antecedentes Penales y Exámenes Médicos',
          'labelEn': '🛡️ Police Certificates & Health Exams',
        },
        {
          'id': 'translations_support',
          'label': '📑 Traducciones Oficiales, Carta de Apoyo y 956A',
          'labelEn': '📑 Official Translations, Gov Letter & Form 956A',
        },
      ],
    },
  ];

  void _openGuideFromChecklist(String categoryId) {
    setState(() {
      _selectedGuideCategory = categoryId;
      _selectedGuideSubTab = 0;
      _expandedGuideSteps.clear();
      for (int i = 0; i < _guideThemes.length; i++) {
        final cats = _guideThemes[i]['categories'] as List<Map<String, String>>;
        if (cats.any((c) => c['id'] == categoryId)) {
          _selectedGuideThemeIndex = i;
          break;
        }
      }
      _cameFromChecklistSmartLink = true;
      _activeMainTab = 1;
    });
  }

  void _showSwitchToPhase2Dialog(BuildContext context, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.flight_takeoff_rounded, color: AppColors.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEn ? 'Switch to Phase 2! 🎉' : '¡Pasar a la Fase 2! 🎉',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          isEn
              ? 'By switching to Phase 2, you will unlock the Australia Arrival Checklist, Step-by-Step Guides, 88-Day Regional Validator, Fair Work Pay Calculator, and Aussie CV Maker. Quota push alerts will be turned off.'
              : 'Al pasar a la Fase 2, accederás al Checklist de Aterrizaje en Australia, Guías paso a paso, Validador de los 88 días, Calculadora de Sueldo Fair Work y generador de CV australiano. Además, apagaremos las alarmas push de apertura de cupos.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isEn ? 'Cancel' : 'Cancelar',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final item = ref.read(checklistProvider).where((i) => i.id == 'switch_to_phase2').firstOrNull;
              if (item != null && !item.isChecked) {
                ref.read(checklistProvider.notifier).toggleItem('switch_to_phase2');
              }
              final profile = ref.read(userProfileProvider).value;
              if (profile != null) {
                await ref.read(userRepositoryProvider).saveUserProfile(profile.copyWith(currentPhase: 2));
              }
              NotificationService().syncPassportSubscriptions([]);
            },
            child: Text(
              isEn ? 'Enter Phase 2' : 'Entrar a la Fase 2',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checklist = ref.watch(checklistProvider);
    final progress = ref.watch(checklistProgressProvider);
    final locale = ref.watch(localeProvider);
    final isEn = (locale?.languageCode ?? Localizations.localeOf(context).languageCode) == 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 48,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                image: const DecorationImage(
                  image: AssetImage('assets/images/app_icon.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.checklistTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isEn ? 'Official Home Affairs Sources' : 'Fuentes Oficiales Home Affairs',
            icon: const Icon(CupertinoIcons.info_circle, color: AppColors.textPrimary, size: 21),
            onPressed: () => _showOfficialVisaSourcesModal(context, isEn),
          ),
          IconButton(
            tooltip: isEn ? 'Settings' : 'Ajustes',
            icon: const Icon(CupertinoIcons.gear, color: AppColors.textPrimary, size: 21),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Selector Superior Uniforme (Parte 1: Checklist de Visado | Parte 2: Guías de Solicitud)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _activeMainTab = 0;
                        _cameFromChecklistSmartLink = false;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _activeMainTab == 0 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: _activeMainTab == 0
                              ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.checkmark_shield_fill,
                              size: 15,
                              color: _activeMainTab == 0 ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isEn ? 'Visa Checklist' : 'Checklist Visado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: _activeMainTab == 0 ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeMainTab = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _activeMainTab == 1 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: _activeMainTab == 1
                              ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.book_fill,
                              size: 15,
                              color: _activeMainTab == 1 ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isEn ? 'How to Apply (Guides)' : 'Guías de Solicitud',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: _activeMainTab == 1 ? Colors.white : AppColors.textSecondary,
                                ),
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
          ),

          // Contenido principal según la vista activa
          Expanded(
            child: _activeMainTab == 0
                ? _buildChecklistTabView(context, checklist, progress, isEn)
                : _buildGuidesTabView(context, isEn),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PARTE 1: CHECKLIST DE VISADO (CON CAMINO EN 'S' Y ACORDEONES IGUAL QUE FASE 2)
  // ===========================================================================
  Widget _buildChecklistTabView(
    BuildContext context,
    List<ChecklistItem> checklist,
    double progressPercent,
    bool isEn,
  ) {
    ChecklistItem findOrFallback(String id, String fallbackTitle, String fallbackDesc) {
      return checklist.firstWhere(
        (item) => item.id == id,
        orElse: () => ChecklistItem(id: id, title: fallbackTitle, description: fallbackDesc),
      );
    }

    final stage0Items = [
      findOrFallback('immiaccount_setup', 'Crear y verificar cuenta ImmiAccount', 'Registrarse en online.immi.gov.au y activar 2FA.'),
      findOrFallback('identity_documents', 'Documentos de identidad y Pasaporte', 'Pasaporte a color, certificado de nacimiento y foto.'),
      findOrFallback('government_support', 'Apoyo del Gobierno (Solo ciertos países)', 'Solo exigida en países como Perú o Ecuador.'),
    ];
    final stage1Items = [
      findOrFallback('english_language', 'Certificado oficial de Nivel de Inglés', 'PTE ≥ 30, IELTS ≥ 4.5, CAE ≥ 147 o TOEFL iBT ≥ 32.'),
      findOrFallback('education', 'Título o Expediente de Educación Superior', 'Título universitario, FP superior o 2 años de carrera.'),
    ];
    final stage2Items = [
      findOrFallback('enough_money', 'Fondos suficientes (\$5.000 AUD + Vuelo)', 'Extracto bancario oficial con \$5.000 AUD + billete.'),
      findOrFallback('character_documents', 'Certificado de Antecedentes Penales', 'Certificado policial de países donde residiste +12 meses.'),
      findOrFallback('health_exams', 'Exámenes médicos y radiografía (Si aplica)', 'Revisión médica con Panel Physician (código HAP ID).'),
    ];
    final stage3Items = [
      findOrFallback('prepare_documents', 'Traducciones oficiales y escaneo a color', 'Traductor Jurado / NAATI y archivos PDF a color (<5 MB).'),
      findOrFallback('getting_help', 'Formulario 956 / 956A (Solo si usas Agente)', 'Solo si autorizas a un agente migratorio o tercero.'),
      findOrFallback('immiaccount_draft', 'Dejar borrador de solicitud listo en ImmiAccount', 'Guardar las páginas del formulario antes de la apertura.'),
      findOrFallback('visa_payment_submit', 'Tarjeta preparada para tasa (\$650 AUD) y Envío', 'Tener tarjeta / Wise lista para pagar \$650 AUD al aplicar.'),
      findOrFallback('switch_to_phase2', 'Pasar a la Fase 2 de la app (¡Visado Concedido!)', 'Activar la Fase 2 para acceder a Aterrizaje, Guías en Australia, 88 Días, Sueldo y CV.'),
    ];

    final allItems = [...stage0Items, ...stage1Items, ...stage2Items, ...stage3Items];
    final completedCount = allItems.where((i) => i.isChecked).length;
    final totalCount = allItems.length;
    final computedProgress = totalCount > 0 ? (completedCount / totalCount) : progressPercent;

    final stages = [
      {
        'title': isEn ? '1. Identity & ImmiAccount' : '1. Identidad & ImmiAccount',
        'subtitle': isEn ? 'Account, passport & birth certificate' : 'Cuenta oficial, pasaporte y nacimiento',
        'icon': '🛂',
        'tasks': stage0Items,
      },
      {
        'title': isEn ? '2. English & Education' : '2. Inglés & Estudios',
        'subtitle': isEn ? 'Accepted language tests & degrees' : 'Exámenes oficiales y títulos',
        'icon': '🎓',
        'tasks': stage1Items,
      },
      {
        'title': isEn ? '3. Funds & Background' : '3. Fondos & Antecedentes',
        'subtitle': isEn ? '\$5,000 AUD bank proof, police & health' : '\$5.000 AUD, penales y salud',
        'icon': '🏦',
        'tasks': stage2Items,
      },
      {
        'title': isEn ? '4. Translations, Submit & Phase 2' : '4. Traducción, Envío y Fase 2',
        'subtitle': isEn ? 'Translations, \$650 AUD fee & enter Phase 2' : 'Traducciones, pago \$650 AUD y pasar a Fase 2',
        'icon': '🚀',
        'tasks': stage3Items,
      },
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 1. Camino en 'S' hacia el Visado (Uniforme con Fase 2)
        _buildVisaJourneyTrailCard(
          completedCount: completedCount,
          totalCount: totalCount,
          progressPercent: computedProgress,
          stages: stages,
          isEn: isEn,
        ),
        const SizedBox(height: 16),

        // 2. Etapas desplegables del Checklist con botones Smart Link a las Guías
        for (int stageIdx = 0; stageIdx < stages.length; stageIdx++) ...[
          _buildStageAccordion(
            context: context,
            stageIndex: stageIdx,
            stage: stages[stageIdx],
            isExpanded: _selectedStageIndex == stageIdx,
            isEn: isEn,
            onHeaderTap: () {
              setState(() {
                if (_selectedStageIndex == stageIdx) {
                  _selectedStageIndex = -1;
                } else {
                  _selectedStageIndex = stageIdx;
                }
              });
            },
          ),
          const SizedBox(height: 10),
        ],

        const SizedBox(height: 8),
        // Consejo de preparación rápida
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.compass_fill,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.checklistTip,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVisaJourneyTrailCard({
    required int completedCount,
    required int totalCount,
    required double progressPercent,
    required List<Map<String, dynamic>> stages,
    required bool isEn,
  }) {
    final isDone = completedCount == totalCount && totalCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🦘', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'VISA EXPEDITION TRAIL' : 'LA RUTA HACIA TU VISADO',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isEn ? 'Work & Holiday Application Kit' : 'Preparación Work & Holiday (462 / 417)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone
                        ? AppColors.secondary.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDone ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.flame_fill,
                      size: 13,
                      color: isDone ? AppColors.secondary : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$completedCount/$totalCount (${(progressPercent * 100).round()}%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDone ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildVisaSTrail(stages: stages),
        ],
      ),
    );
  }

  Widget _buildVisaSTrail({
    required List<Map<String, dynamic>> stages,
  }) {
    final stage0Tasks = stages[0]['tasks'] as List<ChecklistItem>;
    final stage0Done = stage0Tasks.where((t) => t.isChecked).length;
    final stage0Ratio = stage0Tasks.isNotEmpty ? (stage0Done / stage0Tasks.length) : 0.0;

    final stage1Tasks = stages[1]['tasks'] as List<ChecklistItem>;
    final stage1Done = stage1Tasks.where((t) => t.isChecked).length;
    final stage1Ratio = stage1Tasks.isNotEmpty ? (stage1Done / stage1Tasks.length) : 0.0;

    final stage2Tasks = stages[2]['tasks'] as List<ChecklistItem>;
    final stage2Done = stage2Tasks.where((t) => t.isChecked).length;
    final stage2Ratio = stage2Tasks.isNotEmpty ? (stage2Done / stage2Tasks.length) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const canvasHeight = 146.0;
        const padX = 36.0;
        const y0 = 24.0;
        const y1 = 73.0;
        const y2 = 122.0;

        final path = Path();
        path.moveTo(padX, y0);
        path.lineTo(availableWidth - padX, y0);
        path.cubicTo(
          availableWidth - 2, y0,
          availableWidth - 2, y1,
          availableWidth - padX, y1,
        );
        path.lineTo(padX, y1);
        path.cubicTo(
          2, y1,
          2, y2,
          padX, y2,
        );
        path.lineTo(availableWidth - padX, y2);

        final metric = path.computeMetrics().first;
        final totalLength = metric.length;

        final subPathToW1 = Path()
          ..moveTo(padX, y0)
          ..lineTo(availableWidth - padX, y0);
        final lenW1 = subPathToW1.computeMetrics().first.length;

        final subPathToW2 = Path()
          ..moveTo(padX, y0)
          ..lineTo(availableWidth - padX, y0)
          ..cubicTo(availableWidth - 2, y0, availableWidth - 2, y1, availableWidth - padX, y1)
          ..lineTo(padX, y1);
        final lenW2 = subPathToW2.computeMetrics().first.length;

        final f1 = (lenW1 / totalLength).clamp(0.0, 1.0);
        final f2 = (lenW2 / totalLength).clamp(0.0, 1.0);

        double effectiveProgress = 0.0;
        if (stage0Ratio < 1.0) {
          effectiveProgress = f1 * stage0Ratio;
        } else if (stage1Ratio < 1.0) {
          effectiveProgress = f1 + (f2 - f1) * stage1Ratio;
        } else if (stage2Ratio < 1.0) {
          effectiveProgress = f2 + (1.0 - f2) * stage2Ratio;
        } else {
          effectiveProgress = 1.0;
        }

        final waypoints = [
          const Offset(padX, y0),
          Offset(availableWidth - padX, y0),
          const Offset(padX, y1),
          Offset(availableWidth - padX, y2),
        ];

        return SizedBox(
          height: canvasHeight,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: effectiveProgress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            builder: (context, animatedVal, _) {
              final tangent = metric.getTangentForOffset(totalLength * animatedVal);
              final kPos = tangent?.position ?? const Offset(padX, y0);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _VisaSTrailPainter(
                        basePath: path,
                        metric: metric,
                        progress: animatedVal,
                        waypoints: waypoints,
                        selectedIndex: _selectedStageIndex,
                        stages: stages,
                      ),
                    ),
                  ),
                  Positioned(
                    left: padX - 17,
                    top: y0 - 17,
                    child: _buildStageIconNode(index: 0, stage: stages[0], isSelected: _selectedStageIndex == 0),
                  ),
                  Positioned(
                    left: availableWidth - padX - 17,
                    top: y0 - 17,
                    child: _buildStageIconNode(index: 1, stage: stages[1], isSelected: _selectedStageIndex == 1),
                  ),
                  Positioned(
                    left: padX - 17,
                    top: y1 - 17,
                    child: _buildStageIconNode(index: 2, stage: stages[2], isSelected: _selectedStageIndex == 2),
                  ),
                  Positioned(
                    left: availableWidth - padX - 17,
                    top: y2 - 17,
                    child: _buildStageIconNode(index: 3, stage: stages[3], isSelected: _selectedStageIndex == 3),
                  ),
                  Positioned(
                    left: (kPos.dx - 15).clamp(0.0, availableWidth - 30),
                    top: (kPos.dy - 15).clamp(0.0, canvasHeight - 30),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 7,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text('🦘', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStageIconNode({
    required int index,
    required Map<String, dynamic> stage,
    required bool isSelected,
  }) {
    final tasks = stage['tasks'] as List<ChecklistItem>;
    final doneCount = tasks.where((t) => t.isChecked).length;
    final isDone = tasks.isNotEmpty && doneCount == tasks.length;

    return GestureDetector(
      onTap: () => setState(() => _selectedStageIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? (isDone ? AppColors.secondary : AppColors.primary)
              : (isDone ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.surface),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : (isDone ? AppColors.secondary : AppColors.cardBorder),
            width: isSelected ? 2.2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          stage['icon'] as String,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStageAccordion({
    required BuildContext context,
    required int stageIndex,
    required Map<String, dynamic> stage,
    required bool isExpanded,
    required bool isEn,
    required VoidCallback onHeaderTap,
  }) {
    final tasks = stage['tasks'] as List<ChecklistItem>;
    final doneCount = tasks.where((t) => t.isChecked).length;
    final isDone = tasks.isNotEmpty && doneCount == tasks.length;
    final pendingTasks = tasks.where((t) => !t.isChecked).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? (isDone ? AppColors.secondary : AppColors.primary.withValues(alpha: 0.6))
              : (isDone ? AppColors.secondary.withValues(alpha: 0.35) : AppColors.cardBorder),
          width: isExpanded ? 1.6 : 1.0,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.secondary.withValues(alpha: 0.14)
                          : (isExpanded
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surfaceElevated),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(stage['icon'] as String, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage['title'] as String,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDone ? AppColors.secondary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stage['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : (isExpanded ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceElevated),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDone
                            ? AppColors.secondary.withValues(alpha: 0.4)
                            : (isExpanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.cardBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDone)
                          const Icon(CupertinoIcons.checkmark_circle_fill, size: 12, color: AppColors.secondary)
                        else
                          Text(
                            '$doneCount/${tasks.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isExpanded ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    size: 15,
                    color: isExpanded ? AppColors.primary : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pendingTasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.flame_fill, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isEn
                                  ? 'Prepare these documents before the visa quota opens.'
                                  : 'Prepara estos requisitos antes de que abran los cupos.',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...tasks.map((item) => _buildVisaChecklistTaskTile(context, item, isEn)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, String> _getTaskLocalizedMeta(BuildContext context, ChecklistItem item, bool isEn) {
    final l10n = AppLocalizations.of(context)!;
    switch (item.id) {
      case 'immiaccount_setup':
        return {
          'title': isEn ? 'Create & verify your ImmiAccount' : 'Crear y verificar cuenta ImmiAccount',
          'desc': isEn
              ? 'Register on the official Department of Home Affairs portal (online.immi.gov.au) and set up 2FA.'
              : 'Regístrate en el portal oficial del Department of Home Affairs (online.immi.gov.au) y activa la verificación en 2 pasos.',
          'guideCategory': 'immiaccount_apply',
          'actionLabel': isEn ? 'Step-by-step ImmiAccount guide' : 'Ver guía de ImmiAccount y portal oficial',
        };
      case 'identity_documents':
        return {
          'title': l10n.checklistIdentityDocumentsTitle,
          'desc': l10n.checklistIdentityDocumentsDesc,
          'guideCategory': 'identity_documents',
          'actionLabel': isEn ? 'Passport & birth certificate guide' : 'Ver requisitos de pasaporte y nacimiento',
        };
      case 'government_support':
        return {
          'title': l10n.checklistGovernmentSupportTitle,
          'desc': l10n.checklistGovernmentSupportDesc,
          'guideCategory': 'translations_support',
          'actionLabel': isEn ? 'Check countries & exemptions' : 'Consultar países exentos y requisitos',
        };
      case 'english_language':
        return {
          'title': l10n.checklistEnglishLanguageTitle,
          'desc': l10n.checklistEnglishLanguageDesc,
          'guideCategory': 'english_language',
          'actionLabel': isEn ? 'Compare accepted English exams & scores' : 'Comparar exámenes de inglés y notas mínimas',
        };
      case 'education':
        return {
          'title': l10n.checklistEducationTitle,
          'desc': l10n.checklistEducationDesc,
          'guideCategory': 'education',
          'actionLabel': isEn ? 'Check degree requirements by country' : 'Ver estudios exigidos según tu pasaporte',
        };
      case 'enough_money':
        return {
          'title': l10n.checklistEnoughMoneyTitle,
          'desc': l10n.checklistEnoughMoneyDesc,
          'guideCategory': 'enough_money',
          'actionLabel': isEn ? 'How to format the \$5,000 AUD bank statement' : 'Cómo presentar el extracto de \$5.000 AUD',
        };
      case 'character_documents':
        return {
          'title': l10n.checklistCharacterDocumentsTitle,
          'desc': l10n.checklistCharacterDocumentsDesc,
          'guideCategory': 'character_health',
          'actionLabel': isEn ? 'Police certificate & character guide' : 'Guía de antecedentes penales y apostilla',
        };
      case 'health_exams':
        return {
          'title': isEn ? 'Health exams & chest X-ray (If applicable)' : 'Exámenes médicos y radiografía (Si aplica)',
          'desc': isEn
              ? 'Check if your country of residence or intended work requires a medical examination with a Panel Physician (HAP ID).'
              : 'Comprueba si tu país de residencia o sector requiere revisión médica con un médico acreditado (Panel Physician y HAP ID).',
          'guideCategory': 'character_health',
          'actionLabel': isEn ? 'Check health rules & Panel Physicians' : 'Ver normativa médica y clínicas oficiales',
        };
      case 'prepare_documents':
        return {
          'title': l10n.checklistPrepareDocumentsTitle,
          'desc': l10n.checklistPrepareDocumentsDesc,
          'guideCategory': 'translations_support',
          'actionLabel': isEn ? 'Official translation & colour scan rules' : 'Reglas de traducción jurada/NAATI y escaneo',
        };
      case 'getting_help':
        return {
          'title': l10n.checklistGettingHelpTitle,
          'desc': l10n.checklistGettingHelpDesc,
          'guideCategory': 'translations_support',
          'actionLabel': isEn ? 'Form 956 / 956A official instructions' : 'Ver cuándo usar el Formulario 956 / 956A',
        };
      case 'immiaccount_draft':
        return {
          'title': isEn ? 'Save your application draft in ImmiAccount' : 'Dejar borrador de solicitud listo en ImmiAccount',
          'desc': isEn
              ? 'Fill out and save the Work & Holiday (462 / 417) application pages in advance so you can submit in minutes when spots open.'
              : 'Completa y guarda las páginas del formulario Work & Holiday (462 / 417) con antelación para enviar en minutos al abrir cupos.',
          'guideCategory': 'immiaccount_apply',
          'actionLabel': isEn ? 'See how to pre-fill the application' : 'Ver cómo rellenar el formulario paso a paso',
        };
      case 'switch_to_phase2':
        return {
          'title': isEn ? 'Switch to Phase 2 of the app (Visa Granted!)' : 'Pasar a la Fase 2 de la app (¡Visado Concedido!)',
          'desc': isEn
              ? 'Once your visa is granted, activate Phase 2 to unlock your Australia Arrival Checklist, Step-by-Step Guides, 88-Day Validator, Pay Calculator & Aussie CV.'
              : 'Cuando te concedan el visado, pasa a la Fase 2 para activar el Checklist de Aterrizaje, Guías en Australia, Validador de 88 Días, Sueldo y CV.',
          'guideCategory': 'switch_phase2_action',
          'actionLabel': isEn ? '✈️ Tap here to enter Phase 2 now' : '✈️ Pulsar aquí para pasar a la Fase 2',
        };
      case 'visa_payment_submit':
      default:
        return {
          'title': isEn ? 'Payment card ready (\$650 AUD) & Submit' : 'Tarjeta preparada para tasa (\$650 AUD) y Envío',
          'desc': isEn
              ? 'Ensure international online payment limit is enabled (Wise, Revolut or bank card) to pay the \$650 AUD official visa fee.'
              : 'Asegura el límite de pago internacional (Wise, Revolut o tarjeta bancaria) para abonar los \$650 AUD de tasa oficial en ImmiAccount.',
          'guideCategory': 'immiaccount_apply',
          'actionLabel': isEn ? 'See payment & submission tips' : 'Ver guía de pago oficial y envío en ImmiAccount',
        };
    }
  }

  Widget _buildVisaChecklistTaskTile(BuildContext context, ChecklistItem item, bool isEn) {
    final meta = _getTaskLocalizedMeta(context, item, isEn);
    final isPhase2Step = item.id == 'switch_to_phase2';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isPhase2Step
              ? AppColors.secondary.withValues(alpha: 0.65)
              : (item.isChecked ? AppColors.secondary.withValues(alpha: 0.35) : AppColors.cardBorder),
          width: isPhase2Step || item.isChecked ? 1.5 : 1.0,
        ),
      ),
      elevation: 0,
      color: item.isChecked
          ? AppColors.surfaceElevated.withValues(alpha: 0.5)
          : (isPhase2Step ? AppColors.secondary.withValues(alpha: 0.06) : AppColors.surface),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1.05,
              child: Checkbox(
                value: item.isChecked,
                activeColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                side: const BorderSide(color: AppColors.textMuted, width: 1.5),
                onChanged: (_) {
                  if (isPhase2Step && !item.isChecked) {
                    _showSwitchToPhase2Dialog(context, isEn);
                  } else {
                    ref.read(checklistProvider.notifier).toggleItem(item.id);
                  }
                },
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    meta['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: item.isChecked ? AppColors.textMuted : AppColors.textPrimary,
                      decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta['desc']!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: item.isChecked ? AppColors.textMuted : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      if (isPhase2Step) {
                        _showSwitchToPhase2Dialog(context, isEn);
                      } else {
                        _openGuideFromChecklist(meta['guideCategory']!);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPhase2Step ? AppColors.secondary : AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isPhase2Step ? AppColors.secondary : AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPhase2Step ? Icons.flight_takeoff_rounded : CupertinoIcons.arrow_right_circle_fill,
                            size: 14,
                            color: isPhase2Step ? Colors.white : AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              meta['actionLabel']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isPhase2Step ? Colors.white : AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  // ===========================================================================
  // PARTE 2: GUÍAS DE CÓMO SOLICITAR EL VISADO CON ENLACES OFICIALES (IGUAL QUE FASE 2)
  // ===========================================================================
  Widget _buildGuidesTabView(BuildContext context, bool isEn) {
    final currentTheme = _guideThemes[_selectedGuideThemeIndex.clamp(0, _guideThemes.length - 1)];
    final currentCategories = currentTheme['categories'] as List<Map<String, String>>;
    final currentCategoryItem = currentCategories.firstWhere(
      (c) => c['id'] == _selectedGuideCategory,
      orElse: () => currentCategories.first,
    );
    final guideData = _getVisaGuideData(_selectedGuideCategory, isEn);

    return Column(
      children: [
        // Banner compacto de retorno al Checklist si venimos de un Smart Link
        if (_cameFromChecklistSmartLink)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: InkWell(
              onTap: () => setState(() {
                _activeMainTab = 0;
                _cameFromChecklistSmartLink = false;
              }),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.arrow_left, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isEn
                            ? 'Return to Visa Checklist to mark step done'
                            : 'Volver al Checklist de Visado para marcar la tarea',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 1. Tarjeta Ejecutiva Compacta de Contexto (Igual formato que Fase 2 pero optimizada en altura)
        _buildActiveGuideHeaderCard(context, isEn, currentTheme, currentCategoryItem),

        // 2. Sub-tabs segmentadas compactas (📘 Pasos | ⚖️ Comparar | 🏛️ Webs Oficiales)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                _buildGuideSubTabItem(index: 0, label: isEn ? '📘 Steps' : '📘 Pasos'),
                _buildGuideSubTabItem(index: 1, label: isEn ? '⚖️ Compare' : '⚖️ Comparar'),
                _buildGuideSubTabItem(index: 2, label: isEn ? '🏛️ Official Webs' : '🏛️ Webs Oficiales'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),

        // 3. Contenido dinámico de la guía seleccionada (ocupa la mayor parte de la pantalla)
        Expanded(
          child: _selectedGuideSubTab == 0
              ? _buildGuideStepsView(guideData, isEn)
              : (_selectedGuideSubTab == 1
                  ? _buildGuideComparisonsView(guideData, isEn)
                  : _buildOfficialPortalsDirectoryView(isEn)),
        ),
      ],
    );
  }

  Widget _buildActiveGuideHeaderCard(
    BuildContext context,
    bool isEn,
    Map<String, dynamic> currentTheme,
    Map<String, String> currentCategoryItem,
  ) {
    final themeLabel = isEn ? (currentTheme['labelEn'] as String) : (currentTheme['label'] as String);
    final categoryLabel = isEn ? currentCategoryItem['labelEn']! : currentCategoryItem['label']!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  categoryLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _showVisaGuidesCatalogModal(context, isEn),
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.square_grid_2x2_fill, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    isEn ? 'All (7)' : 'Ver todas (7)',
                    style: const TextStyle(
                      fontSize: 11,
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

  Widget _buildGuideSubTabItem({required int index, required String label}) {
    final isSelected = _selectedGuideSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGuideSubTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _showVisaGuidesCatalogModal(BuildContext context, bool isEn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.84,
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
                            isEn ? 'Visa Application Guides Directory' : 'Catálogo de Guías para Solicitar el Visado',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            isEn
                                ? '7 official step-by-step guides for Subclass 462 & 417'
                                : '7 guías oficiales paso a paso para Subclase 462 y 417',
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
                  itemCount: _guideThemes.length,
                  itemBuilder: (context, themeIdx) {
                    final theme = _guideThemes[themeIdx];
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
                          final isCurrent = cat['id'] == _selectedGuideCategory;
                          final label = isEn ? cat['labelEn']! : cat['label']!;
                          final info = _getVisaGuideData(cat['id']!, isEn);

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
                                    _selectedGuideThemeIndex = themeIdx;
                                    _selectedGuideCategory = cat['id']!;
                                    _expandedGuideSteps.clear();
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
                                            Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              info['subtitle'] as String,
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isCurrent ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.chevron_right,
                                        size: 18,
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

  Widget _buildGuideStepsView(Map<String, dynamic> guideData, bool isEn) {
    final steps = guideData['steps'] as List<Map<String, String>>;
    final officialUrl = guideData['officialUrl'] as String;
    final officialLabel = guideData['officialLabel'] as String;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        // Cabecera compacta de enlace oficial (deja mucho más espacio en pantalla para los pasos de la guía)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guideData['subtitle'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => UrlLauncherService.openUrl(context, officialUrl),
                  icon: const Icon(CupertinoIcons.globe, size: 14, color: AppColors.primary),
                  label: Text(
                    officialLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de pasos interactivos desplegables (igual que en Fase 2)
        for (int i = 0; i < steps.length; i++)
          _buildExpandableStepCard(i, steps[i], isEn),

        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildExpandableStepCard(int index, Map<String, String> step, bool isEn) {
    final isExpanded = _expandedGuideSteps.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded ? AppColors.primary.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedGuideSteps.remove(index);
              } else {
                _expandedGuideSteps.add(index);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['summary']!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                if (!isExpanded) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        isEn ? 'Tap to view details & official link ▾' : 'Toca para ver detalles y enlace oficial ▾',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  const SizedBox(height: 12),
                  Text(
                    step['body']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                  if (step['tip'] != null && step['tip']!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(CupertinoIcons.lightbulb_fill, size: 16, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step['tip']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (step['url'] != null && step['url']!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => UrlLauncherService.openUrl(context, step['url']!),
                        icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15, color: AppColors.secondary),
                        label: Text(
                          step['urlLabel'] ?? (isEn ? 'Open official Australian Gov page' : 'Abrir web oficial del Gobierno de Australia'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideComparisonsView(Map<String, dynamic> guideData, bool isEn) {
    final comparisons = guideData['comparisons'] as List<Map<String, String>>;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: comparisons.length,
      itemBuilder: (context, idx) {
        final item = comparisons[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item['name']!,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['badge']!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(CupertinoIcons.checkmark_circle_fill, size: 15, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['pros']!,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(CupertinoIcons.info_circle_fill, size: 15, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['cons']!,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '📋 ${item['requirement']!}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
              if (item['url'] != null && item['url']!.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => UrlLauncherService.openUrl(context, item['url']!),
                    icon: const Icon(CupertinoIcons.globe, size: 14, color: AppColors.primary),
                    label: Text(
                      item['urlLabel'] ?? (isEn ? 'View official source' : 'Ver fuente oficial'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfficialPortalsDirectoryView(bool isEn) {
    final portals = [
      {
        'title': isEn ? 'ImmiAccount Official Portal (Login & Register)' : 'Portal Oficial ImmiAccount (Registro y Solicitud)',
        'desc': isEn
            ? 'Official Australian Government portal to create your account, fill out the Subclass 462 / 417 form, upload PDFs and pay the visa fee.'
            : 'Portal único del Gobierno de Australia para crear tu cuenta, rellenar el formulario 462 / 417, subir tus PDFs y pagar la tasa.',
        'badge': 'online.immi.gov.au',
        'url': 'https://online.immi.gov.au/lusc/login',
        'btnLabel': isEn ? 'Open ImmiAccount Official Portal' : 'Abrir Portal Oficial ImmiAccount',
      },
      {
        'title': isEn ? 'Work and Holiday Visa (Subclass 462) — Official Guide' : 'Work and Holiday Visa (Subclase 462) — Guía Oficial',
        'desc': isEn
            ? 'Step-by-step official eligibility, document checklist, costs (\$650 AUD) and application rules for Spain, Chile, Argentina, Peru, Uruguay, etc.'
            : 'Requisitos oficiales paso a paso, documentos, tasa (\$650 AUD) y elegibilidad para España, Argentina, Chile, Perú, Uruguay, etc.',
        'badge': 'Subclass 462',
        'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462',
        'btnLabel': isEn ? 'View Subclass 462 on Home Affairs' : 'Ver Subclase 462 en Home Affairs',
      },
      {
        'title': isEn ? 'Working Holiday Visa (Subclass 417) — Official Guide' : 'Working Holiday Visa (Subclase 417) — Guía Oficial',
        'desc': isEn
            ? 'Official eligibility and application guide for European/Commonwealth passports (Italy, France, Germany, UK, Ireland, Canada, etc.).'
            : 'Requisitos oficiales y guía de solicitud para pasaportes con convenio 417 (Italia, Francia, Alemania, Reino Unido, Irlanda, etc.).',
        'badge': 'Subclass 417',
        'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-417/first-working-holiday-417',
        'btnLabel': isEn ? 'View Subclass 417 on Home Affairs' : 'Ver Subclase 417 en Home Affairs',
      },
      {
        'title': isEn ? 'Status of Country Caps (Annual Quota Monitor)' : 'Estado Oficial de Cupos por País (Country Caps)',
        'desc': isEn
            ? 'Official table published by the Department of Home Affairs showing whether each Subclass 462 country cap is Open, Paused or Closed.'
            : 'Tabla oficial del Department of Home Affairs que muestra el límite anual de plazas por país y si el programa está Abierto o Cerrado.',
        'badge': 'Country Caps',
        'url': 'https://immi.homeaffairs.gov.au/what-we-do/whm-program/status-of-country-caps',
        'btnLabel': isEn ? 'Check Official Country Caps Table' : 'Consultar Tabla Oficial de Cupos',
      },
      {
        'title': isEn ? 'Functional English — Official Scores & Exams' : 'Nivel de Inglés Funcional — Notas y Exámenes Oficiales',
        'desc': isEn
            ? 'Official minimum scores required by Home Affairs: PTE Academic (30), IELTS (4.5), TOEFL iBT (32) and Cambridge C1 Advanced (147).'
            : 'Puntuaciones mínimas oficiales exigidas por Inmigración: PTE Academic (30), IELTS (4.5), TOEFL iBT (32) y Cambridge C1 CAE (147).',
        'badge': 'Functional English',
        'url': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/english-language/functional-english',
        'btnLabel': isEn ? 'Open Functional English Rules' : 'Abrir Normativa Oficial de Inglés',
      },
      {
        'title': isEn ? 'Health Requirements & Panel Physicians Finder' : 'Exámenes Médicos y Buscador de Clínicas (Panel Physicians)',
        'desc': isEn
            ? 'Check if you need a medical exam or chest X-ray (HAP ID) and find the official clinics authorized by the Australian Embassy in your country.'
            : 'Comprueba si necesitas examen médico o radiografía de tórax (HAP ID) y localiza las clínicas autorizadas en tu país.',
        'badge': 'Health & HAP ID',
        'url': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/health',
        'btnLabel': isEn ? 'Open Official Health Requirements' : 'Ver Requisitos Médicos y Clínicas',
      },
      {
        'title': isEn ? 'Global Visa Processing Times Tool' : 'Tiempos Oficiales de Procesamiento de Visados',
        'desc': isEn
            ? 'Official Home Affairs interactive tool showing how many days 50% and 90% of Subclass 462 and 417 applications take to be granted.'
            : 'Herramienta interactiva oficial de Home Affairs con los tiempos reales de espera para el 50% y 90% de las solicitudes.',
        'badge': 'Processing Times',
        'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-processing-times/global-visa-processing-times',
        'btnLabel': isEn ? 'Open Official Processing Times' : 'Consultar Tiempos de Espera Oficiales',
      },
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: portals.length,
      itemBuilder: (context, idx) {
        final p = portals[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p['badge']!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const Icon(CupertinoIcons.shield_lefthalf_fill, size: 16, color: AppColors.secondary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                p['title']!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p['desc']!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => UrlLauncherService.openUrl(context, p['url']!),
                  icon: const Icon(CupertinoIcons.arrow_up_right_square_fill, size: 16, color: Colors.white),
                  label: Text(
                    p['btnLabel']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOfficialVisaSourcesModal(BuildContext context, bool isEn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(CupertinoIcons.shield_lefthalf_fill, color: AppColors.secondary, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEn
                            ? 'Official Australian Government Sources'
                            : 'Fuentes Oficiales del Gobierno de Australia',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isEn
                      ? 'All visa application requirements in OzAlert are verified against the official Department of Home Affairs regulations:'
                      : 'Todos los requisitos y guías de solicitud de visado están verificados directamente con la normativa oficial del Department of Home Affairs:',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),
                _buildOfficialSourceTile(
                  context,
                  title: 'Work and Holiday Visa (Subclass 462) — Step by Step',
                  subtitle: 'immi.homeaffairs.gov.au — First Work and Holiday 462',
                  url: 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462',
                ),
                _buildOfficialSourceTile(
                  context,
                  title: 'Working Holiday Visa (Subclass 417) — Step by Step',
                  subtitle: 'immi.homeaffairs.gov.au — First Working Holiday 417',
                  url: 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-417/first-working-holiday-417',
                ),
                _buildOfficialSourceTile(
                  context,
                  title: 'ImmiAccount Official Portal (Login & Registration)',
                  subtitle: 'online.immi.gov.au — Department of Home Affairs',
                  url: 'https://online.immi.gov.au/lusc/login',
                ),
                _buildOfficialSourceTile(
                  context,
                  title: 'Status of Country Caps (Cupos Anuales 462)',
                  subtitle: 'immi.homeaffairs.gov.au — Working Holiday Maker Program',
                  url: 'https://immi.homeaffairs.gov.au/what-we-do/whm-program/status-of-country-caps',
                ),
                _buildOfficialSourceTile(
                  context,
                  title: 'Functional English Requirements (PTE, IELTS, TOEFL, CAE)',
                  subtitle: 'immi.homeaffairs.gov.au — English language requirements',
                  url: 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/english-language/functional-english',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      isEn ? 'Close' : 'Cerrar',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfficialSourceTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: const Icon(CupertinoIcons.globe, color: AppColors.primary, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        trailing: const Icon(CupertinoIcons.arrow_up_right_square, color: AppColors.secondary, size: 18),
        onTap: () => UrlLauncherService.openUrl(context, url),
      ),
    );
  }

  // ===========================================================================
  // BASE DE DATOS ESTRUCTURADA DE LAS 7 GUÍAS DE SOLICITUD DE VISADO (FASE 1)
  // ===========================================================================
  Map<String, dynamic> _getVisaGuideData(String categoryId, bool isEn) {
    switch (categoryId) {
      case 'identity_documents':
        return {
          'title': isEn
              ? 'Passport, Birth Certificate & Identity Documents'
              : 'Pasaporte, Certificado de Nacimiento y Documentos de Identidad',
          'subtitle': isEn
              ? 'Exact scanning rules and validity requirements required by Home Affairs.'
              : 'Reglas exactas de vigencia, escaneo a color y documentos familiares exigidos por Home Affairs.',
          'officialUrl': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#HowTo',
          'officialLabel': isEn
              ? 'View Official Identity Document Rules (Home Affairs)'
              : 'Ver Normativa Oficial de Documentos de Identidad (Home Affairs)',
          'steps': [
            {
              'title': isEn ? 'Check Passport Validity (+12 Months)' : 'Verificar vigencia del Pasaporte (+12 meses)',
              'summary': isEn
                  ? 'Your passport is electronically linked to your visa. Renew it beforehand if it expires soon.'
                  : 'Tu visado queda vinculado electrónicamente a tu número de pasaporte.',
              'body': isEn
                  ? 'Home Affairs requires a valid eligible passport (minimum 6 months validity to apply, though 12+ months is strongly recommended so it covers your entire stay). Scan the bio-data page (photo, personal details, issue/expiry dates and signature) in high-resolution colour.'
                  : 'El Department of Home Affairs exige pasaporte en vigor (mínimo 6 meses legales, pero se recomienda encarecidamente al menos 12 a 18 meses de vigencia para cubrir toda tu estancia). Escanea a color y en alta resolución la página biográfica donde aparecen tu foto, firma, datos y fechas.',
              'tip': isEn
                  ? 'Pro Tip: If you renew your passport after applying or getting the visa, you must update your new passport details in ImmiAccount before flying.'
                  : 'Tip Pro: Si renuevas el pasaporte después de pedir la visa, debes actualizar el nuevo número en ImmiAccount (Update details) antes de volar.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
              'urlLabel': isEn ? 'Official Passport Eligibility Rules' : 'Ver Requisitos Oficiales de Pasaporte',
            },
            {
              'title': isEn ? 'Full Birth Certificate (With Parents\' Names)' : 'Certificado Literal de Nacimiento (Con nombres de padres)',
              'summary': isEn
                  ? 'Must show the full names of both parents.'
                  : 'Debe mostrar obligatoriamente el nombre completo de ambos padres.',
              'body': isEn
                  ? 'For Subclass 462/417, Home Affairs asks for a full birth certificate showing the names of both your parents. In Spain and EU countries, you can request the Multilingual Birth Certificate (Certificado Plurilingüe) which is already valid in English, or translate your literal certificate with a certified translator.'
                  : 'Home Affairs solicita el Certificado Literal de Nacimiento donde figuren los nombres de ambos progenitores. En España puedes descargar gratis con Cl@ve o certificado digital el Certificado de Nacimiento Plurilingüe (o traducir el literal con traductor jurado). En Latinoamérica solicita la partida de nacimiento íntegra.',
              'tip': isEn
                  ? 'If you cannot provide a birth certificate, you can upload your family book (Libro de Familia) showing parents\' names.'
                  : 'Si usas el modelo plurilingüe europeo, asegúrate de que incluya la casilla con traducción al inglés o adjunta traducción oficial.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#HowTo',
              'urlLabel': isEn ? 'View Step 2: Gather your documents' : 'Ver Paso 2 Oficial: Reunir documentos de identidad',
            },
            {
              'title': isEn ? 'National ID Card (DNI / Cédula) & Passport Photo' : 'DNI / Cédula de Identidad y Fotografía Digital',
              'summary': isEn
                  ? 'Colour scan of both sides of your ID and a digital passport-size photo.'
                  : 'Escaneo a color por ambas caras de tu DNI/Cédula y fotografía tipo carnet en JPG/PDF.',
              'body': isEn
                  ? 'Scan both the front and back of your National Identity Card (DNI / Cédula) in colour on a single PDF page. Also prepare a recent digital passport photo (45mm x 35mm, plain light background, neutral expression, head and shoulders visible).'
                  : 'Escanea el anverso y reverso de tu DNI o Cédula de Identidad a color. Prepara también una fotografía digital reciente tamaño pasaporte (45x35 mm, fondo blanco o claro liso, rostro despejado sin gafas ni sombreros) lista para adjuntar en ImmiAccount.',
              'tip': isEn
                  ? 'Do not use black-and-white scans: Home Affairs only accepts colour scans of original documents without translation.'
                  : 'Nunca subas escaneos en blanco y negro de documentos originales: Inmigración exige que todo original escaneado sea a color.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/applying-online-or-on-paper/online/prepare-your-documents',
              'urlLabel': isEn ? 'Official Document Scanning Specifications' : 'Especificaciones Oficiales de Escaneo en ImmiAccount',
            },
          ],
          'comparisons': [
            {
              'name': isEn ? 'Colour Scan of Original Passport' : 'Pasaporte Original Escaneado a Color',
              'badge': isEn ? 'MANDATORY' : 'OBLIGATORIO',
              'pros': isEn ? 'No translation needed (already bilingual with English).' : 'No requiere traducción jurada (ya incluye campos en inglés).',
              'cons': isEn ? 'Phone photos with glare or cut edges can delay processing.' : 'Fotos de móvil con reflejos del flash o bordes cortados retrasan la aprobación.',
              'requirement': isEn ? 'Bio-data page in colour PDF/JPG (<5 MB).' : 'Página de datos y foto en PDF o JPG a color (<5 MB).',
              'url': 'https://immi.homeaffairs.gov.au/help-support/applying-online-or-on-paper/online/prepare-your-documents',
              'urlLabel': isEn ? 'Prepare Your Documents (Home Affairs)' : 'Guía Oficial para Preparar Documentos',
            },
            {
              'name': isEn ? 'Birth Certificate & National ID' : 'Certificado de Nacimiento y DNI / Cédula',
              'badge': isEn ? 'IDENTITY PROOF' : 'IDENTIDAD',
              'pros': isEn ? 'Verifies parentage and national identity number.' : 'Acredita filiación de padres y número nacional de identidad.',
              'cons': isEn ? 'Must be translated into English if only in Spanish.' : 'Requiere traducción oficial al inglés si está solo en español.',
              'requirement': isEn ? 'Original colour scan + English translation.' : 'Original a color + traducción oficial al inglés.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#HowTo',
              'urlLabel': isEn ? 'Official Subclass 462 Checklist' : 'Ver Checklist Oficial Subclase 462',
            },
          ],
        };

      case 'english_language':
        return {
          'title': isEn
              ? 'Functional English Requirement (Accepted Exams & Scores)'
              : 'Requisito de Inglés Funcional (Exámenes y Notas Oficiales)',
          'subtitle': isEn
              ? 'Required for all Subclass 462 applicants (valid for 12 months before lodging).'
              : 'Obligatorio para la Subclase 462: exámenes aceptados, puntuaciones mínimas y validez de 12 meses.',
          'officialUrl': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/english-language/functional-english',
          'officialLabel': isEn
              ? 'Open Official Functional English Table (Home Affairs)'
              : 'Abrir Tabla Oficial de Inglés Funcional (Home Affairs)',
          'steps': [
            {
              'title': isEn ? 'Choose an Official Accepted Exam (PTE, IELTS, TOEFL, CAE)' : 'Elegir un Examen Oficial Aceptado (PTE, IELTS, TOEFL o CAE)',
              'summary': isEn
                  ? 'You must complete the test within the 12 months before you apply for the visa.'
                  : 'El examen debe haberse realizado como máximo en los 12 meses previos a solicitar la visa.',
              'body': isEn
                  ? 'To meet Functional English for Subclass 462, you need one of these minimum overall scores:\n• PTE Academic: 30 overall\n• IELTS (General or Academic): 4.5 average across the 4 components\n• TOEFL iBT: 32 total score\n• Cambridge C1 Advanced (CAE): 147 overall\nNote: Home-edition / online tests taken at home (such as IELTS Online, PTE Online or TOEFL iBT Home Edition) are NOT accepted by Australian Immigration.'
                  : 'Para cumplir el nivel "Functional English" en la Subclase 462 necesitas alcanzar la nota global mínima en UNO de estos exámenes presenciales:\n• PTE Academic: 30 puntos globales (sobre 90)\n• IELTS (General o Academic): 4.5 de media global en las 4 destrezas\n• TOEFL iBT: 32 puntos totales\n• Cambridge C1 Advanced (CAE): 147 puntos globales\n⚠️ MUY IMPORTante: Home Affairs NO acepta exámenes realizados desde casa (Online / Home Edition). Debe hacerse presencialmente en un centro examinador oficial.',
              'tip': isEn
                  ? 'Pro Tip: PTE Academic is the community favourite because it is 100% computer-graded and results usually arrive in 24 to 48 hours.'
                  : 'Tip Pro: El PTE Academic es el favorito de la comunidad porque lo corrige un algoritmo por ordenador y la nota suele llegar en solo 24 a 48 horas.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/english-language/functional-english',
              'urlLabel': isEn ? 'Verify Official Scores on Home Affairs' : 'Verificar Puntuaciones en Home Affairs',
            },
            {
              'title': isEn ? 'Remember the Strict 12-Month Validity Rule' : 'Regla estricta de caducidad de 12 meses para inmigración',
              'summary': isEn
                  ? 'Even if your diploma says valid for 2 years, Immigration only accepts tests taken in the last 12 months.'
                  : 'Aunque el certificado diga que dura 2 años, para el visado caduca a los 12 meses exactos.',
              'body': isEn
                  ? 'A very common mistake is applying with an IELTS or Cambridge C1 taken 14 months ago. For the Work and Holiday (Subclass 462) visa, the test date must be no more than 12 months before the day you lodge and pay for your visa in ImmiAccount.'
                  : 'Uno de los errores más frecuentes de rechazo es presentar un IELTS, TOEFL o Cambridge sacado hace más de un año. Aunque para universidades dure 2 años, la normativa del Department of Home Affairs exige que el examen se haya realizado dentro de los 12 meses inmediatamente anteriores al día en que envías y pagas tu solicitud.',
              'tip': isEn
                  ? 'Can I apply without an exam? Only if you completed a university degree of at least 2 years taught 100% in English, or 5 years of secondary school in English.'
                  : '¿Se puede justificar sin examen? Solo si has cursado una carrera/grado de al menos 2 años impartido 100% en inglés (presentando certificado oficial de la universidad que acredite que el idioma de instrucción fue el inglés).',
              'url': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/english-language/functional-english',
              'urlLabel': isEn ? 'Read 12-Month Validity & Exemptions' : 'Ver Validez de 12 Meses y Exenciones Oficiales',
            },
          ],
          'comparisons': [
            {
              'name': 'PTE Academic (Pearson)',
              'badge': isEn ? '⭐ FASTEST (24-48H)' : '⭐ MÁS RÁPIDO (24-48H)',
              'pros': isEn
                  ? 'Minimum score: 30/90 (equivalent to A2/B1). Results in 24-48 hours. 100% computer-based.'
                  : 'Nota mínima muy asequible: 30 sobre 90 puntos. Resultados en 24-48 horas. 100% en ordenador.',
              'cons': isEn ? 'Must be taken at an official Pearson VUE test centre.' : 'Debes reservar plaza presencial en un centro oficial Pearson VUE.',
              'requirement': isEn ? 'Minimum overall score: 30 points (No minimum per band for 462).' : 'Nota mínima exigida: 30 puntos globales (no exige mínimo por banda en la 462).',
              'url': 'https://www.pearsonpte.com/',
              'urlLabel': isEn ? 'Open Official Pearson PTE Website' : 'Abrir Web Oficial de Pearson PTE',
            },
            {
              'name': 'IELTS (General Training / Academic)',
              'badge': 'SCORE ≥ 4.5',
              'pros': isEn
                  ? 'Available in many cities worldwide (British Council / IDP). Paper or computer format.'
                  : 'Gran disponibilidad de centros (British Council / IDP). Opción en ordenador (resultados en 3-5 días).',
              'cons': isEn ? 'Speaking is face-to-face with an examiner.' : 'La parte de Speaking se hace con un examinador humano.',
              'requirement': isEn ? 'Average band score of at least 4.5 across the 4 components.' : 'Media global de al menos 4.5 entre las 4 partes del examen.',
              'url': 'https://ielts.org/',
              'urlLabel': isEn ? 'Open Official IELTS Website' : 'Abrir Web Oficial de IELTS',
            },
            {
              'name': 'TOEFL iBT / Cambridge C1 (CAE)',
              'badge': 'TOEFL ≥ 32 / CAE ≥ 147',
              'pros': isEn
                  ? 'Accepted if taken in an authorized test centre within the last 12 months.'
                  : 'Válidos si se realizan en centro presencial autorizado dentro de los últimos 12 meses.',
              'cons': isEn
                  ? 'Cambridge B1 (PET) and B2 (First/FCE) are NOT accepted by Home Affairs—only C1 Advanced (CAE ≥ 147).'
                  : '¡OJO! El B1 (PET) y el B2 (First/FCE) de Cambridge NO sirven para inmigración; de Cambridge solo aceptan el examen C1 Advanced (CAE) sacando ≥ 147.',
              'requirement': isEn ? 'TOEFL iBT ≥ 32 total | Cambridge C1 Advanced (CAE) ≥ 147.' : 'TOEFL iBT ≥ 32 puntos totales | Cambridge C1 CAE ≥ 147 puntos.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/english-language/functional-english',
              'urlLabel': isEn ? 'Check Official Home Affairs Exam List' : 'Consultar Lista Oficial en Home Affairs',
            },
          ],
        };

      case 'education':
        return {
          'title': isEn
              ? 'Education & Academic Qualification Requirements'
              : 'Requisitos de Educación y Estudios por País',
          'subtitle': isEn
              ? 'What degrees, diplomas or university years qualify for your passport under Subclass 462.'
              : 'Qué títulos universitarios, grados superiores o años de carrera exige Home Affairs según tu nacionalidad.',
          'officialUrl': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
          'officialLabel': isEn
              ? 'Open Education Rules by Country (Home Affairs)'
              : 'Abrir Requisitos de Estudios por País (Home Affairs)',
          'steps': [
            {
              'title': isEn ? 'Check the Exact Requirement for Your Passport' : 'Comprobar el requisito exacto según tu pasaporte',
              'summary': isEn
                  ? 'Spain, Argentina, Peru, Ecuador & Uruguay require a degree, tertiary diploma or 2 completed years of university.'
                  : 'España, Argentina, Perú, Ecuador y Uruguay exigen título universitario, grado superior o 2 años de carrera.',
              'body': isEn
                  ? 'Under Subclass 462 ("Have this education" section on Home Affairs):\n• Spain, Argentina, Peru, Ecuador, Uruguay, Portugal, etc.: You must hold a tertiary qualification (University Degree / Grado Superior), OR have satisfactorily completed at least 2 years of undergraduate university study.\n• Chile: Must hold a tertiary qualification or have completed 2 years of university study (or technical tertiary diploma).\n• Subclass 417 Passports (Italy, France, Germany, UK, etc.): No university or tertiary education is required.'
                  : 'Según el acuerdo bilateral de cada país en la Subclase 462 ("Have this education" en Home Affairs):\n• España, Argentina, Perú, Ecuador, Uruguay, Portugal: Tener un título universitario (Grado/Licenciatura), un título de Formación Profesional de Grado Superior / Terciario (mín. 2 años), O haber aprobado satisfactoriamente al menos los 2 primeros años de una carrera universitaria (120 créditos ECTS en España).\n• Chile: Título universitario, título técnico de nivel superior o 2 años de estudios universitarios aprobados.\n• Si aplicas con pasaporte de Subclase 417 (ej. doble nacionalidad italiana, francesa o alemana): NO se exige requisito de estudios superiores.',
              'tip': isEn
                  ? 'Secondary school (Bachillerato), ESO, or Grado Medio (Intermediate FP) do NOT meet the tertiary requirement for Spain.'
                  : 'Importante para España: Bachillerato o FP de Grado Medio NO cumplen el requisito; debe ser Grado Superior (CFGS) o al menos 2 años completos aprobados de universidad.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
              'urlLabel': isEn ? 'Check Official Education List by Country' : 'Ver Lista Oficial por País en Home Affairs',
            },
            {
              'title': isEn ? 'What Official Document to Upload in ImmiAccount' : 'Qué documento oficial subir a ImmiAccount',
              'summary': isEn
                  ? 'Upload your official Diploma, European Diploma Supplement (SET) or Academic Transcript.'
                  : 'Sube tu Título Oficial, Suplemento Europeo al Título (SET) o Certificado Académico Oficial.',
              'body': isEn
                  ? '• If you already graduated: Upload a colour scan of your official Degree Certificate (or official provisional degree certificate with verification code CSV) plus its official English translation (or European Diploma Supplement in English).\n• If you are still studying (2+ years completed): Upload an official Academic Transcript (Certificado Académico Personal) signed by your university confirming you have passed at least 2 full academic years (e.g. 120 ECTS credits) + official English translation.'
                  : '• Si ya te graduaste: Sube el escaneo a color de tu Título Oficial (o Certificado Supletorio Provisional del Título con código CSV) junto con su traducción jurada al inglés (o el Suplemento Europeo al Título si ya viene en inglés).\n• Si sigues estudiando pero tienes 2 años aprobados: Solicita a tu universidad el Certificado Académico Oficial de Notas donde conste que has superado al menos 2 cursos completos (120 créditos ECTS) y adjunta su traducción oficial al inglés.',
              'tip': isEn
                  ? 'Simple screenshots of your student portal without university stamp/signature can be rejected. Always request the official stamped/CSV PDF.'
                  : 'Evita subir simples capturas de pantalla de la intranet sin sello ni firma electrónica (CSV): pide siempre el certificado académico oficial.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#HowTo',
              'urlLabel': isEn ? 'View Official Document Instructions' : 'Ver Instrucciones de Documentos en Home Affairs',
            },
          ],
          'comparisons': [
            {
              'name': isEn ? 'Completed University Degree / Grado Superior' : 'Título Universitario o FP de Grado Superior Finalizado',
              'badge': isEn ? '100% VALID' : '100% VÁLIDO',
              'pros': isEn ? 'Direct approval with Diploma or official provisional certificate.' : 'Aceptación directa con el título definitivo o certificado supletorio provisional.',
              'cons': isEn ? 'Requires English translation if not issued in English.' : 'Requiere traducción jurada al inglés (salvo que tengas el Suplemento Europeo en inglés).',
              'requirement': isEn ? 'Official Degree / Diploma + English translation.' : 'Título oficial a color + Traducción oficial al inglés.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
              'urlLabel': isEn ? 'Verify on Home Affairs' : 'Verificar en Home Affairs',
            },
            {
              'name': isEn ? '2 Years of University Study Completed' : '2 Años de Universidad Aprobados (Sin haber terminado)',
              'badge': isEn ? '120+ ECTS' : '120+ CRÉDITOS',
              'pros': isEn ? 'Allows you to apply before finishing your 4-year university degree.' : 'Te permite pedir el visado sin haber terminado los 4 años de carrera.',
              'cons': isEn ? 'Must upload official Academic Transcript showing all passed subjects.' : 'Debes adjuntar el Certificado Académico Personal oficial con los créditos superados.',
              'requirement': isEn ? 'Official Academic Transcript + English translation.' : 'Certificado Académico Oficial + Traducción jurada al inglés.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
              'urlLabel': isEn ? 'Verify on Home Affairs' : 'Verificar en Home Affairs',
            },
          ],
        };

      case 'enough_money':
        return {
          'title': isEn
              ? 'Proof of Funds (\$5,000 AUD + Return Ticket)'
              : 'Demostración de Fondos Económicos (\$5.000 AUD + Vuelo)',
          'subtitle': isEn
              ? 'How to prepare your bank certificate so Immigration approves it without delays.'
              : 'Cómo generar el extracto bancario para acreditar los \$5.000 AUD y el billete de salida.',
          'officialUrl': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
          'officialLabel': isEn
              ? 'View Official Financial Requirements (Home Affairs)'
              : 'Ver Requisito Oficial de Fondos en Home Affairs',
          'steps': [
            {
              'title': isEn ? 'Calculate the Exact Minimum Balance Required' : 'Calcular el saldo mínimo recomendado en tu cuenta',
              'summary': isEn
                  ? '\$5,000 AUD (~3,100 €) for your stay + extra funds for a return flight (~1,000 €).'
                  : '\$5.000 AUD (~3.100 €) para tu estancia + fondos adicionales para el vuelo de salida.',
              'body': isEn
                  ? 'Home Affairs requires proof of at least \$5,000 AUD to support yourself Initially in Australia, PLUS either a return/onward plane ticket OR enough extra money to buy one. Since Home Affairs recommends not buying flights before your visa is granted, the safest rule is to show a single bank balance equivalent to \$6,000 – \$6,500 AUD (approx. 3,800 € to 4,200 € or \$4,200 USD).'
                  : 'El Department of Home Affairs exige demostrar al menos \$5.000 AUD para mantenerte al llegar a Australia, MÁS un billete de salida de Australia O el dinero extra para comprarlo. Como la propia embajada recomienda NO comprar vuelos antes de tener el visado aprobado, lo más seguro es mostrar en tu cuenta bancaria el equivalente a unos \$6.000 – \$6.500 AUD en total (aprox. entre 3.800 € y 4.200 € o \$4.200 USD).',
              'tip': isEn
                  ? 'The money does not need to be in Australian Dollars (AUD); your local currency (EUR, USD, CLP, ARS, PEN) is valid as long as it equals or exceeds the AUD amount.'
                  : 'El dinero NO tiene que estar en dólares australianos (AUD): puede estar en euros, dólares o tu moneda local siempre que al cambio supere los \$5.000 AUD + vuelo.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
              'urlLabel': isEn ? 'Check Official \$5,000 AUD Rule' : 'Ver Regla Oficial de los \$5.000 AUD',
            },
            {
              'title': isEn ? 'Download an Official Bank Certificate / Statement in English' : 'Descargar Certificado de Saldo o Extracto Oficial',
              'summary': isEn
                  ? 'Must show your full name, account number/IBAN, current balance, currency and recent date.'
                  : 'Debe mostrar tu nombre completo, IBAN/cuenta, saldo actual, divisa y fecha reciente.',
              'body': isEn
                  ? 'Generate the statement within the 7 to 15 days before applying. Many digital banks (Wise, Revolut, N26, BBVA, Santander, CaixaBank) let you download a "Certificate of Balance" or "Account Statement" directly in English from the app for free, saving you translation costs!'
                  : 'Descarga el documento como máximo entre 7 y 15 días antes de enviar tu solicitud. Bancos como Wise, Revolut, N26 y la mayoría de bancos tradicionales permiten descargar desde la propia app el "Certificado de Titularidad y Saldo" o el extracto directamente en idioma inglés, ¡así te ahorras pagar traducción jurada de este documento!',
              'tip': isEn
                  ? 'What if the account is in my parents\' name? Try to transfer the funds to an account where YOU are the account holder or co-holder.'
                  : 'Lo más rápido y libre de trabas es que tú figures como titular (o cotitular) de la cuenta bancaria donde están los fondos.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#HowTo',
              'urlLabel': isEn ? 'View Official Proof of Funds Instructions' : 'Ver Instrucciones Oficiales en Home Affairs',
            },
          ],
          'comparisons': [
            {
              'name': isEn ? 'Wise / Revolut Statement in English' : 'Extracto Oficial en Inglés (Wise / Revolut / N26)',
              'badge': isEn ? '⭐ ZERO TRANSLATION FEE' : '⭐ SIN COSTE DE TRADUCCIÓN',
              'pros': isEn ? 'Instant PDF generated in English with official stamp, currency and full name.' : 'Genera el PDF al instante en inglés o en dólares australianos (AUD) sin pagar traductor.',
              'cons': isEn ? 'Make sure your full name matches your passport exactly.' : 'Verifica que aparezca tu nombre y apellidos tal como figuran en el pasaporte.',
              'requirement': isEn ? 'Recommended balance: ≥ \$6,000 AUD equivalent.' : 'Saldo total recomendado: equivalente a ≥ \$6.000 AUD (~3.900 €).',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
              'urlLabel': isEn ? 'Verify Financial Rules' : 'Verificar Reglas Financieras en Home Affairs',
            },
            {
              'name': isEn ? 'Traditional Bank Certificate' : 'Certificado de Saldo de Banco Tradicional',
              'badge': isEn ? 'TRADITIONAL BANK' : 'BANCO TRADICIONAL',
              'pros': isEn ? 'Signed/stamped PDF from your main bank.' : 'Certificado con sello o código CSV de tu banco habitual.',
              'cons': isEn ? 'If issued only in Spanish, it requires an official English translation.' : 'Si tu banco solo lo emite en español, tendrás que traducirlo oficialmente al inglés.',
              'requirement': isEn ? 'Must be dated within 15-30 days before application.' : 'Debe tener fecha reciente (máximo 15-30 días de antigüedad al aplicar).',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#HowTo',
              'urlLabel': isEn ? 'View Home Affairs Document Guide' : 'Ver Guía de Documentos en Home Affairs',
            },
          ],
        };

      case 'character_health':
        return {
          'title': isEn
              ? 'Police Certificates (Character) & Medical Exams (Health)'
              : 'Antecedentes Penales (Carácter) y Exámenes Médicos (Salud)',
          'subtitle': isEn
              ? 'When you need a Police Check or a Panel Physician medical exam (HAP ID).'
              : 'Cuándo necesitas Certificado de Antecedentes Penales o revisión médica con código HAP ID.',
          'officialUrl': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/character',
          'officialLabel': isEn
              ? 'Open Official Character & Health Rules (Home Affairs)'
              : 'Abrir Normativa de Antecedentes y Salud (Home Affairs)',
          'steps': [
            {
              'title': isEn ? 'Police Certificate (Countries Lived 12+ Months)' : 'Certificado de Antecedentes Penales (Estancias de +12 meses)',
              'summary': isEn
                  ? 'Official police clearance from countries where you lived 12+ months in the last 10 years.'
                  : 'Certificado oficial de países donde hayas vivido 12 meses o más en los últimos 10 años.',
              'body': isEn
                  ? 'You must declare any criminal record truthfully and provide an official Police Certificate for every country where you have spent a total of 12 months or more in the last 10 years since turning 16. In Spain, you can download the Certificado de Antecedentes Penales online from the Ministry of Justice in minutes with Cl@ve / Digital Certificate.'
                  : 'Debes contar con el Certificado de Antecedentes Penales de cada país en el que hayas residido 12 meses o más (continuos o acumulados) en los últimos 10 años desde que cumpliste 16 años. En España se descarga al instante en la sede electrónica del Ministerio de Justicia con Cl@ve o Certificado Digital.',
              'tip': isEn
                  ? 'Police certificates are valid for 12 months from their issue date for Australian Immigration.'
                  : 'Para inmigración australiana, el Certificado de Antecedentes Penales tiene una validez de 12 meses desde su fecha de emisión.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/character',
              'urlLabel': isEn ? 'View Official Character Requirements' : 'Ver Requisitos Oficiales de Carácter (Home Affairs)',
            },
            {
              'title': isEn ? 'Health Examinations & Chest X-Ray (HAP ID)' : 'Exámenes Médicos y Radiografía de Tórax (Código HAP ID)',
              'summary': isEn
                  ? 'Only required if you lived in certain countries or plan to work in healthcare/childcare.'
                  : 'Requerido según el riesgo de tuberculosis de tu país o si trabajarás en sanidad/educación.',
              'body': isEn
                  ? 'Depending on the countries you have visited/lived in during the last 5 years (tuberculosis risk list) or if you plan to work in hospitals, aged care or childcare in Australia, ImmiAccount will generate a "HAP ID" referral letter after you submit your visa or via "My Health Declarations". You can only do the medical exam at an official Panel Physician clinic approved by the Australian Government.'
                  : 'Según el país donde hayas residido los últimos 5 años (lista de riesgo de tuberculosis de Home Affairs) o si planeas trabajar en hospitales, residencias o guarderías en Australia, ImmiAccount te generará una carta con tu número "HAP ID" tras enviar la solicitud. Con ese HAP ID pides cita únicamente en una clínica autorizada ("Panel Physician") por la Embajada de Australia.',
              'tip': isEn
                  ? 'Never go to a regular doctor: only Panel Physicians linked to eMedical can upload your results directly to Home Affairs.'
                  : 'No vayas a un médico cualquiera: solo las clínicas Panel Physician conectadas al sistema eMedical pueden enviar tus pruebas a Australia.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/health/when-to-have-health-examinations',
              'urlLabel': isEn ? 'Find Official Panel Physicians & Health Rules' : 'Buscar Clínicas Autorizadas y Normativa de Salud',
            },
          ],
          'comparisons': [
            {
              'name': isEn ? 'National Police Certificate' : 'Certificado Nacional de Antecedentes Penales',
              'badge': isEn ? 'VALID 12 MONTHS' : 'VALIDEZ 12 MESES',
              'pros': isEn ? 'Fast online issuance in Spain, Chile, Argentina and Peru.' : 'Emisión online rápida en la mayoría de países (Ministerio de Justicia / Registro Civil).',
              'cons': isEn ? 'Requires official English translation if issued in Spanish.' : 'Debe ir acompañado de traducción oficial al inglés.',
              'requirement': isEn ? 'For any country where you lived ≥ 12 months since age 16.' : 'Para cualquier país donde hayas vivido ≥ 12 meses desde los 16 años.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/meeting-our-requirements/character',
              'urlLabel': isEn ? 'Character Requirements (Home Affairs)' : 'Requisitos de Carácter (Home Affairs)',
            },
            {
              'name': isEn ? 'Panel Physician Medical Exam (eMedical)' : 'Examen Médico Oficial (Panel Physician - eMedical)',
              'badge': 'HAP ID',
              'pros': isEn ? 'Clinic sends results electronically via eMedical in 2-5 days.' : 'La clínica sube los resultados directamente a inmigración por eMedical en 2-5 días.',
              'cons': isEn ? 'Only required if requested by ImmiAccount after submission.' : 'Solo debes hacerlo si ImmiAccount te lo solicita en "Health Assessment".',
              'requirement': isEn ? 'Bring your passport and the HAP ID letter generated in ImmiAccount.' : 'Acudir con tu pasaporte original y la carta con código HAP ID.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/contact-us/offices-and-locations/list',
              'urlLabel': isEn ? 'Find Panel Physicians by Country' : 'Buscador Oficial de Clínicas por País',
            },
          ],
        };

      case 'translations_support':
        return {
          'title': isEn
              ? 'Official Translations, Government Support Letter & Form 956A'
              : 'Traducciones Oficiales, Carta de Apoyo y Formulario 956A',
          'subtitle': isEn
              ? 'Exact rules for translating non-English documents so your visa is never rejected.'
              : 'Normativa exacta del Gobierno de Australia sobre traducciones juradas/NAATI y formato de archivos.',
          'officialUrl': 'https://immi.homeaffairs.gov.au/help-support/applying-online-or-on-paper/online/prepare-your-documents',
          'officialLabel': isEn
              ? 'Open Official Translation & Document Rules (Home Affairs)'
              : 'Abrir Normativa Oficial de Traducciones (Home Affairs)',
          'steps': [
            {
              'title': isEn ? 'Official Translation Rules (Outside vs Inside Australia)' : 'Reglas Oficiales de Traducción al Inglés (Fuera y Dentro de Australia)',
              'summary': isEn
                  ? 'Every document not in English must include a certified translation with the translator\'s full details.'
                  : 'Todo documento que no esté en inglés debe acompañarse de traducción oficial con datos del traductor.',
              'body': isEn
                  ? 'Home Affairs strictly requires that any document not in English be translated:\n• Translators outside Australia: Do NOT need to be NAATI-accredited, but on EVERY translation they must include in English their full name, address, telephone number, and qualifications/experience in the language being translated (e.g., Sworn Translator / Traductor Jurado).\n• Translators inside Australia: Must be accredited by NAATI.\nAlways upload BOTH the original document scan in colour AND the English translation.'
                  : 'Home Affairs exige que todo documento redactado en español u otro idioma vaya acompañado de traducción al inglés:\n• Traductores fuera de Australia: No necesitan ser NAATI, pero en cada traducción deben incluir obligatoriamente en inglés su nombre completo, dirección, teléfono, firma/sello y su cualificación oficial (ej. Traductor-Intérprete Jurado nombrado por el MAEC o Colegio de Traductores).\n• Traductores dentro de Australia: Deben estar acreditados por NAATI.\nRecuerda adjuntar en el mismo PDF (o en archivos juntos) tanto el original escaneado a color como su traducción.',
              'tip': isEn
                  ? 'Merge the original colour document and its translation into a single PDF per category so your application is super clean for the case officer.'
                  : 'Consejo Pro: Une en un mismo archivo PDF el documento original a color seguido de su traducción oficial para que el agente de inmigración lo revise de un vistazo.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/applying-online-or-on-paper/online/prepare-your-documents',
              'urlLabel': isEn ? 'Read Official Home Affairs Translation Rules' : 'Leer Reglas Oficiales de Traducción en Home Affairs',
            },
            {
              'title': isEn ? 'Letter of Government Support & Form 956 / 956A' : 'Carta de Apoyo Gubernamental y Formulario 956 / 956A',
              'summary': isEn
                  ? 'Spain, Argentina, Chile and Uruguay are EXEMPT from the Government Support Letter.'
                  : 'España, Argentina, Chile y Uruguay están EXENTOS de la Carta de Apoyo Gubernamental.',
              'body': isEn
                  ? '• Letter of Government Support: Only required for specific nationalities such as Ecuador or Peru (issued by their Ministry of Foreign Affairs/Youth). Citizens of Spain, Argentina, Chile, Uruguay, Brazil, Portugal, etc. do NOT need it.\n• Form 956 / 956A: Only required if you hire a Migration Agent or authorize another person to receive emails on your behalf. If you apply on your own, select "No" in ImmiAccount.'
                  : '• Carta de Apoyo del Gobierno: NO es necesaria para España, Argentina, Chile, Uruguay, Brasil ni Portugal. Solo se exige a determinados pasaportes como Ecuador, Perú, Tailandia, etc.\n• Formulario 956 / 956A: Solo debes rellenarlo si contratas a un agente migratorio o autorizas a otra persona a recibir notificaciones. Si haces la solicitud por tu cuenta, marca "No" en ese apartado de ImmiAccount.',
              'tip': isEn
                  ? 'Applying on your own in ImmiAccount is 100% official, free of agency commissions, and takes about 25 minutes.'
                  : 'Hacer tu solicitud por tu cuenta en ImmiAccount es 100% directo, sin intermediarios y te ahorra cientos de euros en agencias.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#Eligibility',
              'urlLabel': isEn ? 'Check Government Letter Exemptions' : 'Ver Lista de Países Exentos en Home Affairs',
            },
          ],
          'comparisons': [
            {
              'name': isEn ? 'Sworn / Certified Translator (Outside Australia)' : 'Traductor Jurado Oficial (Desde tu país)',
              'badge': isEn ? 'MOST ECONOMIC' : 'MÁS ECONÓMICO',
              'pros': isEn ? 'Usually 20€–35€ per document. Accepted by Home Affairs worldwide.' : 'Suele costar entre 20 € y 35 € por documento. 100% aceptado por Home Affairs.',
              'cons': isEn ? 'Must include translator\'s full name, address, phone and stamp in English.' : 'Asegúrate de que incluya su nombre completo, dirección, teléfono y sello.',
              'requirement': isEn ? 'Attach original colour scan + signed translation.' : 'Adjuntar original a color + traducción firmada.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/applying-online-or-on-paper/online/prepare-your-documents',
              'urlLabel': isEn ? 'Official Translation Requirements' : 'Requisitos Oficiales de Traducción',
            },
            {
              'name': isEn ? 'NAATI Accredited Translator (Australia)' : 'Traductor Acreditado NAATI (Australia)',
              'badge': 'NAATI STAMP',
              'pros': isEn ? 'Official Australian national accreditation standard; also valid later for driving licences.' : 'Estándar nacional australiano; te servirá también al llegar para canjear u homologar carnets.',
              'cons': isEn ? 'Slightly higher cost (\$40–\$65 AUD per document).' : 'Precio algo superior (\$40–\$65 AUD por documento).',
              'requirement': isEn ? 'Digital PDF with official NAATI practitioner number and stamp.' : 'PDF digital con sello y número de acreditación NAATI.',
              'url': 'https://www.naati.com.au/',
              'urlLabel': isEn ? 'Open Official NAATI Directory' : 'Abrir Directorio Oficial NAATI',
            },
          ],
        };

      case 'immiaccount_apply':
      default:
        return {
          'title': isEn
              ? 'How to Apply in ImmiAccount Step by Step (Subclass 462 & 417)'
              : 'Cómo Solicitar el Visado en ImmiAccount Paso a Paso (462 y 417)',
          'subtitle': isEn
              ? 'Complete walkthrough from creating your account to paying the \$650 AUD fee and getting your Grant Letter.'
              : 'Guía completa desde la creación de tu cuenta hasta el pago de la tasa oficial (\$650 AUD) y concesión del visado.',
          'officialUrl': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#HowTo',
          'officialLabel': isEn
              ? 'Open Official Step-by-Step Guide on Home Affairs'
              : 'Abrir Guía Paso a Paso en la Web Oficial de Home Affairs',
          'steps': [
            {
              'title': isEn ? 'Create an Individual ImmiAccount & Enable 2FA' : 'Crear cuenta individual en ImmiAccount y activar 2FA',
              'summary': isEn
                  ? 'Register at online.immi.gov.au using your personal email and set up your authenticator code.'
                  : 'Regístrate en online.immi.gov.au con tu correo personal y configura el doble factor.',
              'body': isEn
                  ? '1. Go to the official portal (online.immi.gov.au) and select "Create ImmiAccount" -> "Individual".\n2. Enter your full name exactly as shown on your passport, your email and phone number.\n3. Configure Multi-Factor Authentication (2FA) via Authenticator App or email so you don\'t get locked out on quota opening day.'
                  : '1. Entra en el portal oficial (online.immi.gov.au) y pulsa en "Create ImmiAccount" eligiendo la opción "Individual".\n2. Escribe tu nombre y apellidos exactamente igual que en tu pasaporte (sin tildes ni la letra Ñ si en la zona legible inferior del pasaporte aparece como N).\n3. Configura la verificación en dos pasos (2FA) y verifica tu email para no perder ni un segundo cuando salte la alarma de apertura.',
              'tip': isEn
                  ? 'Create your ImmiAccount weeks before the quota opens so your login is ready.'
                  : 'Crea tu cuenta semanas antes de la apertura de cupos para tener el acceso listo al instante.',
              'url': 'https://online.immi.gov.au/lusc/register',
              'urlLabel': isEn ? 'Register Official ImmiAccount' : 'Crear Cuenta en ImmiAccount Oficial',
            },
            {
              'title': isEn ? 'Start a New Application: Work and Holiday (462 or 417)' : 'Iniciar Solicitud: "First Work and Holiday Visa (462 o 417)"',
              'summary': isEn
                  ? 'Click "New application" -> "Working Holiday Maker" and save your draft.'
                  : 'Pulsa en "New application" -> "Working Holiday Maker" y guarda el borrador.',
              'body': isEn
                  ? 'Inside ImmiAccount:\n1. Click "New application" in the top-left corner.\n2. Open the "Working Holiday Maker" dropdown and select "Work and Holiday Visa (462)" (or "Working Holiday Visa (417)" if applying with an eligible 417 passport).\n3. Complete the pages covering Passport details, National ID, Usual Occupation, Education, Functional English test reference number, Address and Character declarations.\n4. Click "Save" on every page to keep your draft ready.'
                  : 'Dentro de tu ImmiAccount:\n1. Pulsa en "New application" arriba a la izquierda.\n2. Despliega la categoría "Working Holiday Maker" y selecciona "Work and Holiday Visa (462)" (o "417" según tu pasaporte).\n3. Rellena con calma las páginas: datos del pasaporte, DNI, estado civil, ocupación habitual, nivel de estudios, número de referencia de tu examen de inglés y declaraciones de salud y antecedentes.\n4. Pulsa "Save" en cada página para dejar tu borrador guardado.',
              'tip': isEn
                  ? 'Double-check every single digit of your passport number and birth date: a typo here invalidates the linked visa.'
                  : 'Revisa tres veces el número de pasaporte y fecha de nacimiento: el visado es electrónico y va asociado a ese número exacto.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462#HowTo',
              'urlLabel': isEn ? 'View Official Application Steps' : 'Ver Pasos de Solicitud en Home Affairs',
            },
            {
              'title': isEn ? 'Attach Colour PDF Documents (<5 MB per file)' : 'Adjuntar todos los Documentos en PDF a Color (<5 MB)',
              'summary': isEn
                  ? 'Upload Passport, Birth Certificate, Education, English Test and Bank Statement.'
                  : 'Sube Pasaporte, Nacimiento, Estudios, Inglés y Extracto Bancario en sus casillas.',
              'body': isEn
                  ? 'On the "Attach documents" screen of ImmiAccount, upload each PDF under its corresponding section:\n• Travel Document: Passport bio-data page (colour).\n• Birth or Age, Evidence of: Birth Certificate + translation.\n• Evidence of Financial Capacity: Bank statement showing ≥ \$5,000 AUD + flight funds.\n• Qualifications - Overseas, Evidence of: University degree / transcript + translation.\n• Functional English, Evidence of: PTE / IELTS / TOEFL / CAE score report.\n• Character, Evidence of: Police certificate + translation.'
                  : 'En la pantalla "Attach documents" de ImmiAccount, sube cada archivo PDF (máximo 5 MB por archivo, sin contraseña) en su apartado:\n• Travel Document: Página biográfica del pasaporte a color.\n• Birth or Age: Certificado de nacimiento + traducción.\n• Financial Capacity: Certificado bancario de los \$5.000 AUD + fondos de vuelo.\n• Qualifications - Overseas: Título o certificado de 2 años universitarios + traducción.\n• Functional English: Certificado oficial de notas de PTE, IELTS, TOEFL o CAE.\n• Character: Certificado de antecedentes penales + traducción.',
              'tip': isEn
                  ? 'Applications with all documents attached in colour from day 1 are often granted automatically or within days!'
                  : 'Las solicitudes que suben todos los documentos completos y traducidos desde el primer minuto ("Decision Ready") suelen aprobarse mucho más rápido.',
              'url': 'https://immi.homeaffairs.gov.au/help-support/applying-online-or-on-paper/online/prepare-your-documents',
              'urlLabel': isEn ? 'Official Attachment Rules (Home Affairs)' : 'Reglas Oficiales de Archivos Adjuntos',
            },
            {
              'title': isEn ? 'Pay the Official Visa Fee (\$650 AUD) & Submit' : 'Pagar la Tasa Oficial (\$650 AUD) y Enviar ("Submit")',
              'summary': isEn
                  ? 'Your place in the quota is only secured once payment is completed and status says "Received".'
                  : 'Tu plaza solo queda reservada cuando completas el pago y el estado pasa a "Received".',
              'body': isEn
                  ? 'When spots open for your country, log into ImmiAccount, review your saved application, attach the documents, and proceed to payment (\$650 AUD + approx. 1.4% card surcharge). Once paid, click "Submit Application". Make sure your application status changes from "Incomplete" to "Received". You have 12 months from the date the visa is granted to enter Australia, and 12 months of stay from the day you first land!'
                  : 'En cuanto recibas el aviso de apertura de cupos, entra en ImmiAccount, revisa tu borrador, adjunta los documentos y realiza el pago de la tasa oficial (\$650 AUD + ~1,4% de recargo por tarjeta). Asegúrate de que el estado cambie de "Incomplete" a "Received". Desde el día en que te conceden el visado ("Granted"), tienes 12 meses para entrar a Australia, y tu año de visado empieza a contar el día que pisas suelo australiano.',
              'tip': isEn
                  ? 'Use Wise or Revolut with AUD balance to avoid 3-4% hidden exchange rate markups charged by traditional banks.'
                  : 'Usa una tarjeta multimoneda (como Wise o Revolut) con saldo en AUD para ahorrar unos 20-30 € en comisiones de cambio de divisa al pagar la tasa.',
              'url': 'https://online.immi.gov.au/lusc/login',
              'urlLabel': isEn ? 'Open ImmiAccount to Apply' : 'Ir a ImmiAccount para Solicitar la Visa',
            },
          ],
          'comparisons': [
            {
              'name': 'Work and Holiday Visa (Subclass 462)',
              'badge': '\$650 AUD',
              'pros': isEn
                  ? 'For Spain, Argentina, Chile, Peru, Uruguay, Brazil, Portugal, USA, etc. Allows hospitality in Northern/Remote Australia for 88 days.'
                  : 'Para España, Argentina, Chile, Perú, Uruguay, Portugal, etc. Permite renovar los 88 días trabajando en Hostelería en el Norte/Zonas Remotas.',
              'cons': isEn
                  ? 'Annual country quota (except USA), requires Functional English & Tertiary Education.'
                  : 'Sujeta a cupos anuales por país; exige certificado de inglés (Functional English) y estudios superiores.',
              'requirement': isEn ? 'Age 18–30 | \$650 AUD fee | \$5,000 AUD funds.' : 'Edad 18 a 30 años | Tasa oficial: \$650 AUD | Fondos: \$5.000 AUD.',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-work-holiday-462',
              'urlLabel': isEn ? 'Official Subclass 462 Page' : 'Página Oficial Subclase 462 (Home Affairs)',
            },
            {
              'name': 'Working Holiday Visa (Subclass 417)',
              'badge': '\$650 AUD (NO CAP)',
              'pros': isEn
                  ? 'For Italy, France, Germany, UK, Ireland, Canada, etc. Unlimited annual quota (open 365 days), no English exam or university degree required.'
                  : 'Para pasaportes de Italia, Francia, Alemania, UK, Irlanda, etc. Sin límite de cupos anuales (abierta todo el año), no pide examen de inglés ni universidad.',
              'cons': isEn
                  ? 'Hospitality does not count towards the 88 days on 417 (except UK passport holders who are exempt from 88 days).'
                  : 'La hostelería no suma para los 88 días en la 417 (salvo pasaporte británico que está exento de hacer los 88 días).',
              'requirement': isEn ? 'Age 18–30 (up to 35 for Italy, France, UK, Canada, Ireland).' : 'Edad 18–30 años (hasta 35 años para Italia, Francia, UK, Canadá e Irlanda).',
              'url': 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-417/first-working-holiday-417',
              'urlLabel': isEn ? 'Official Subclass 417 Page' : 'Página Oficial Subclase 417 (Home Affairs)',
            },
          ],
        };
    }
  }
}

// ===========================================================================
// PAINTER DEL CAMINO EN 'S' PARA LA EXPEDICIÓN DEL VISADO (FASE 1)
// ===========================================================================
class _VisaSTrailPainter extends CustomPainter {
  final Path basePath;
  final PathMetric metric;
  final double progress;
  final List<Offset> waypoints;
  final int selectedIndex;
  final List<Map<String, dynamic>> stages;

  _VisaSTrailPainter({
    required this.basePath,
    required this.metric,
    required this.progress,
    required this.waypoints,
    required this.selectedIndex,
    required this.stages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(basePath.shift(const Offset(0, 2)), shadowPaint);

    final roadPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(basePath, roadPaint);

    if (progress > 0.0) {
      final activePath = metric.extractPath(0, metric.length * progress);
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(activePath, activePaint);
    }

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const double dashWidth = 5;
    const double dashSpace = 7;
    double distance = 0;
    while (distance < metric.length) {
      final extract = metric.extractPath(distance, (distance + dashWidth).clamp(0.0, metric.length));
      canvas.drawPath(extract, dashPaint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _VisaSTrailPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.selectedIndex != selectedIndex;
  }
}
