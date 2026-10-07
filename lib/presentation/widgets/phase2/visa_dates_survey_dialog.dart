import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/phase2/phase2_providers.dart';

void showVisaDatesSurveyDialogIfNeeded(BuildContext context, WidgetRef ref) {
  final profile = ref.read(userProfileProvider).value;
  if (profile == null) return;

  // Si ya completó la encuesta, no volver a mostrar
  if (profile.datesSurveyCompleted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const VisaDatesSurveyDialog(),
  );
}

class VisaDatesSurveyDialog extends ConsumerStatefulWidget {
  const VisaDatesSurveyDialog({super.key});

  @override
  ConsumerState<VisaDatesSurveyDialog> createState() => _VisaDatesSurveyDialogState();
}

class _VisaDatesSurveyDialogState extends ConsumerState<VisaDatesSurveyDialog> {
  DateTime _lodgementDate = DateTime.now().subtract(const Duration(days: 14));
  DateTime _grantDate = DateTime.now();
  bool _isSaving = false;

  int get _processingDays => _grantDate.difference(_lodgementDate).inDays;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono festivo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.celebration_rounded, color: AppColors.secondary, size: 40),
            ),
            const SizedBox(height: 16),

            const Text(
              '¡Enhorabuena por tu Visado! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Ayuda a la comunidad de OzAlert: dinos cuándo aplicaste y cuándo te lo concedieron para calcular los plazos reales de Inmigración.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Selector 1: Fecha de Solicitud (Lodgement)
            _buildDatePickerTile(
              title: '¿Cuándo solicitaste la visa?',
              selectedDate: _lodgementDate,
              dateFormat: dateFormat,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _lodgementDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _lodgementDate = picked;
                    if (_grantDate.isBefore(_lodgementDate)) {
                      _grantDate = _lodgementDate;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            // Selector 2: Fecha de Concesión (Grant)
            _buildDatePickerTile(
              title: '¿Cuándo te la concedieron?',
              selectedDate: _grantDate,
              dateFormat: dateFormat,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _grantDate,
                  firstDate: _lodgementDate,
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _grantDate = picked);
                }
              },
            ),
            const SizedBox(height: 16),

            // Indicador de días calculados
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                'Tu visado tardó $_processingDays ${_processingDays == 1 ? "día" : "días"} en ser aprobado',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        setState(() => _isSaving = true);
                        final user = ref.read(authStateProvider).value;
                        final profile = ref.read(userProfileProvider).value;

                        try {
                          if (user != null && profile != null) {
                            final country = profile.passports.isNotEmpty ? profile.passports.first : 'ES';
                            await ref.read(visaStatsRepositoryProvider).submitVisaDates(
                                  uid: user.uid,
                                  countryCode: country,
                                  subclass: profile.visaSubclass,
                                  lodgementDate: _lodgementDate,
                                  grantDate: _grantDate,
                                );
                          }
                        } catch (e) {
                          debugPrint('Error submitVisaDates: $e');
                        } finally {
                          if (mounted) navigator.pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar y compartir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),

            // Botón Completar Más Tarde
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Completar más tarde', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTile({
    required String title,
    required DateTime selectedDate,
    required DateFormat dateFormat,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(dateFormat.format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
              ],
            ),
            const Icon(CupertinoIcons.calendar, color: AppColors.secondary, size: 22),
          ],
        ),
      ),
    );
  }
}
