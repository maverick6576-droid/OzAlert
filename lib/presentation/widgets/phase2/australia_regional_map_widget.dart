import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RegionalHub {
  final String name;
  final String state;
  final String postcode;
  final double relX;
  final double relY;
  final String icon;
  final String description;

  const RegionalHub({
    required this.name,
    required this.state,
    required this.postcode,
    required this.relX,
    required this.relY,
    required this.icon,
    required this.description,
  });
}

const List<RegionalHub> kRegionalHubs = [
  RegionalHub(name: 'Cairns', state: 'QLD', postcode: '4870', relX: 0.70, relY: 0.18, icon: '🌴', description: 'Reef & Fruit'),
  RegionalHub(name: 'Bundaberg', state: 'QLD', postcode: '4670', relX: 0.86, relY: 0.44, icon: '🍍', description: 'Farms & Berries'),
  RegionalHub(name: 'Byron Bay', state: 'NSW', postcode: '2481', relX: 0.85, relY: 0.57, icon: '🏄', description: 'Blueberries & Coast'),
  RegionalHub(name: 'Darwin', state: 'NT', postcode: '0800', relX: 0.44, relY: 0.17, icon: '🐊', description: 'Top End & Hospitality'),
  RegionalHub(name: 'Alice Springs', state: 'NT', postcode: '0870', relX: 0.50, relY: 0.45, icon: '🐫', description: 'Red Centre Outback'),
  RegionalHub(name: 'Broome', state: 'WA', postcode: '6725', relX: 0.20, relY: 0.24, icon: '🐚', description: 'Kimberley & Tourism'),
  RegionalHub(name: 'Margaret River', state: 'WA', postcode: '6280', relX: 0.13, relY: 0.75, icon: '🍷', description: 'Vineyards & Farm'),
  RegionalHub(name: 'Adelaide Hills', state: 'SA', postcode: '5251', relX: 0.58, relY: 0.79, icon: '🍇', description: 'Statewide Regional'),
  RegionalHub(name: 'Bendigo', state: 'VIC', postcode: '3550', relX: 0.70, relY: 0.77, icon: '🍏', description: 'Fruit Bowl & Cattle'),
  RegionalHub(name: 'Launceston', state: 'TAS', postcode: '7250', relX: 0.74, relY: 0.93, icon: '🍎', description: 'Apple Isle & Cherries'),
];

class AustraliaRegionalMapWidget extends StatelessWidget {
  final String activeState; // 'QLD', 'NSW', 'VIC', 'WA', 'SA', 'TAS', 'NT', 'ACT', or ''
  final String activeZone;  // 'northern', 'remote', 'regional', 'metro', etc.
  final String? activeLocation;
  final String? activePostcode;
  final bool isEn;
  final Function(String postcode, String state)? onRegionSelected;
  final Function(String state)? onStateTap;

  const AustraliaRegionalMapWidget({
    super.key,
    required this.activeState,
    required this.activeZone,
    this.activeLocation,
    this.activePostcode,
    required this.isEn,
    this.onRegionSelected,
    this.onStateTap,
  });

  void _handleMapTap(Offset localOffset, Size size) {
    final normX = (localOffset.dx / size.width).clamp(0.0, 1.0);
    final normY = (localOffset.dy / size.height).clamp(0.0, 1.0);

    // 1. Verificar si tocó cerca de un hub regional específico (radio 0.09)
    for (final hub in kRegionalHubs) {
      final dx = normX - hub.relX;
      final dy = normY - hub.relY;
      final distSquared = (dx * dx) + (dy * dy);
      if (distSquared < 0.007) { // ~0.083 distancia euclídea
        onRegionSelected?.call(hub.postcode, hub.state);
        onStateTap?.call(hub.state);
        return;
      }
    }

    // 2. Si no tocó un hub exacto, resolver la región/estado geográfica
    String state;
    String samplePostcode;

    if (normX <= 0.38) {
      state = 'WA';
      samplePostcode = normY < 0.40 ? '6725' : '6280'; // Broome o Margaret River
    } else if (normX > 0.38 && normX <= 0.58 && normY <= 0.52) {
      state = 'NT';
      samplePostcode = normY < 0.35 ? '0800' : '0870'; // Darwin o Alice Springs
    } else if (normX > 0.38 && normX <= 0.64 && normY > 0.52 && normY <= 0.85) {
      state = 'SA';
      samplePostcode = '5251'; // Adelaide Hills / Mount Barker
    } else if (normX > 0.58 && normY <= 0.52) {
      state = 'QLD';
      samplePostcode = normY < 0.30 ? '4870' : '4670'; // Cairns o Bundaberg
    } else if (normX > 0.64 && normY > 0.52 && normY <= 0.72) {
      state = 'NSW';
      samplePostcode = '2481'; // Byron Bay
    } else if (normX > 0.62 && normY > 0.72 && normY <= 0.88) {
      state = 'VIC';
      samplePostcode = '3550'; // Bendigo
    } else if (normX >= 0.68 && normY > 0.88) {
      state = 'TAS';
      samplePostcode = '7250'; // Launceston
    } else {
      state = 'QLD';
      samplePostcode = '4870';
    }

    onRegionSelected?.call(samplePostcode, state);
    onStateTap?.call(state);
  }

  @override
  Widget build(BuildContext context) {
    final stateTitle = _getStateFullName(activeState);
    final zoneDescription = _getZoneDescription(activeState, activeZone);
    final currentPostcode = activePostcode ?? '4870';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del Mapa
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.map_pin_ellipse, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Interactive Regional Map' : 'Mapa Regional Interactivo',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    Text(
                      isEn ? 'Tap any zone to view postcode & eligibility' : 'Toca el mapa para ver el código y normativa',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.location_solid, size: 12, color: AppColors.secondary),
                    const SizedBox(width: 3),
                    Text(
                      '$activeState • $currentPostcode',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Renderizado del Mapa Vectorial Geográfico Realista & Táctil
          LayoutBuilder(
            builder: (context, constraints) {
              const mapHeight = 220.0;
              final mapSize = Size(constraints.maxWidth, mapHeight);

              return GestureDetector(
                onTapUp: (details) => _handleMapTap(details.localPosition, mapSize),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: mapHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: mapSize,
                        painter: _RealisticAustraliaMapPainter(
                          activeState: activeState.toUpperCase(),
                          activePostcode: currentPostcode,
                          primaryColor: AppColors.primary,
                          secondaryColor: AppColors.secondary,
                          neutralColor: const Color(0xFFE5DFD7),
                          borderColor: Colors.white,
                          isEn: isEn,
                        ),
                      ),
                      // Indicador flotante sutil en esquina
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isEn ? '👆 Tap to inspect' : '👆 Toca para explorar',
                            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Selector de Hitos Regionales Oficiales Más Frecuentes
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kRegionalHubs.map((hub) {
                final isSelected = activeState.toUpperCase() == hub.state &&
                    (activePostcode == hub.postcode || (activePostcode == null && activeState == hub.state));

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      onRegionSelected?.call(hub.postcode, hub.state);
                      onStateTap?.call(hub.state);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hub.icon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '${hub.name} (${hub.postcode})',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activeLocation != null
                                  ? '$activeLocation (CP: $currentPostcode)'
                                  : '$stateTitle (CP: $currentPostcode)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.textPrimary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: _isZoneEligible(activeZone)
                                  ? AppColors.secondary.withValues(alpha: 0.12)
                                  : AppColors.statusClosed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _isZoneEligible(activeZone) ? (isEn ? 'ELIGIBLE' : 'ELEGIBLE') : (isEn ? 'METRO' : 'NO VÁLIDO'),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: _isZoneEligible(activeZone) ? AppColors.secondary : AppColors.statusClosed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
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
        return isEn ? 'Queensland (QLD)' : 'Queensland (QLD)';
    }
  }

  String _getZoneDescription(String state, String zone) {
    final st = state.toUpperCase();
    if (zone == 'northern' || st == 'NT' || (st == 'QLD' && (zone.contains('north') || activePostcode?.startsWith('48') == true))) {
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
          : 'Área Metropolitana: No válida para renovar visado de los 88 días bajo LIN 22/050.';
    }
    return isEn
        ? 'Regional Postcode Zone (LIN 22/050): Plant & animal cultivation and construction approved.'
        : 'Zona Regional Aprobada (LIN 22/050): Agricultura, ganadería y construcción válidas.';
  }
}

class _RealisticAustraliaMapPainter extends CustomPainter {
  final String activeState;
  final String activePostcode;
  final Color primaryColor;
  final Color secondaryColor;
  final Color neutralColor;
  final Color borderColor;
  final bool isEn;

  _RealisticAustraliaMapPainter({
    required this.activeState,
    required this.activePostcode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.neutralColor,
    required this.borderColor,
    required this.isEn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 0. Halo oceánico de la costa de Australia (Great Barrier Reef & Ocean)
    final oceanHaloPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;

    // 1. Western Australia (WA) - Contorno curvo y auténtico
    final waPath = Path()
      ..moveTo(w * 0.38, h * 0.20)
      ..quadraticBezierTo(w * 0.29, h * 0.16, w * 0.23, h * 0.20) // Kimberley
      ..quadraticBezierTo(w * 0.18, h * 0.23, w * 0.14, h * 0.29) // Dampier / Pilbara
      ..quadraticBezierTo(w * 0.06, h * 0.33, w * 0.05, h * 0.42) // Exmouth & Ningaloo
      ..quadraticBezierTo(w * 0.07, h * 0.50, w * 0.09, h * 0.60) // Shark Bay & Geraldton
      ..quadraticBezierTo(w * 0.11, h * 0.70, w * 0.13, h * 0.78) // Perth & Cape Leeuwin
      ..quadraticBezierTo(w * 0.22, h * 0.81, w * 0.30, h * 0.82) // Costa sur (Albany/Esperance)
      ..lineTo(w * 0.38, h * 0.82)
      ..lineTo(w * 0.38, h * 0.20)
      ..close();

    // 2. Northern Territory (NT) - Arnhem Land y Top End
    final ntPath = Path()
      ..moveTo(w * 0.38, h * 0.20)
      ..quadraticBezierTo(w * 0.40, h * 0.17, w * 0.44, h * 0.16) // Darwin & Van Diemen
      ..quadraticBezierTo(w * 0.50, h * 0.15, w * 0.53, h * 0.19) // Arnhem Land
      ..quadraticBezierTo(w * 0.56, h * 0.24, w * 0.58, h * 0.30) // Golfo de Carpentaria
      ..lineTo(w * 0.58, h * 0.52)
      ..lineTo(w * 0.38, h * 0.52)
      ..close();

    // 3. South Australia (SA) - Spencer Gulf y Yorke Peninsula
    final saPath = Path()
      ..moveTo(w * 0.38, h * 0.52)
      ..lineTo(w * 0.64, h * 0.52)
      ..lineTo(w * 0.64, h * 0.82)
      ..quadraticBezierTo(w * 0.58, h * 0.80, w * 0.56, h * 0.84) // Golfo San Vicente / Adelaide
      ..quadraticBezierTo(w * 0.54, h * 0.78, w * 0.51, h * 0.85) // Golfo de Spencer & Península Eyre
      ..quadraticBezierTo(w * 0.45, h * 0.83, w * 0.38, h * 0.82) // Gran Bahía Australiana
      ..close();

    // 4. Queensland (QLD) - Península Cape York y costa Gran Barrera
    final qldPath = Path()
      ..moveTo(w * 0.58, h * 0.30)
      ..quadraticBezierTo(w * 0.61, h * 0.22, w * 0.66, h * 0.07) // Península de Cape York
      ..quadraticBezierTo(w * 0.70, h * 0.15, w * 0.74, h * 0.24) // Cooktown & Cairns
      ..quadraticBezierTo(w * 0.80, h * 0.34, w * 0.85, h * 0.43) // Townsville, Mackay & Bundaberg
      ..quadraticBezierTo(w * 0.88, h * 0.50, w * 0.85, h * 0.57) // Brisbane & Gold Coast
      ..lineTo(w * 0.64, h * 0.52)
      ..lineTo(w * 0.58, h * 0.52)
      ..lineTo(w * 0.58, h * 0.30)
      ..close();

    // 5. New South Wales (NSW) - Byron Bay y costa este
    final nswPath = Path()
      ..moveTo(w * 0.64, h * 0.52)
      ..lineTo(w * 0.85, h * 0.57) // Tweed Heads / Byron Bay
      ..quadraticBezierTo(w * 0.84, h * 0.64, w * 0.83, h * 0.70) // Newcastle & Sydney
      ..quadraticBezierTo(w * 0.81, h * 0.74, w * 0.80, h * 0.77) // Wollongong & Cape Howe
      ..lineTo(w * 0.64, h * 0.72) // Río Murray
      ..lineTo(w * 0.64, h * 0.52)
      ..close();

    // 6. Victoria (VIC) - Wilsons Promontory y Port Phillip
    final vicPath = Path()
      ..moveTo(w * 0.64, h * 0.72)
      ..lineTo(w * 0.80, h * 0.77)
      ..quadraticBezierTo(w * 0.77, h * 0.82, w * 0.74, h * 0.86) // Wilsons Promontory (punto más al sur)
      ..quadraticBezierTo(w * 0.71, h * 0.82, w * 0.68, h * 0.85) // Port Phillip & Melbourne
      ..lineTo(w * 0.64, h * 0.82)
      ..close();

    // 7. Tasmania (TAS) - Isla de Tasmania realista
    final tasPath = Path()
      ..moveTo(w * 0.71, h * 0.90)
      ..quadraticBezierTo(w * 0.74, h * 0.89, w * 0.77, h * 0.90) // Costa norte
      ..quadraticBezierTo(w * 0.78, h * 0.94, w * 0.75, h * 0.98) // Costa este & Hobart
      ..quadraticBezierTo(w * 0.70, h * 0.96, w * 0.71, h * 0.90) // Costa oeste
      ..close();

    // Dibujar halos oceánicos
    canvas.drawPath(waPath, oceanHaloPaint);
    canvas.drawPath(ntPath, oceanHaloPaint);
    canvas.drawPath(saPath, oceanHaloPaint);
    canvas.drawPath(qldPath, oceanHaloPaint);
    canvas.drawPath(nswPath, oceanHaloPaint);
    canvas.drawPath(vicPath, oceanHaloPaint);
    canvas.drawPath(tasPath, oceanHaloPaint);

    // Dibujar cada estado con relleno y frontera
    _drawState(canvas, name: 'WA', path: waPath, labelPoint: Offset(w * 0.20, h * 0.50));
    _drawState(canvas, name: 'NT', path: ntPath, labelPoint: Offset(w * 0.48, h * 0.34));
    _drawState(canvas, name: 'SA', path: saPath, labelPoint: Offset(w * 0.50, h * 0.66));
    _drawState(canvas, name: 'QLD', path: qldPath, labelPoint: Offset(w * 0.72, h * 0.36));
    _drawState(canvas, name: 'NSW', path: nswPath, labelPoint: Offset(w * 0.74, h * 0.63));
    _drawState(canvas, name: 'VIC', path: vicPath, labelPoint: Offset(w * 0.72, h * 0.80));
    _drawState(canvas, name: 'TAS', path: tasPath, labelPoint: Offset(w * 0.74, h * 0.94));

    // Dibujar Pines de Hitos Regionales Oficiales en el Mapa
    for (final hub in kRegionalHubs) {
      final pinX = hub.relX * w;
      final pinY = hub.relY * h;
      final isHubActive = activeState == hub.state &&
          (activePostcode == hub.postcode || (activePostcode.isEmpty && activeState == hub.state));

      // Círculo exterior brillante si está activo
      if (isHubActive) {
        final glowPaint = Paint()
          ..color = secondaryColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(pinX, pinY), 8.0, glowPaint);
      }

      // Pin central
      final pinPaint = Paint()
        ..color = isHubActive ? secondaryColor : const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pinX, pinY), isHubActive ? 4.5 : 2.5, pinPaint);

      final pinBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(Offset(pinX, pinY), isHubActive ? 4.5 : 2.5, pinBorderPaint);

      // Etiqueta del hito si está activo o en hubs clave
      if (isHubActive || hub.name == 'Cairns' || hub.name == 'Darwin' || hub.name == 'Byron Bay') {
        final textSpan = TextSpan(
          text: '${hub.name} (${hub.postcode})',
          style: TextStyle(
            color: isHubActive ? Colors.white : const Color(0xFF1E293B),
            fontSize: isHubActive ? 9.5 : 8.0,
            fontWeight: isHubActive ? FontWeight.w900 : FontWeight.bold,
            backgroundColor: isHubActive ? const Color(0xCC00A896) : const Color(0xAAFFFFFF),
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(pinX + 5, pinY - tp.height / 2));
      }
    }
  }

  void _drawState(Canvas canvas, {required String name, required Path path, required Offset labelPoint}) {
    final isSelected = activeState == name;
    final fillPaint = Paint()
      ..color = isSelected ? primaryColor : neutralColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isSelected ? Colors.white : const Color(0xFFC7BEB3)
      ..strokeWidth = isSelected ? 2.2 : 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    // Texto de la abreviatura del estado
    final textSpan = TextSpan(
      text: name,
      style: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontSize: isSelected ? 12.5 : 10.5,
        fontWeight: FontWeight.w900,
        shadows: isSelected
            ? const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))]
            : null,
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
  bool shouldRepaint(covariant _RealisticAustraliaMapPainter oldDelegate) {
    return oldDelegate.activeState != activeState || oldDelegate.activePostcode != activePostcode;
  }
}
