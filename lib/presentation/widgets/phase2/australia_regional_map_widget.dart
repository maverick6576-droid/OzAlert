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
                      // Indicador flotante sutil en esquina superior derecha (océano libre, nunca tapa Tasmania)
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isEn ? '👆 Tap to explore' : '👆 Toca para explorar',
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
          const SizedBox(height: 10),

          // Etiqueta minimalista: Únicamente la zona seleccionada
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.location_solid, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    stateTitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

    // 0. Halo oceánico y relieve de plataforma continental
    final oceanHaloPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    // 1. Western Australia (WA) - Relieve geográfico hiperrealista
    final waPath = Path()
      ..moveTo(w * 0.38, h * 0.19)
      ..quadraticBezierTo(w * 0.32, h * 0.155, w * 0.27, h * 0.16) // Cambridge Gulf & Joseph Bonaparte
      ..quadraticBezierTo(w * 0.21, h * 0.175, w * 0.17, h * 0.21) // Costa escarpada del Kimberley
      ..quadraticBezierTo(w * 0.135, h * 0.25, w * 0.12, h * 0.29) // Eighty Mile Beach
      ..quadraticBezierTo(w * 0.085, h * 0.305, w * 0.06, h * 0.345) // Dampier & Pilbara
      ..quadraticBezierTo(w * 0.045, h * 0.375, w * 0.05, h * 0.41) // Cabo Noroeste (Exmouth Horn)
      ..quadraticBezierTo(w * 0.07, h * 0.445, w * 0.065, h * 0.49) // Bahía Shark / Isla Dirk Hartog
      ..quadraticBezierTo(w * 0.08, h * 0.55, w * 0.095, h * 0.62) // Geraldton
      ..quadraticBezierTo(w * 0.105, h * 0.69, w * 0.115, h * 0.74) // Costa de Perth & Cabo Naturaliste
      ..quadraticBezierTo(w * 0.125, h * 0.795, w * 0.16, h * 0.815) // Cabo Leeuwin
      ..quadraticBezierTo(w * 0.22, h * 0.825, w * 0.30, h * 0.82) // Costa sur (Albany & Esperance)
      ..lineTo(w * 0.38, h * 0.82)
      ..lineTo(w * 0.38, h * 0.19)
      ..close();

    // 2. Northern Territory (NT) - Arnhem Land y Top End
    final ntPath = Path()
      ..moveTo(w * 0.38, h * 0.19)
      ..quadraticBezierTo(w * 0.40, h * 0.165, w * 0.435, h * 0.15) // Darwin & Beagle Gulf
      ..quadraticBezierTo(w * 0.46, h * 0.13, w * 0.48, h * 0.135) // Península Cobourg
      ..quadraticBezierTo(w * 0.52, h * 0.14, w * 0.545, h * 0.175) // Arnhem Land
      ..quadraticBezierTo(w * 0.565, h * 0.22, w * 0.58, h * 0.305) // Golfo de Carpentaria (costa occidental)
      ..lineTo(w * 0.58, h * 0.52)
      ..lineTo(w * 0.38, h * 0.52)
      ..close();

    // 3. South Australia (SA) - Spencer Gulf y Eyre Peninsula
    final saPath = Path()
      ..moveTo(w * 0.38, h * 0.52)
      ..lineTo(w * 0.64, h * 0.52)
      ..lineTo(w * 0.64, h * 0.82)
      ..quadraticBezierTo(w * 0.59, h * 0.805, w * 0.575, h * 0.845) // Encounter Bay / Adelaida
      ..quadraticBezierTo(w * 0.56, h * 0.795, w * 0.545, h * 0.85) // Península Yorke & Golfo San Vicente
      ..quadraticBezierTo(w * 0.525, h * 0.775, w * 0.495, h * 0.835) // Golfo de Spencer & Península Eyre
      ..quadraticBezierTo(w * 0.44, h * 0.83, w * 0.38, h * 0.82) // Gran Bahía Australiana
      ..close();

    // 4. Queensland (QLD) - Península Cape York y costa Gran Barrera
    final qldPath = Path()
      ..moveTo(w * 0.58, h * 0.305)
      ..quadraticBezierTo(w * 0.605, h * 0.21, w * 0.655, h * 0.055) // Costa oeste Península de Cape York
      ..quadraticBezierTo(w * 0.665, h * 0.052, w * 0.675, h * 0.075) // Punta de Cape York (Estrecho de Torres)
      ..quadraticBezierTo(w * 0.71, h * 0.16, w * 0.75, h * 0.255) // Cooktown, Cairns & Hinchinbrook
      ..quadraticBezierTo(w * 0.79, h * 0.33, w * 0.83, h * 0.41) // Townsville & Whitsundays
      ..quadraticBezierTo(w * 0.865, h * 0.48, w * 0.85, h * 0.555) // Bundaberg, Hervey Bay & Fraser Coast
      ..lineTo(w * 0.64, h * 0.52)
      ..lineTo(w * 0.58, h * 0.52)
      ..lineTo(w * 0.58, h * 0.305)
      ..close();

    // 5. New South Wales (NSW) - Byron Bay y costa este
    final nswPath = Path()
      ..moveTo(w * 0.64, h * 0.52)
      ..lineTo(w * 0.85, h * 0.555) // Byron Bay (punto más oriental)
      ..quadraticBezierTo(w * 0.845, h * 0.615, w * 0.835, h * 0.67) // Coffs Harbour & Port Macquarie
      ..quadraticBezierTo(w * 0.82, h * 0.72, w * 0.805, h * 0.76) // Newcastle, Sídney & Wollongong
      ..lineTo(w * 0.64, h * 0.72) // Río Murray
      ..lineTo(w * 0.64, h * 0.52)
      ..close();

    // 6. Victoria (VIC) - Wilsons Promontory y Port Phillip
    final vicPath = Path()
      ..moveTo(w * 0.64, h * 0.72)
      ..lineTo(w * 0.805, h * 0.76) // Cabo Howe
      ..quadraticBezierTo(w * 0.77, h * 0.81, w * 0.74, h * 0.865) // Wilsons Promontory (extremo sur continental)
      ..quadraticBezierTo(w * 0.715, h * 0.82, w * 0.68, h * 0.855) // Port Phillip & Melbourne
      ..lineTo(w * 0.64, h * 0.82)
      ..close();

    // 7. Tasmania (TAS) - Isla de Tasmania realista
    final tasPath = Path()
      ..moveTo(w * 0.715, h * 0.90)
      ..quadraticBezierTo(w * 0.74, h * 0.89, w * 0.765, h * 0.905) // Costa norte (Estrecho de Bass)
      ..quadraticBezierTo(w * 0.78, h * 0.94, w * 0.76, h * 0.98) // Costa este & Hobart
      ..quadraticBezierTo(w * 0.74, h * 0.985, w * 0.72, h * 0.965) // Costa sur (South East Cape)
      ..quadraticBezierTo(w * 0.705, h * 0.93, w * 0.715, h * 0.90) // Costa salvaje oeste
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
    _drawState(canvas, name: 'VIC', path: vicPath, labelPoint: Offset(w * 0.72, h * 0.79));
    _drawState(canvas, name: 'TAS', path: tasPath, labelPoint: Offset(w * 0.74, h * 0.94));

    // Relieve Geográfico Ejecutivo (Great Dividing Range)
    final reliefPaint = Paint()
      ..color = const Color(0x221E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final gdrReliefPath = Path()
      ..moveTo(w * 0.67, h * 0.09)
      ..quadraticBezierTo(w * 0.73, h * 0.24, w * 0.78, h * 0.38)
      ..quadraticBezierTo(w * 0.81, h * 0.50, w * 0.79, h * 0.62)
      ..quadraticBezierTo(w * 0.76, h * 0.73, w * 0.72, h * 0.81);
    canvas.drawPath(gdrReliefPath, reliefPaint);

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
