import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AustraliaRegionalMapWidget extends StatelessWidget {
  final String activeState; // 'QLD', 'NSW', 'VIC', 'WA', 'SA', 'TAS', 'NT', 'ACT', or ''
  final String activeZone;  // 'northern', 'remote', 'regional', 'metro', etc.
  final String? activeLocation;
  final bool isEn;
  final Function(String state)? onStateTap;

  const AustraliaRegionalMapWidget({
    super.key,
    required this.activeState,
    required this.activeZone,
    this.activeLocation,
    required this.isEn,
    this.onStateTap,
  });

  @override
  Widget build(BuildContext context) {
    final stateTitle = _getStateFullName(activeState);
    final zoneDescription = _getZoneDescription(activeState, activeZone);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del Mapa
          Row(
            children: [
              const Icon(CupertinoIcons.map_fill, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn ? 'Regional Australia Map (LIN 22/050)' : 'Mapa Regional de Australia (LIN 22/050)',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
              if (activeState.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    activeState,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Renderizado del Mapa Vectorial Interactivo
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: _AustraliaMapPainter(
                activeState: activeState.toUpperCase(),
                primaryColor: AppColors.primary,
                secondaryColor: AppColors.secondary,
                neutralColor: const Color(0xFFE2DCD5),
                borderColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Píldoras de Selección Rápida de Estados
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['WA', 'NT', 'SA', 'QLD', 'NSW', 'VIC', 'TAS'].map((st) {
                final isSelected = activeState.toUpperCase() == st;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => onStateTap?.call(st),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                      ),
                      child: Text(
                        st,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Tarjeta Informativa de la Zona Activa
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: _isZoneEligible(activeZone)
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.statusClosed.withValues(alpha: 0.15),
                  child: Icon(
                    _isZoneEligible(activeZone) ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.xmark_circle_fill,
                    size: 16,
                    color: _isZoneEligible(activeZone) ? AppColors.secondary : AppColors.statusClosed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stateTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        zoneDescription,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isZoneEligible(String zone) {
    return zone != 'metro' && zone != 'unknown';
  }

  String _getStateFullName(String code) {
    switch (code.toUpperCase()) {
      case 'QLD':
        return isEn ? 'Queensland (QLD)' : 'Queensland (QLD)';
      case 'NSW':
        return isEn ? 'New South Wales (NSW)' : 'Nueva Gales del Sur (NSW)';
      case 'VIC':
        return isEn ? 'Victoria (VIC)' : 'Victoria (VIC)';
      case 'WA':
        return isEn ? 'Western Australia (WA)' : 'Australia Occidental (WA)';
      case 'SA':
        return isEn ? 'South Australia (SA)' : 'Australia Meridional (SA)';
      case 'TAS':
        return isEn ? 'Tasmania (TAS)' : 'Tasmania (TAS)';
      case 'NT':
        return isEn ? 'Northern Territory (NT)' : 'Territorio del Norte (NT)';
      case 'ACT':
        return isEn ? 'Australian Capital Territory (ACT)' : 'Territorio Capital (ACT)';
      default:
        return isEn ? 'All Regional Zones' : 'Zonas Regionales de Australia';
    }
  }

  String _getZoneDescription(String state, String zone) {
    final st = state.toUpperCase();
    if (zone == 'northern' || st == 'NT' || (st == 'QLD' && zone.contains('north'))) {
      return isEn
          ? 'Northern Australia Tropical Zone: Eligible for Hospitality & Tourism under Subclass 462, plus Agriculture and Construction.'
          : 'Zona Norte Tropical: Aprobada para Hostelería y Turismo en Subclase 462, además de Campo y Obras.';
    }
    if (st == 'SA' || st == 'TAS') {
      return isEn
          ? 'Entire state is classified regional by Home Affairs. Agriculture & Construction eligible statewide.'
          : 'El 100% del estado califica como área regional oficial según Inmigración (Agricultura y Obras).';
    }
    if (zone == 'metro') {
      return isEn
          ? 'Metropolitan Capital Area: Ineligible for 88 days visa extension specified work.'
          : 'Área Metropolitana: No válida para renovar visado de los 88 días.';
    }
    return isEn
        ? 'Regional Postcode Zone (LIN 22/050): Plant & animal cultivation and construction approved.'
        : 'Zona Regional Aprobada (LIN 22/050): Agricultura, ganadería y construcción válidas.';
  }
}

class _AustraliaMapPainter extends CustomPainter {
  final String activeState;
  final Color primaryColor;
  final Color secondaryColor;
  final Color neutralColor;
  final Color borderColor;

  _AustraliaMapPainter({
    required this.activeState,
    required this.primaryColor,
    required this.secondaryColor,
    required this.neutralColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pintar los 7 estados principales de Australia con proporciones relativas armoniosas
    // 1. Western Australia (WA) - Todo el oeste (40% del ancho)
    _drawState(
      canvas,
      name: 'WA',
      path: Path()
        ..moveTo(w * 0.05, h * 0.25)
        ..lineTo(w * 0.38, h * 0.20)
        ..lineTo(w * 0.38, h * 0.82)
        ..lineTo(w * 0.25, h * 0.85)
        ..lineTo(w * 0.12, h * 0.75)
        ..lineTo(w * 0.05, h * 0.55)
        ..close(),
      labelPoint: Offset(w * 0.20, h * 0.50),
    );

    // 2. Northern Territory (NT) - Centro-Norte
    _drawState(
      canvas,
      name: 'NT',
      path: Path()
        ..moveTo(w * 0.38, h * 0.20)
        ..lineTo(w * 0.60, h * 0.18)
        ..lineTo(w * 0.60, h * 0.52)
        ..lineTo(w * 0.38, h * 0.52)
        ..close(),
      labelPoint: Offset(w * 0.49, h * 0.34),
    );

    // 3. South Australia (SA) - Centro-Sur
    _drawState(
      canvas,
      name: 'SA',
      path: Path()
        ..moveTo(w * 0.38, h * 0.52)
        ..lineTo(w * 0.64, h * 0.52)
        ..lineTo(w * 0.64, h * 0.80)
        ..lineTo(w * 0.52, h * 0.85)
        ..lineTo(w * 0.38, h * 0.82)
        ..close(),
      labelPoint: Offset(w * 0.50, h * 0.66),
    );

    // 4. Queensland (QLD) - Noreste
    _drawState(
      canvas,
      name: 'QLD',
      path: Path()
        ..moveTo(w * 0.60, h * 0.18)
        ..lineTo(w * 0.68, h * 0.05) // Península Cape York
        ..lineTo(w * 0.74, h * 0.15)
        ..lineTo(w * 0.88, h * 0.42)
        ..lineTo(w * 0.64, h * 0.60)
        ..lineTo(w * 0.60, h * 0.52)
        ..close(),
      labelPoint: Offset(w * 0.72, h * 0.36),
    );

    // 5. New South Wales (NSW) - Este medio
    _drawState(
      canvas,
      name: 'NSW',
      path: Path()
        ..moveTo(w * 0.64, h * 0.60)
        ..lineTo(w * 0.88, h * 0.42)
        ..lineTo(w * 0.86, h * 0.75)
        ..lineTo(w * 0.72, h * 0.78)
        ..lineTo(w * 0.64, h * 0.72)
        ..close(),
      labelPoint: Offset(w * 0.75, h * 0.63),
    );

    // 6. Victoria (VIC) - Sureste
    _drawState(
      canvas,
      name: 'VIC',
      path: Path()
        ..moveTo(w * 0.64, h * 0.72)
        ..lineTo(w * 0.72, h * 0.78)
        ..lineTo(w * 0.84, h * 0.76)
        ..lineTo(w * 0.76, h * 0.88)
        ..lineTo(w * 0.62, h * 0.82)
        ..close(),
      labelPoint: Offset(w * 0.72, h * 0.82),
    );

    // 7. Tasmania (TAS) - Isla al sur
    _drawState(
      canvas,
      name: 'TAS',
      path: Path()
        ..moveTo(w * 0.72, h * 0.92)
        ..lineTo(w * 0.78, h * 0.92)
        ..lineTo(w * 0.77, h * 0.98)
        ..lineTo(w * 0.71, h * 0.97)
        ..close(),
      labelPoint: Offset(w * 0.75, h * 0.95),
    );
  }

  void _drawState(Canvas canvas, {required String name, required Path path, required Offset labelPoint}) {
    final isSelected = activeState == name;
    final fillPaint = Paint()
      ..color = isSelected ? primaryColor : neutralColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    // Texto de la abreviatura del estado
    final textSpan = TextSpan(
      text: name,
      style: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontSize: isSelected ? 12.0 : 10.0,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(labelPoint.dx - textPainter.width / 2, labelPoint.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _AustraliaMapPainter oldDelegate) {
    return oldDelegate.activeState != activeState;
  }
}
