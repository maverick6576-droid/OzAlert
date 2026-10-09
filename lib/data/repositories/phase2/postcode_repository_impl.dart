import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../domain/models/phase2/postcode_info.dart';
import '../../../domain/repositories/phase2/postcode_repository.dart';

class PostcodeRepositoryImpl implements PostcodeRepository {
  final Map<String, PostcodeInfo> _cache = {};

  // --- TABLA OFICIAL DE RANGOS LIN 22/050 ---

  // 1. Agricultura y Construcción (Regional Australia)
  static const List<List<int>> _agriConstNSW = [
    [2311, 2312],
    [2328, 2411],
    [2420, 2490],
    [2536, 2551],
    [2575, 2594],
    [2618, 2739],
    [2787, 2898],
  ];

  static const List<List<int>> _agriConstVIC = [
    [3139, 3139],
    [3211, 3334],
    [3340, 3424],
    [3430, 3649],
    [3658, 3749],
    [3753, 3753],
    [3756, 3756],
    [3758, 3758],
    [3762, 3762],
    [3764, 3764],
    [3778, 3781],
    [3783, 3783],
    [3797, 3797],
    [3799, 3799],
    [3810, 3909],
    [3921, 3925],
    [3945, 3974],
    [3979, 3979],
    [3981, 3996],
  ];

  static const List<List<int>> _agriConstQLD = [
    [4124, 4125],
    [4133, 4133],
    [4211, 4211],
    [4270, 4272],
    [4275, 4275],
    [4280, 4280],
    [4285, 4285],
    [4287, 4287],
    [4307, 4499],
    [4510, 4510],
    [4512, 4512],
    [4515, 4519],
    [4522, 4899],
  ];

  static const List<List<int>> _agriConstSA = [
    [5000, 5999], // Todo el estado de Australia Meridional
  ];

  static const List<List<int>> _agriConstWA = [
    [6041, 6044],
    [6055, 6056],
    [6069, 6069],
    [6076, 6076],
    [6083, 6084],
    [6111, 6111],
    [6121, 6126],
    [6200, 6799],
  ];

  static const List<List<int>> _agriConstTAS = [
    [7000, 7999], // Todo el estado de Tasmania
  ];

  static const List<List<int>> _agriConstNT = [
    [800, 999], // Todo el Territorio del Norte (0800 a 0999)
  ];

  static const List<List<int>> _agriConstNorfolk = [
    [2898, 2899], // Isla Norfolk
  ];

  // 2. Pesca, Perlas y Silvicultura (Northern Australia - Subclase 462)
  static const List<List<int>> _fishingForestryQLD = [
    [4472, 4472],
    [4478, 4478],
    [4481, 4482],
    [4680, 4680],
    [4694, 4695],
    [4697, 4697],
    [4699, 4707],
    [4709, 4714],
    [4717, 4717],
    [4720, 4728],
    [4730, 4733],
    [4735, 4746],
    [4750, 4751],
    [4753, 4754],
    [4756, 4757],
    [4798, 4812],
    [4814, 4825],
    [4828, 4830],
    [4849, 4850],
    [4852, 4852],
    [4854, 4856],
    [4858, 4861],
    [4865, 4865],
    [4868, 4888],
    [4890, 4892],
    [4895, 4895],
  ];

  static const List<List<int>> _fishingForestryWA = [
    [872, 872],
    [6537, 6537],
    [6642, 6642],
    [6646, 6646],
    [6701, 6701],
    [6705, 6705],
    [6707, 6707],
    [6710, 6714],
    [6716, 6716],
    [6718, 6718],
    [6720, 6722],
    [6725, 6726],
    [6728, 6728],
    [6740, 6740],
    [6743, 6743],
    [6751, 6751],
    [6753, 6754],
    [6758, 6758],
    [6760, 6760],
    [6762, 6762],
    [6765, 6765],
    [6770, 6770],
  ];

  // 3. Turismo y Hostelería (Northern + Remote & Very Remote Australia - Subclase 462)
  static const List<List<int>> _tourismRemoteQLD = [
    [4406, 4406],
    [4416, 4416],
    [4498, 4498],
  ];

  static const List<List<int>> _tourismRemoteWA = [
    [6426, 6427],
    [6434, 6434],
    [6436, 6438],
    [6440, 6440],
    [6442, 6442],
    [6450, 6450],
    [6452, 6452],
    [6507, 6507],
    [6509, 6509],
    [6511, 6511],
    [6517, 6517],
    [6521, 6521],
    [6532, 6532],
    [6535, 6535],
    [6556, 6556],
    [6558, 6558],
    [6560, 6560],
    [6563, 6563],
    [6568, 6571],
    [6574, 6575],
  ];

  static const List<List<int>> _tourismRemoteNSW = [
    [2356, 2356],
    [2386, 2387],
    [2396, 2396],
    [2405, 2406],
    [2672, 2672],
    [2675, 2675],
    [2825, 2826],
    [2829, 2829],
    [2832, 2836],
    [2838, 2840],
    [2873, 2873],
    [2878, 2879],
    [2898, 2899],
  ];

  static const List<List<int>> _tourismRemoteVIC = [
    [3424, 3424],
    [3506, 3506],
    [3509, 3509],
    [3512, 3512],
    [3889, 3892],
  ];

  static const List<List<int>> _tourismRemoteSA = [
    [5220, 5223],
    [5302, 5304],
    [5440, 5440],
    [5576, 5576],
    [5577, 5577],
    [5582, 5582],
    [5583, 5583],
    [5602, 5607],
    [5611, 5611],
    [5630, 5633],
    [5640, 5642],
    [5650, 5655],
    [5660, 5660],
    [5661, 5661],
    [5670, 5670],
    [5671, 5671],
    [5680, 5680],
    [5690, 5690],
    [5713, 5713],
    [5715, 5715],
    [5717, 5717],
    [5719, 5719],
    [5720, 5720],
    [5722, 5725],
    [5730, 5734],
  ];

  static const List<List<int>> _tourismRemoteTAS = [
    [7139, 7139],
    [7215, 7215],
    [7255, 7257],
    [7466, 7470],
  ];

  // Diccionario de ciudades clave y zonas para resolver nombres instantáneos
  static const Map<String, String> _knownLocations = {
    '4870': 'Cairns / Northern Beaches, QLD',
    '4877': 'Port Douglas, QLD',
    '4810': 'Townsville, QLD',
    '4802': 'Airlie Beach / Whitsundays, QLD',
    '4740': 'Mackay, QLD',
    '4670': 'Bundaberg, QLD',
    '4700': 'Rockhampton, QLD',
    '4350': 'Toowoomba, QLD',
    '4406': 'Tara / Western Downs, QLD',
    '4416': 'Wandoan, QLD',
    '4498': 'Kioma / Goondiwindi, QLD',
    '4000': 'Brisbane CBD (Metropolitan), QLD',
    '4217': 'Surfers Paradise (Metropolitan), QLD',
    '2481': 'Byron Bay, NSW',
    '2450': 'Coffs Harbour, NSW',
    '2340': 'Tamworth, NSW',
    '2800': 'Orange, NSW',
    '2830': 'Dubbo, NSW',
    '2825': 'Cobar (Remote Outpost), NSW',
    '2899': 'Norfolk Island (External Territory)',
    '2000': 'Sydney CBD (Metropolitan), NSW',
    '2600': 'Canberra (Metropolitan), ACT',
    '3220': 'Geelong, VIC',
    '3350': 'Ballarat, VIC',
    '3550': 'Bendigo, VIC',
    '3630': 'Shepparton, VIC',
    '3500': 'Mildura, VIC',
    '3889': 'Bemm River / East Gippsland, VIC',
    '3000': 'Melbourne CBD (Metropolitan), VIC',
    '5000': 'Adelaide CBD, SA',
    '5251': 'Mount Barker / Adelaide Hills, SA',
    '5280': 'Millicent / Limestone Coast, SA',
    '5353': 'Angaston / Barossa Valley, SA',
    '5290': 'Mount Gambier, SA',
    '5606': 'Port Lincoln / Eyre Peninsula, SA',
    '5720': 'Coober Pedy (Opal Capital), SA',
    '6000': 'Perth CBD (Metropolitan), WA',
    '6280': 'Busselton / Margaret River, WA',
    '6230': 'Bunbury, WA',
    '6330': 'Albany, WA',
    '6530': 'Geraldton, WA',
    '6725': 'Broome (Kimberley), WA',
    '6743': 'Kununurra (East Kimberley), WA',
    '6714': 'Karratha (Pilbara), WA',
    '6707': 'Exmouth (Ningaloo Reef), WA',
    '6430': 'Kalgoorlie (Goldfields), WA',
    '7000': 'Hobart CBD, TAS',
    '7250': 'Launceston, TAS',
    '7310': 'Devonport, TAS',
    '7467': 'Queenstown (West Coast), TAS',
    '7255': 'Flinders Island (Bass Strait), TAS',
    '0800': 'Darwin City, NT',
    '0870': 'Alice Springs (Red Centre), NT',
    '0850': 'Katherine, NT',
    '0880': 'Nhulunbuy / Arnhem Land, NT',
  };

  static bool _isInRange(int pCode, List<List<int>> ranges) {
    for (final r in ranges) {
      if (pCode >= r[0] && pCode <= r[1]) return true;
    }
    return false;
  }

  final Map<String, String> _jsonLocations = {};

  @override
  Future<void> init() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/regional_postcodes.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> list = data['postcodes'] ?? [];

      for (final item in list) {
        if (item is Map) {
          final code = item['code']?.toString();
          final loc = item['location']?.toString();
          if (code != null && loc != null) {
            _jsonLocations[code] = loc;
          }
        }
      }
    } catch (_) {}
  }

  @override
  PostcodeInfo? findPostcode(String code) {
    final clean = code.trim().replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 4) return null;
    final int? pCode = int.tryParse(clean);
    if (pCode == null) return null;

    // Si ya está cacheado, retornarlo de inmediato
    if (_cache.containsKey(clean)) {
      return _cache[clean];
    }

    // Evaluación dinámica y estricta según LIN 22/050
    final info = _evaluatePostcode(clean, pCode);
    _cache[clean] = info;
    return info;
  }

  @override
  List<PostcodeInfo> getAllPostcodes() {
    final allKeys = {..._knownLocations.keys, ..._jsonLocations.keys};
    for (final code in allKeys) {
      if (!_cache.containsKey(code)) {
        final pCode = int.tryParse(code);
        if (pCode != null) {
          _cache[code] = _evaluatePostcode(code, pCode);
        }
      }
    }
    return _cache.values.toList();
  }

  PostcodeInfo _evaluatePostcode(String codeStr, int pCode) {
    // 1. Deducir Estado y Territorio
    String state = 'NSW';
    if (codeStr.startsWith('0')) {
      state = 'NT';
    } else if (codeStr.startsWith('2')) {
      if (pCode == 2899) {
        state = 'Norfolk Island';
      } else if ((pCode >= 2600 && pCode <= 2612) || (pCode >= 2900 && pCode <= 2920)) {
        state = 'ACT';
      } else {
        state = 'NSW';
      }
    } else if (codeStr.startsWith('3')) {
      state = 'VIC';
    } else if (codeStr.startsWith('4')) {
      state = 'QLD';
    } else if (codeStr.startsWith('5')) {
      state = 'SA';
    } else if (codeStr.startsWith('6')) {
      state = 'WA';
    } else if (codeStr.startsWith('7')) {
      state = 'TAS';
    }

    // 2. Verificar Agricultura y Construcción (Regional Australia)
    bool isAgriConstEligible = false;
    switch (state) {
      case 'NSW':
        isAgriConstEligible = _isInRange(pCode, _agriConstNSW);
        break;
      case 'VIC':
        isAgriConstEligible = _isInRange(pCode, _agriConstVIC);
        break;
      case 'QLD':
        isAgriConstEligible = _isInRange(pCode, _agriConstQLD);
        break;
      case 'SA':
        isAgriConstEligible = _isInRange(pCode, _agriConstSA);
        break;
      case 'WA':
        isAgriConstEligible = _isInRange(pCode, _agriConstWA);
        break;
      case 'TAS':
        isAgriConstEligible = _isInRange(pCode, _agriConstTAS);
        break;
      case 'NT':
        isAgriConstEligible = _isInRange(pCode, _agriConstNT);
        break;
      case 'Norfolk Island':
        isAgriConstEligible = _isInRange(pCode, _agriConstNorfolk);
        break;
      default:
        isAgriConstEligible = false;
    }

    // 3. Verificar Northern Australia (Pesca, Perlas, Silvicultura y Minería 462)
    bool isNorthernAustralia = false;
    if (state == 'NT') {
      isNorthernAustralia = true;
    } else if (state == 'QLD') {
      isNorthernAustralia = _isInRange(pCode, _fishingForestryQLD);
    } else if (state == 'WA') {
      isNorthernAustralia = _isInRange(pCode, _fishingForestryWA);
    }

    // 4. Verificar Turismo y Hostelería (Northern + Remote & Very Remote - 462)
    bool isTourism462Eligible = false;
    bool isRemoteAustralia = false;

    if (isNorthernAustralia) {
      isTourism462Eligible = true;
    } else {
      switch (state) {
        case 'QLD':
          isRemoteAustralia = _isInRange(pCode, _tourismRemoteQLD);
          break;
        case 'WA':
          isRemoteAustralia = _isInRange(pCode, _tourismRemoteWA);
          break;
        case 'NSW':
          isRemoteAustralia = _isInRange(pCode, _tourismRemoteNSW);
          break;
        case 'VIC':
          isRemoteAustralia = _isInRange(pCode, _tourismRemoteVIC);
          break;
        case 'SA':
          isRemoteAustralia = _isInRange(pCode, _tourismRemoteSA);
          break;
        case 'TAS':
          isRemoteAustralia = _isInRange(pCode, _tourismRemoteTAS);
          break;
      }
      isTourism462Eligible = isRemoteAustralia;
    }

    // 5. Determinar Zona Geográfica Oficial
    String zone = 'metro';
    if (isNorthernAustralia) {
      zone = 'northern';
    } else if (isRemoteAustralia) {
      zone = 'remote';
    } else if (isAgriConstEligible) {
      zone = 'regional_${state.toLowerCase()}';
    } else {
      zone = 'metro';
    }

    // 6. Asignar Nombre de Ubicación
    String location = _knownLocations[codeStr] ??
        _jsonLocations[codeStr] ??
        (isAgriConstEligible
            ? (isNorthernAustralia
                ? '$state Northern Regional Area'
                : (isRemoteAustralia ? '$state Remote Area' : '$state Regional Area'))
            : '$state Metropolitan / Ineligible Area');

    // 7. Mapear Subclases 462 y 417
    final Map<String, bool> subclass462 = {
      'agriculture': isAgriConstEligible,
      'construction': isAgriConstEligible,
      'tourism_hospitality': isTourism462Eligible,
      'forestry': isNorthernAustralia,
      'fishing': isNorthernAustralia,
      'forestry_fishing': isNorthernAustralia,
      'mining': isNorthernAustralia,
      'bushfire_recovery': isAgriConstEligible,
      'flood_recovery': isAgriConstEligible,
    };

    final Map<String, bool> subclass417 = {
      'agriculture': isAgriConstEligible,
      'construction': isAgriConstEligible,
      'tourism_hospitality': false, // NO computable para 417 desde 1 julio 2023
      'forestry': isAgriConstEligible,
      'fishing': isAgriConstEligible,
      'forestry_fishing': isAgriConstEligible,
      'mining': isAgriConstEligible,
      'bushfire_recovery': isAgriConstEligible,
      'flood_recovery': isAgriConstEligible,
    };

    return PostcodeInfo(
      code: codeStr,
      location: location,
      state: state == 'Norfolk Island' ? 'NSW' : state,
      zone: zone,
      subclass462: subclass462,
      subclass417: subclass417,
    );
  }
}

