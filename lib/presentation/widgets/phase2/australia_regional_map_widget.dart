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
    const mapAspect = 1022.0 / 788.0;
    double drawW = size.width;
    double drawH = size.width / mapAspect;
    if (drawH > size.height) {
      drawH = size.height;
      drawW = size.height * mapAspect;
    }
    final offX = (size.width - drawW) / 2.0;
    final offY = (size.height - drawH) / 2.0;

    final normX = ((localOffset.dx - offX) / drawW).clamp(0.0, 1.0);
    final normY = ((localOffset.dy - offY) / drawH).clamp(0.0, 1.0);

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

    if (normX <= 0.385) {
      state = 'WA';
      samplePostcode = normY < 0.40 ? '6725' : '6280'; // Broome o Margaret River
    } else if (normX > 0.385 && normX <= 0.582 && normY <= 0.525) {
      state = 'NT';
      samplePostcode = normY < 0.35 ? '0800' : '0870'; // Darwin o Alice Springs
    } else if (normX > 0.385 && normX <= 0.640 && normY > 0.525 && normY <= 0.85) {
      state = 'SA';
      samplePostcode = '5251'; // Adelaide Hills / Mount Barker
    } else if (normX > 0.582 && normY <= 0.525) {
      state = 'QLD';
      samplePostcode = normY < 0.30 ? '4870' : '4670'; // Cairns o Bundaberg
    } else if (normX > 0.640 && normY > 0.525 && normY <= 0.725) {
      state = 'NSW';
      samplePostcode = '2481'; // Byron Bay
    } else if (normX > 0.640 && normY > 0.725 && normY <= 0.88) {
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

  static const List<Offset> _mainlandPts = [
    Offset(0.7456, 0.8217),
    Offset(0.7299, 0.8077),
    Offset(0.7158, 0.8008),
    Offset(0.7172, 0.7849),
    Offset(0.7104, 0.7887),
    Offset(0.6918, 0.8141),
    Offset(0.6321, 0.7887),
    Offset(0.6179, 0.7665),
    Offset(0.6101, 0.7272),
    Offset(0.5998, 0.7138),
    Offset(0.5807, 0.7094),
    Offset(0.5866, 0.6954),
    Offset(0.5832, 0.6758),
    Offset(0.5744, 0.6935),
    Offset(0.5553, 0.6992),
    Offset(0.5651, 0.6815),
    Offset(0.568, 0.6624),
    Offset(0.5758, 0.6485),
    Offset(0.5744, 0.6288),
    Offset(0.5621, 0.6497),
    Offset(0.5475, 0.6637),
    Offset(0.5406, 0.6865),
    Offset(0.5382, 0.6872),
    Offset(0.523, 0.6739),
    Offset(0.523, 0.6574),
    Offset(0.5122, 0.6371),
    Offset(0.5005, 0.6244),
    Offset(0.5029, 0.6161),
    Offset(0.4804, 0.5996),
    Offset(0.4648, 0.5984),
    Offset(0.4472, 0.5844),
    Offset(0.4129, 0.5857),
    Offset(0.364, 0.6072),
    Offset(0.3425, 0.606),
    Offset(0.3229, 0.6212),
    Offset(0.3063, 0.6275),
    Offset(0.3028, 0.6421),
    Offset(0.2945, 0.6567),
    Offset(0.2632, 0.6605),
    Offset(0.2456, 0.6542),
    Offset(0.2192, 0.6593),
    Offset(0.2074, 0.6758),
    Offset(0.1996, 0.6758),
    Offset(0.182, 0.6935),
    Offset(0.1526, 0.6923),
    Offset(0.1208, 0.665),
    Offset(0.1208, 0.6472),
    Offset(0.1336, 0.6371),
    Offset(0.1345, 0.5901),
    Offset(0.1228, 0.5558),
    Offset(0.1199, 0.5406),
    Offset(0.1208, 0.5216),
    Offset(0.113, 0.5038),
    Offset(0.112, 0.4937),
    Offset(0.1032, 0.4822),
    Offset(0.1013, 0.4607),
    Offset(0.0866, 0.4251),
    Offset(0.089, 0.4232),
    Offset(0.0934, 0.4289),
    Offset(0.09, 0.4093),
    Offset(0.1042, 0.4226),
    Offset(0.1042, 0.415),
    Offset(0.0876, 0.3744),
    Offset(0.0895, 0.3604),
    Offset(0.0964, 0.3426),
    Offset(0.0944, 0.3223),
    Offset(0.1023, 0.302),
    Offset(0.1052, 0.3008),
    Offset(0.1067, 0.3166),
    Offset(0.1145, 0.3014),
    Offset(0.1292, 0.2938),
    Offset(0.137, 0.2836),
    Offset(0.1546, 0.2709),
    Offset(0.1703, 0.2722),
    Offset(0.1849, 0.2621),
    Offset(0.1967, 0.2595),
    Offset(0.2045, 0.2506),
    Offset(0.2202, 0.2506),
    Offset(0.2378, 0.243),
    Offset(0.248, 0.231),
    Offset(0.2529, 0.217),
    Offset(0.2647, 0.203),
    Offset(0.2657, 0.1789),
    Offset(0.2784, 0.1574),
    Offset(0.2823, 0.1561),
    Offset(0.2896, 0.177),
    Offset(0.2945, 0.1745),
    Offset(0.2891, 0.1612),
    Offset(0.295, 0.1485),
    Offset(0.3048, 0.151),
    Offset(0.3068, 0.1332),
    Offset(0.3239, 0.1085),
    Offset(0.3322, 0.1041),
    Offset(0.3337, 0.0971),
    Offset(0.3415, 0.0996),
    Offset(0.3425, 0.0933),
    Offset(0.362, 0.0857),
    Offset(0.3757, 0.0971),
    Offset(0.3875, 0.1136),
    Offset(0.41, 0.1161),
    Offset(0.4075, 0.1015),
    Offset(0.4154, 0.0838),
    Offset(0.4251, 0.0749),
    Offset(0.4222, 0.0685),
    Offset(0.4325, 0.0514),
    Offset(0.4423, 0.0438),
    Offset(0.456, 0.0463),
    Offset(0.4702, 0.0406),
    Offset(0.4702, 0.0305),
    Offset(0.4555, 0.0216),
    Offset(0.4638, 0.0159),
    Offset(0.4795, 0.0209),
    Offset(0.4922, 0.0336),
    Offset(0.5049, 0.0387),
    Offset(0.5127, 0.0362),
    Offset(0.5254, 0.0451),
    Offset(0.5362, 0.0374),
    Offset(0.545, 0.0387),
    Offset(0.5499, 0.0349),
    Offset(0.5592, 0.0508),
    Offset(0.5514, 0.0685),
    Offset(0.546, 0.0755),
    Offset(0.5406, 0.0761),
    Offset(0.5426, 0.085),
    Offset(0.5298, 0.1104),
    Offset(0.5308, 0.118),
    Offset(0.546, 0.1326),
    Offset(0.5685, 0.1466),
    Offset(0.5841, 0.1643),
    Offset(0.6018, 0.172),
    Offset(0.6067, 0.1821),
    Offset(0.6243, 0.1897),
    Offset(0.6365, 0.1802),
    Offset(0.6443, 0.1536),
    Offset(0.6522, 0.1206),
    Offset(0.6482, 0.0863),
    Offset(0.6502, 0.0673),
    Offset(0.6541, 0.0596),
    Offset(0.6522, 0.0482),
    Offset(0.661, 0.014),
    Offset(0.6693, 0.0032),
    Offset(0.6766, 0.0178),
    Offset(0.6776, 0.033),
    Offset(0.6825, 0.0368),
    Offset(0.6835, 0.0482),
    Offset(0.6903, 0.0609),
    Offset(0.6913, 0.0863),
    Offset(0.6972, 0.1028),
    Offset(0.6986, 0.1047),
    Offset(0.7114, 0.0958),
    Offset(0.7275, 0.118),
    Offset(0.7255, 0.132),
    Offset(0.7285, 0.1485),
    Offset(0.7324, 0.165),
    Offset(0.7392, 0.1739),
    Offset(0.7432, 0.1916),
    Offset(0.7412, 0.2069),
    Offset(0.7471, 0.2234),
    Offset(0.7691, 0.2379),
    Offset(0.797, 0.264),
    Offset(0.795, 0.2716),
    Offset(0.8048, 0.2855),
    Offset(0.8131, 0.3154),
    Offset(0.82, 0.3103),
    Offset(0.8278, 0.3217),
    Offset(0.8341, 0.3185),
    Offset(0.8371, 0.3477),
    Offset(0.8625, 0.3782),
    Offset(0.8772, 0.401),
    Offset(0.8821, 0.4213),
    Offset(0.8811, 0.4569),
    Offset(0.8909, 0.481),
    Offset(0.8899, 0.5076),
    Offset(0.8811, 0.5444),
    Offset(0.8782, 0.5838),
    Offset(0.8694, 0.6129),
    Offset(0.8537, 0.6294),
    Offset(0.84, 0.6675),
    Offset(0.8341, 0.6954),
    Offset(0.8253, 0.7132),
    Offset(0.8195, 0.7449),
    Offset(0.8195, 0.7678),
    Offset(0.8072, 0.7798),
    Offset(0.7808, 0.7836),
    Offset(0.7671, 0.7938),
  ];

  static const List<Offset> _tasmaniaPts = [
    Offset(0.7564, 0.9791),
    Offset(0.7397, 0.9765),
    Offset(0.7334, 0.9632),
    Offset(0.7255, 0.9416),
    Offset(0.7236, 0.9213),
    Offset(0.7118, 0.8909),
    Offset(0.7143, 0.8737),
    Offset(0.728, 0.8775),
    Offset(0.7456, 0.889),
    Offset(0.772, 0.8775),
    Offset(0.7852, 0.8807),
    Offset(0.7872, 0.9226),
    Offset(0.7803, 0.934),
    Offset(0.7784, 0.9632),
    Offset(0.7701, 0.9562),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Preservar relación de aspecto exacta de la imagen vectorial (1022 x 788)
    const mapAspect = 1022.0 / 788.0;
    double drawW = w;
    double drawH = w / mapAspect;
    if (drawH > h) {
      drawH = h;
      drawW = h * mapAspect;
    }
    final offX = (w - drawW) / 2.0;
    final offY = (h - drawH) / 2.0;

    // 0. Construir el contorno exacto continental de Australia
    final mainlandPath = Path();
    mainlandPath.moveTo(offX + drawW * _mainlandPts[0].dx, offY + drawH * _mainlandPts[0].dy);
    for (int i = 1; i < _mainlandPts.length; i++) {
      mainlandPath.lineTo(offX + drawW * _mainlandPts[i].dx, offY + drawH * _mainlandPts[i].dy);
    }
    mainlandPath.close();

    // Contorno exacto de Tasmania
    final tasmaniaPath = Path();
    tasmaniaPath.moveTo(offX + drawW * _tasmaniaPts[0].dx, offY + drawH * _tasmaniaPts[0].dy);
    for (int i = 1; i < _tasmaniaPts.length; i++) {
      tasmaniaPath.lineTo(offX + drawW * _tasmaniaPts[i].dx, offY + drawH * _tasmaniaPts[i].dy);
    }
    tasmaniaPath.close();

    // 1. Estados federados ajustados a la silueta exacta mediante intersección geométrica
    // WA (Western Australia): Todo el oeste hasta 129°E (x ~ 0.385)
    final waBox = Path()
      ..addRect(Rect.fromLTWH(offX - 10, offY - 10, drawW * 0.385 + 10, drawH + 20));
    final waPath = Path.combine(PathOperation.intersect, mainlandPath, waBox);

    // NT (Northern Territory): Centro-norte (x ~ 0.385 a 0.582, y <= 0.525)
    final ntBox = Path()
      ..addRect(Rect.fromLTWH(offX + drawW * 0.385, offY - 10, drawW * (0.582 - 0.385), drawH * 0.525 + 10));
    final ntPath = Path.combine(PathOperation.intersect, mainlandPath, ntBox);

    // SA (South Australia): Centro-sur (x ~ 0.385 a 0.640, y > 0.525)
    final saBox = Path()
      ..addRect(Rect.fromLTWH(offX + drawW * 0.385, offY + drawH * 0.525, drawW * (0.640 - 0.385), drawH * 0.475 + 10));
    final saPath = Path.combine(PathOperation.intersect, mainlandPath, saBox);

    // QLD (Queensland): Este tropical y noreste
    final qldPoly = Path()
      ..moveTo(offX + drawW * 0.582, offY - 10)
      ..lineTo(offX + drawW + 10, offY - 10)
      ..lineTo(offX + drawW + 10, offY + drawH * 0.525)
      ..lineTo(offX + drawW * 0.640, offY + drawH * 0.525)
      ..lineTo(offX + drawW * 0.640, offY + drawH * 0.525)
      ..lineTo(offX + drawW * 0.582, offY + drawH * 0.525)
      ..close();
    final qldPath = Path.combine(PathOperation.intersect, mainlandPath, qldPoly);

    // NSW (New South Wales): Este centro (y ~ 0.525 a 0.725)
    final nswBox = Path()
      ..addRect(Rect.fromLTWH(offX + drawW * 0.640, offY + drawH * 0.525, drawW * (1.0 - 0.640) + 10, drawH * (0.725 - 0.525)));
    final nswPath = Path.combine(PathOperation.intersect, mainlandPath, nswBox);

    // VIC (Victoria): Sureste continental (y > 0.725)
    final vicBox = Path()
      ..addRect(Rect.fromLTWH(offX + drawW * 0.640, offY + drawH * 0.725, drawW * (1.0 - 0.640) + 10, drawH * 0.275 + 10));
    final vicPath = Path.combine(PathOperation.intersect, mainlandPath, vicBox);

    // 2. Halo oceánico exterior
    final oceanHaloPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawPath(mainlandPath, oceanHaloPaint);
    canvas.drawPath(tasmaniaPath, oceanHaloPaint);

    // 3. Dibujar cada estado con relieve y sombreado corporativo
    _drawState(canvas, name: 'WA', path: waPath, labelPoint: Offset(offX + drawW * 0.20, offY + drawH * 0.50));
    _drawState(canvas, name: 'NT', path: ntPath, labelPoint: Offset(offX + drawW * 0.48, offY + drawH * 0.34));
    _drawState(canvas, name: 'SA', path: saPath, labelPoint: Offset(offX + drawW * 0.50, offY + drawH * 0.66));
    _drawState(canvas, name: 'QLD', path: qldPath, labelPoint: Offset(offX + drawW * 0.72, offY + drawH * 0.36));
    _drawState(canvas, name: 'NSW', path: nswPath, labelPoint: Offset(offX + drawW * 0.74, offY + drawH * 0.63));
    _drawState(canvas, name: 'VIC', path: vicPath, labelPoint: Offset(offX + drawW * 0.72, offY + drawH * 0.79));
    _drawState(canvas, name: 'TAS', path: tasmaniaPath, labelPoint: Offset(offX + drawW * 0.75, offY + drawH * 0.93));

    // 4. Relieve Geográfico Ejecutivo (Great Dividing Range)
    final reliefPaint = Paint()
      ..color = const Color(0x221E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final gdrReliefPath = Path()
      ..moveTo(offX + drawW * 0.67, offY + drawH * 0.09)
      ..quadraticBezierTo(offX + drawW * 0.73, offY + drawH * 0.24, offX + drawW * 0.78, offY + drawH * 0.38)
      ..quadraticBezierTo(offX + drawW * 0.81, offY + drawH * 0.50, offX + drawW * 0.79, offY + drawH * 0.62)
      ..quadraticBezierTo(offX + drawW * 0.76, offY + drawH * 0.73, offX + drawW * 0.72, offY + drawH * 0.81);
    canvas.drawPath(gdrReliefPath, reliefPaint);

    // 5. Dibujar Pines de Hitos Regionales Oficiales en el Mapa
    for (final hub in kRegionalHubs) {
      final pinX = offX + hub.relX * drawW;
      final pinY = offY + hub.relY * drawH;
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
