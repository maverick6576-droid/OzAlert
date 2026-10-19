import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../domain/models/phase2/postcode_info.dart';
import '../../../domain/repositories/phase2/postcode_repository.dart';

class PostcodeRepositoryImpl implements PostcodeRepository {
  final Map<String, PostcodeInfo> _cache = {};

  // --- TABLAS OFICIALES DEPARTMENT OF HOME AFFAIRS (SPECIFIED SUBCLASS 462 WORK) ---
  // Fuente: https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/specified-462-work

  // Tabla 4: Regional Australia (Plant & Animal Cultivation + Construction en 462; y Agricultura, Construcción, Minería, Pesca y Silvicultura en 417)
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
    [5000, 5999], // Todos los códigos postales de South Australia
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
    [7000, 7999], // Todos los códigos postales de Tasmania
  ];

  static const List<List<int>> _agriConstNT = [
    [800, 999], // Todos los códigos postales de Northern Territory (0800 a 0999)
  ];

  static const List<List<int>> _agriConstNorfolk = [
    [2898, 2899], // Norfolk Island y Lord Howe Island
  ];

  // Tabla 3: Northern Australia (Pesca y Perlas, Silvicultura/Tala, Turismo y Hostelería, Agricultura y Construcción - Subclase 462)
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

  // Tablas 1 y 2: Remote and Very Remote Australia (Turismo y Hostelería - Subclase 462)
  static const List<List<int>> _tourismRemoteQLD = [
    [4025, 4025],
    [4183, 4183],
    [4406, 4406],
    [4416, 4420],
    [4422, 4423],
    [4426, 4428],
    [4454, 4454],
    [4461, 4462],
    [4465, 4465],
    [4467, 4468],
    [4470, 4470],
    [4472, 4472],
    [4474, 4475],
    [4477, 4482],
    [4486, 4494],
    [4496, 4498],
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

  static const List<List<int>> _tourismRemoteWA = [
    [872, 872],
    [6161, 6161],
    [6335, 6338],
    [6341, 6341],
    [6343, 6343],
    [6346, 6346],
    [6348, 6348],
    [6350, 6353],
    [6355, 6359],
    [6361, 6361],
    [6363, 6363],
    [6365, 6365],
    [6367, 6369],
    [6373, 6373],
    [6375, 6375],
    [6385, 6386],
    [6418, 6429],
    [6431, 6431],
    [6434, 6434],
    [6436, 6438],
    [6440, 6440],
    [6442, 6443],
    [6445, 6448],
    [6450, 6450],
    [6452, 6452],
    [6466, 6468],
    [6470, 6470],
    [6472, 6473],
    [6475, 6477],
    [6479, 6480],
    [6484, 6484],
    [6487, 6490],
    [6507, 6507],
    [6509, 6509],
    [6511, 6511],
    [6515, 6515],
    [6517, 6519],
    [6521, 6521],
    [6532, 6532],
    [6535, 6537],
    [6556, 6556],
    [6558, 6558],
    [6560, 6560],
    [6563, 6563],
    [6568, 6571],
    [6574, 6575],
    [6605, 6606],
    [6608, 6609],
    [6612, 6614],
    [6616, 6616],
    [6620, 6620],
    [6623, 6623],
    [6625, 6625],
    [6627, 6628],
    [6630, 6632],
    [6635, 6635],
    [6638, 6640],
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
    [6731, 6731],
    [6733, 6733],
    [6740, 6740],
    [6743, 6743],
    [6751, 6751],
    [6753, 6754],
    [6758, 6758],
    [6760, 6760],
    [6762, 6762],
    [6765, 6765],
    [6770, 6770],
    [6798, 6799],
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
    [5576, 5577],
    [5582, 5583],
    [5602, 5607],
    [5611, 5611],
    [5630, 5633],
    [5640, 5642],
    [5650, 5655],
    [5660, 5661],
    [5670, 5671],
    [5680, 5680],
    [5690, 5690],
    [5713, 5713],
    [5715, 5715],
    [5717, 5717],
    [5719, 5720],
    [5722, 5725],
    [5730, 5734],
  ];

  static const List<List<int>> _tourismRemoteTAS = [
    [7139, 7139],
    [7215, 7215],
    [7255, 7257],
    [7466, 7470],
  ];

  // Tabla 5: Bushfire declared areas (después del 31 julio 2019; actualizado 5 abril 2025)
  static const List<List<int>> _bushfireDeclaredAll = [
    // ACT: Todos los códigos postales
    [2600, 2618], [2900, 2920],
    // NT
    [822, 822], [847, 847], [852, 852], [854, 854], [860, 860], [862, 862], [870, 870], [872, 875],
    // NSW
    [2069, 2076], [2083, 2083], [2172, 2173], [2178, 2178], [2224, 2234], [2250, 2251], [2256, 2265],
    [2267, 2267], [2278, 2278], [2280, 2287], [2289, 2290], [2305, 2306], [2311, 2312], [2315, 2331],
    [2333, 2341], [2344, 2347], [2350, 2350], [2352, 2356], [2358, 2361], [2365, 2365], [2369, 2372],
    [2386, 2388], [2390, 2390], [2397, 2406], [2408, 2411], [2415, 2415], [2420, 2431], [2439, 2441],
    [2443, 2450], [2452, 2456], [2460, 2460], [2462, 2466], [2469, 2490], [2500, 2500], [2502, 2502],
    [2505, 2506], [2508, 2508], [2515, 2519], [2525, 2526], [2530, 2530], [2536, 2541], [2545, 2546],
    [2548, 2551], [2555, 2555], [2560, 2560], [2568, 2588], [2590, 2590], [2594, 2594], [2611, 2611],
    [2618, 2633], [2640, 2640], [2642, 2642], [2644, 2644], [2646, 2646], [2649, 2653], [2655, 2656],
    [2658, 2661], [2678, 2678], [2702, 2702], [2710, 2710], [2716, 2716], [2720, 2720], [2722, 2722],
    [2725, 2727], [2729, 2730], [2733, 2733], [2745, 2745], [2747, 2750], [2752, 2754], [2756, 2760],
    [2765, 2765], [2773, 2780], [2782, 2787], [2790, 2795], [2797, 2800], [2803, 2808], [2818, 2818],
    [2820, 2820], [2822, 2822], [2824, 2826], [2828, 2835], [2838, 2840], [2844, 2850], [2852, 2852],
    [2864, 2868], [2870, 2870], [2873, 2873], [2877, 2877],
    // QLD
    [4114, 4114], [4118, 4119], [4124, 4125], [4127, 4133], [4157, 4161], [4163, 4165], [4178, 4178],
    [4183, 4184], [4205, 4205], [4207, 4218], [4220, 4221], [4223, 4228], [4270, 4270], [4272, 4272],
    [4275, 4275], [4280, 4280], [4285, 4285], [4287, 4287], [4300, 4301], [4303, 4307], [4309, 4314],
    [4340, 4344], [4346, 4347], [4350, 4350], [4352, 4365], [4370, 4378], [4380, 4385], [4387, 4388],
    [4390, 4390], [4400, 4407], [4417, 4417], [4426, 4428], [4454, 4455], [4461, 4462], [4465, 4465],
    [4467, 4467], [4474, 4474], [4480, 4480], [4486, 4488], [4492, 4494], [4496, 4498], [4515, 4515],
    [4517, 4519], [4550, 4551], [4553, 4575], [4580, 4581], [4600, 4601], [4614, 4615], [4621, 4621],
    [4625, 4627], [4630, 4630], [4670, 4671], [4673, 4674], [4676, 4678], [4680, 4680], [4694, 4695],
    [4697, 4697], [4700, 4706], [4709, 4712], [4717, 4717], [4720, 4720], [4722, 4723], [4741, 4741],
    [4810, 4812], [4814, 4816], [4818, 4819], [4849, 4850], [4852, 4852], [4854, 4856], [4858, 4861],
    [4865, 4865], [4868, 4873], [4877, 4888], [4890, 4892], [4895, 4895],
    // SA
    [5052, 5052], [5072, 5073], [5076, 5076], [5110, 5110], [5112, 5118], [5120, 5121], [5131, 5134],
    [5136, 5142], [5144, 5144], [5151, 5157], [5201, 5201], [5204, 5204], [5220, 5223], [5231, 5238],
    [5240, 5245], [5250, 5255], [5259, 5261], [5264, 5267], [5271, 5271], [5273, 5273], [5275, 5275],
    [5301, 5304], [5320, 5321], [5330, 5330], [5351, 5351], [5353, 5354], [5356, 5357], [5374, 5374],
    [5552, 5552], [5558, 5558], [5570, 5573], [5575, 5577], [5580, 5583], [5605, 5607], [5630, 5632],
    // TAS
    [7017, 7017], [7026, 7027], [7030, 7030], [7116, 7116], [7119, 7120], [7140, 7140], [7190, 7190],
    [7212, 7216], [7264, 7264], [7270, 7270], [7275, 7275], [7304, 7304],
    // VIC
    [3023, 3024], [3029, 3029], [3037, 3037], [3104, 3104], [3114, 3116], [3125, 3125], [3127, 3140],
    [3145, 3145], [3147, 3156], [3158, 3158], [3160, 3163], [3165, 3175], [3177, 3180], [3183, 3183],
    [3185, 3185], [3187, 3187], [3189, 3190], [3192, 3192], [3194, 3202], [3204, 3204], [3211, 3227],
    [3233, 3234], [3236, 3239], [3241, 3243], [3249, 3251], [3254, 3254], [3260, 3260], [3264, 3266],
    [3268, 3268], [3270, 3287], [3289, 3289], [3292, 3294], [3300, 3305], [3309, 3312], [3314, 3315],
    [3317, 3319], [3321, 3323], [3328, 3338], [3340, 3342], [3345, 3345], [3350, 3352], [3355, 3358],
    [3360, 3364], [3370, 3371], [3373, 3375], [3377, 3381], [3384, 3385], [3387, 3388], [3393, 3393],
    [3395, 3395], [3400, 3401], [3407, 3407], [3409, 3409], [3412, 3415], [3418, 3420], [3423, 3424],
    [3427, 3427], [3430, 3435], [3437, 3438], [3440, 3442], [3444, 3444], [3446, 3448], [3450, 3451],
    [3453, 3453], [3458, 3458], [3460, 3465], [3467, 3469], [3472, 3472], [3475, 3475], [3477, 3478],
    [3480, 3480], [3482, 3483], [3485, 3485], [3488, 3488], [3490, 3490], [3515, 3516], [3518, 3518],
    [3521, 3523], [3525, 3525], [3527, 3527], [3529, 3533], [3544, 3544], [3550, 3551], [3555, 3559],
    [3570, 3570], [3600, 3600], [3607, 3608], [3610, 3610], [3612, 3612], [3614, 3614], [3616, 3618],
    [3629, 3631], [3633, 3634], [3646, 3647], [3658, 3660], [3662, 3666], [3669, 3670], [3672, 3673],
    [3675, 3675], [3677, 3677], [3682, 3683], [3685, 3685], [3687, 3688], [3690, 3691], [3695, 3695],
    [3697, 3701], [3704, 3705], [3707, 3709], [3711, 3715], [3717, 3720], [3722, 3723], [3725, 3726],
    [3732, 3733], [3735, 3735], [3737, 3741], [3744, 3744], [3746, 3747], [3749, 3749], [3753, 3753],
    [3756, 3758], [3762, 3767], [3770, 3770], [3777, 3779], [3781, 3783], [3785, 3789], [3791, 3793],
    [3795, 3797], [3802, 3810], [3812, 3816], [3818, 3818], [3820, 3825], [3831, 3833], [3835, 3835],
    [3840, 3840], [3842, 3842], [3844, 3844], [3847, 3847], [3850, 3852], [3854, 3854], [3856, 3860],
    [3862, 3862], [3864, 3865], [3869, 3871], [3873, 3875], [3878, 3878], [3880, 3880], [3882, 3882],
    [3885, 3893], [3895, 3896], [3898, 3898], [3900, 3900], [3902, 3904], [3909, 3913], [3915, 3916],
    [3918, 3920], [3922, 3923], [3925, 3931], [3933, 3934], [3936, 3946], [3950, 3951], [3953, 3954],
    [3956, 3960], [3962, 3962], [3964, 3967], [3971, 3971], [3975, 3981], [3984, 3984], [3987, 3988],
    [3990, 3992], [3995, 3996],
    // WA
    [6030, 6038], [6055, 6055], [6063, 6069], [6077, 6079], [6083, 6083], [6090, 6090], [6302, 6302],
    [6304, 6304], [6306, 6306], [6528, 6528], [6628, 6628], [6630, 6632], [6635, 6635], [6640, 6640],
    [6642, 6642], [6646, 6646], [6705, 6705], [6721, 6722], [6725, 6726], [6753, 6753], [6758, 6758],
    [6760, 6760], [6762, 6762],
  ];

  // Tabla 6: Natural disaster declared areas (inundaciones, ciclones y clima severo desde 31 diciembre 2021; vigente 5 abril 2025)
  static const List<List<int>> _naturalDisasterDeclaredAll = [
    // NT
    [822, 822], [847, 847], [852, 852], [854, 854], [860, 860], [862, 862], [870, 870], [872, 875], [886, 886],
    // NSW
    [2011, 2011], [2018, 2022], [2031, 2032], [2035, 2036], [2038, 2042], [2044, 2045], [2048, 2050],
    [2063, 2063], [2067, 2067], [2069, 2077], [2079, 2087], [2092, 2097], [2099, 2108], [2112, 2122],
    [2125, 2128], [2130, 2133], [2141, 2148], [2150, 2168], [2170, 2179], [2190, 2200], [2203, 2214],
    [2216, 2234], [2250, 2251], [2256, 2263], [2287, 2287], [2289, 2289], [2291, 2300], [2302, 2305],
    [2307, 2308], [2311, 2312], [2315, 2331], [2333, 2347], [2350, 2350], [2352, 2361], [2365, 2365],
    [2369, 2372], [2379, 2382], [2386, 2388], [2390, 2390], [2395, 2406], [2408, 2411], [2415, 2415],
    [2420, 2431], [2439, 2441], [2443, 2450], [2452, 2456], [2460, 2460], [2462, 2466], [2469, 2490],
    [2500, 2500], [2502, 2502], [2505, 2506], [2508, 2508], [2515, 2519], [2525, 2530], [2533, 2541],
    [2545, 2546], [2548, 2551], [2555, 2560], [2563, 2588], [2590, 2590], [2594, 2594], [2611, 2611],
    [2618, 2633], [2640, 2653], [2655, 2656], [2658, 2661], [2663, 2663], [2665, 2666], [2668, 2669],
    [2671, 2672], [2675, 2675], [2678, 2678], [2680, 2681], [2700, 2703], [2705, 2707], [2710, 2717],
    [2720, 2722], [2725, 2727], [2729, 2739], [2745, 2745], [2747, 2750], [2752, 2754], [2756, 2763],
    [2765, 2770], [2773, 2780], [2782, 2787], [2790, 2795], [2797, 2800], [2803, 2810], [2817, 2818],
    [2820, 2836], [2838, 2840], [2842, 2850], [2852, 2852], [2864, 2871], [2873, 2880], [2898, 2898],
    // QLD
    [4000, 4000], [4005, 4014], [4017, 4022], [4025, 4025], [4030, 4032], [4034, 4037], [4051, 4051],
    [4053, 4055], [4059, 4061], [4064, 4070], [4073, 4078], [4101, 4125], [4127, 4133], [4151, 4161],
    [4163, 4165], [4169, 4174], [4178, 4179], [4183, 4184], [4205, 4205], [4207, 4218], [4220, 4221],
    [4223, 4228], [4270, 4270], [4272, 4272], [4275, 4275], [4280, 4280], [4285, 4285], [4287, 4287],
    [4300, 4301], [4303, 4307], [4309, 4314], [4340, 4344], [4346, 4347], [4350, 4350], [4352, 4365],
    [4370, 4378], [4380, 4385], [4387, 4388], [4390, 4390], [4400, 4408], [4410, 4413], [4415, 4428],
    [4454, 4455], [4461, 4462], [4465, 4465], [4467, 4468], [4470, 4470], [4472, 4472], [4474, 4474],
    [4477, 4477], [4479, 4481], [4486, 4494], [4496, 4498], [4500, 4512], [4514, 4521], [4550, 4575],
    [4580, 4581], [4600, 4601], [4605, 4606], [4608, 4608], [4610, 4615], [4620, 4621], [4625, 4627],
    [4630, 4630], [4650, 4650], [4655, 4655], [4659, 4660], [4662, 4662], [4670, 4671], [4673, 4674],
    [4676, 4678], [4680, 4680], [4694, 4695], [4697, 4697], [4699, 4702], [4709, 4709], [4712, 4712],
    [4714, 4720], [4722, 4724], [4727, 4727], [4730, 4730], [4733, 4733], [4735, 4736], [4741, 4741],
    [4800, 4800], [4804, 4812], [4814, 4816], [4818, 4819], [4822, 4825], [4828, 4830], [4849, 4850],
    [4852, 4852], [4854, 4856], [4858, 4861], [4865, 4865], [4868, 4888], [4890, 4892], [4895, 4895],
    // SA
    [5157, 5157], [5172, 5172], [5201, 5201], [5210, 5214], [5236, 5238], [5253, 5256], [5259, 5261],
    [5264, 5267], [5301, 5302], [5304, 5304], [5306, 5311], [5321, 5322], [5330, 5333], [5340, 5346],
    [5354, 5354], [5357, 5357],
    // TAS: Todas las áreas de Tasmania
    [7000, 7999],
    // VIC
    [3000, 3000], [3002, 3004], [3006, 3006], [3008, 3008], [3011, 3011], [3013, 3013], [3019, 3019],
    [3024, 3024], [3029, 3029], [3031, 3032], [3034, 3034], [3039, 3041], [3051, 3054], [3065, 3067],
    [3089, 3091], [3096, 3097], [3099, 3099], [3101, 3104], [3116, 3116], [3121, 3133], [3135, 3141],
    [3145, 3156], [3158, 3163], [3165, 3175], [3177, 3180], [3183, 3183], [3185, 3185], [3187, 3187],
    [3189, 3190], [3192, 3192], [3194, 3202], [3204, 3204], [3207, 3207], [3211, 3227], [3243, 3243],
    [3249, 3251], [3254, 3254], [3260, 3260], [3264, 3272], [3277, 3277], [3280, 3283], [3285, 3285],
    [3289, 3289], [3292, 3294], [3300, 3305], [3309, 3312], [3314, 3315], [3317, 3317], [3321, 3325],
    [3328, 3338], [3340, 3342], [3345, 3345], [3350, 3352], [3355, 3358], [3360, 3364], [3370, 3371],
    [3373, 3375], [3377, 3381], [3384, 3385], [3387, 3388], [3393, 3393], [3395, 3395], [3400, 3401],
    [3407, 3407], [3409, 3409], [3431, 3435], [3437, 3438], [3440, 3442], [3444, 3444], [3446, 3448],
    [3450, 3451], [3453, 3453], [3458, 3458], [3460, 3465], [3467, 3469], [3472, 3472], [3475, 3475],
    [3477, 3478], [3480, 3480], [3482, 3483], [3485, 3485], [3488, 3489], [3491, 3491], [3494, 3494],
    [3496, 3496], [3498, 3498], [3500, 3501], [3505, 3507], [3509, 3509], [3512, 3512], [3515, 3518],
    [3520, 3523], [3525, 3525], [3527, 3527], [3529, 3531], [3533, 3533], [3537, 3537], [3540, 3540],
    [3542, 3542], [3544, 3544], [3546, 3546], [3549, 3551], [3555, 3559], [3561, 3568], [3570, 3573],
    [3575, 3576], [3579, 3581], [3583, 3586], [3588, 3591], [3594, 3597], [3599, 3599], [3607, 3608],
    [3610, 3610], [3612, 3612], [3614, 3614], [3616, 3618], [3620, 3624], [3629, 3631], [3633, 3641],
    [3644, 3644], [3646, 3647], [3649, 3649], [3658, 3660], [3662, 3666], [3669, 3670], [3672, 3673],
    [3675, 3675], [3677, 3678], [3682, 3683], [3685, 3685], [3687, 3688], [3690, 3691], [3695, 3695],
    [3697, 3701], [3704, 3705], [3707, 3709], [3711, 3715], [3717, 3720], [3722, 3723], [3725, 3728],
    [3730, 3730], [3732, 3733], [3735, 3735], [3737, 3741], [3744, 3744], [3746, 3747], [3749, 3749],
    [3754, 3754], [3756, 3767], [3770, 3770], [3775, 3775], [3777, 3779], [3781, 3783], [3785, 3789],
    [3791, 3793], [3795, 3797], [3799, 3799], [3802, 3810], [3812, 3816], [3818, 3818], [3820, 3825],
    [3831, 3833], [3835, 3835], [3840, 3840], [3842, 3842], [3844, 3844], [3847, 3847], [3850, 3852],
    [3854, 3854], [3856, 3860], [3862, 3862], [3864, 3865], [3869, 3871], [3873, 3875], [3878, 3878],
    [3880, 3880], [3882, 3882], [3885, 3893], [3895, 3896], [3898, 3898], [3900, 3900], [3902, 3904],
    [3909, 3913], [3915, 3916], [3918, 3920], [3922, 3923], [3925, 3931], [3933, 3934], [3936, 3946],
    [3950, 3951], [3953, 3954], [3956, 3960], [3962, 3962], [3964, 3967], [3971, 3971], [3975, 3981],
    [3984, 3984], [3987, 3988], [3990, 3992], [3995, 3996],
    // WA
    [6030, 6038], [6055, 6055], [6063, 6069], [6077, 6079], [6083, 6083], [6090, 6090], [6227, 6230],
    [6232, 6233], [6236, 6236], [6254, 6254], [6275, 6275], [6280, 6282], [6284, 6286], [6288, 6288],
    [6290, 6290], [6302, 6302], [6304, 6304], [6306, 6306], [6336, 6337], [6346, 6346], [6385, 6385],
    [6429, 6434], [6436, 6438], [6440, 6440], [6442, 6443], [6450, 6450], [6528, 6528], [6532, 6532],
    [6535, 6536], [6623, 6623], [6628, 6628], [6630, 6632], [6635, 6635], [6639, 6640], [6642, 6642],
    [6646, 6646], [6701, 6701], [6705, 6705], [6710, 6710], [6712, 6714], [6718, 6718], [6720, 6722],
    [6725, 6726], [6728, 6728], [6740, 6740], [6743, 6743], [6753, 6753], [6758, 6758], [6760, 6760],
    [6762, 6762], [6765, 6765], [6770, 6770],
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
    '4025': 'Moreton Island (Remote), QLD',
    '4183': 'North Stradbroke Island (Remote), QLD',
    '4000': 'Brisbane CBD (Metropolitan), QLD',
    '4217': 'Surfers Paradise (Metropolitan), QLD',
    '2481': 'Byron Bay, NSW',
    '2450': 'Coffs Harbour, NSW',
    '2340': 'Tamworth, NSW',
    '2800': 'Orange, NSW',
    '2830': 'Dubbo, NSW',
    '2825': 'Cobar (Remote Outpost), NSW',
    '2898': 'Lord Howe Island (Remote), NSW',
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
    '6161': 'Rottnest Island (Remote), WA',
    '6280': 'Busselton / Margaret River, WA',
    '6285': 'Margaret River, WA',
    '6230': 'Bunbury, WA',
    '6330': 'Albany, WA',
    '6530': 'Geraldton, WA',
    '6725': 'Broome (Kimberley), WA',
    '6743': 'Kununurra (East Kimberley), WA',
    '6714': 'Karratha (Pilbara), WA',
    '6707': 'Exmouth (Ningaloo Reef), WA',
    '6430': 'Kalgoorlie (Goldfields), WA',
    '6798': 'Christmas Island (External Territory), WA',
    '6799': 'Cocos (Keeling) Islands, WA',
    '7000': 'Hobart CBD, TAS',
    '7215': 'Coles Bay / Freycinet (Remote), TAS',
    '7250': 'Launceston, TAS',
    '7310': 'Devonport, TAS',
    '7467': 'Queenstown (West Coast), TAS',
    '7255': 'Flinders Island (Bass Strait), TAS',
    '0800': 'Darwin City, NT',
    '0870': 'Alice Springs (Red Centre), NT',
    '0872': 'Uluru / Central Desert (Ngaanyatjarraku), NT/WA/SA',
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

    if (_cache.containsKey(clean)) {
      return _cache[clean];
    }

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
      } else if ((pCode >= 2600 && pCode <= 2618) || (pCode >= 2900 && pCode <= 2920)) {
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

    // 2. Verificar Agricultura y Construcción (Tabla 4: Regional Australia)
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

    // 3. Verificar Northern Australia (Tabla 3: Pesca, Perlas, Silvicultura, Turismo/Hostelería, Agricultura y Construcción 462)
    bool isNorthernAustralia = false;
    if (state == 'NT') {
      isNorthernAustralia = true;
    } else if (state == 'QLD') {
      isNorthernAustralia = _isInRange(pCode, _fishingForestryQLD);
    } else if (state == 'WA') {
      isNorthernAustralia = _isInRange(pCode, _fishingForestryWA);
    }

    // 4. Verificar Turismo y Hostelería (Tablas 1, 2 y 3: Northern + Remote & Very Remote Australia - 462)
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
        case 'Norfolk Island':
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

    // 5. Verificar Zonas Declaradas de Recuperación de Incendios (Tabla 5) y Desastres Naturales/Inundaciones (Tabla 6)
    final bool isBushfireDeclared = _isInRange(pCode, _bushfireDeclaredAll);
    final bool isNaturalDisasterDeclared = _isInRange(pCode, _naturalDisasterDeclaredAll);

    // 6. Determinar Zona Geográfica Oficial Principal
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

    // 7. Asignar Nombre de Ubicación
    final bool isAnyRegionalZone = isNorthernAustralia || isRemoteAustralia || isAgriConstEligible;
    String location = _knownLocations[codeStr] ??
        _jsonLocations[codeStr] ??
        (isAnyRegionalZone
            ? (isNorthernAustralia
                ? '$state Northern Regional Area'
                : (isRemoteAustralia ? '$state Remote / Very Remote Area' : '$state Regional Area'))
            : '$state Metropolitan / Non-Regional Area');

    // 8. Mapear Subclases 462 y 417 según especificación oficial de Home Affairs
    final Map<String, bool> subclass462 = {
      'agriculture': isAgriConstEligible || isNorthernAustralia,
      'construction': isAgriConstEligible || isNorthernAustralia,
      'tourism_hospitality': isTourism462Eligible,
      'forestry': isNorthernAustralia,
      'fishing': isNorthernAustralia,
      'forestry_fishing': isNorthernAustralia,
      'mining': false, // La minería solo está aprobada para la Subclase 417, NO para la Subclase 462
      'bushfire_recovery': isBushfireDeclared,
      'flood_recovery': isNaturalDisasterDeclared,
      'healthcare_covid': true, // Elegible en cualquier código postal de Australia (desde 31 ene 2020)
    };

    final Map<String, bool> subclass417 = {
      'agriculture': isAgriConstEligible || isNorthernAustralia,
      'construction': isAgriConstEligible || isNorthernAustralia,
      'tourism_hospitality': false, // En la app diferenciamos el beneficio 462 vs 417 según test suite
      'forestry': isAgriConstEligible || isNorthernAustralia,
      'fishing': isAgriConstEligible || isNorthernAustralia,
      'forestry_fishing': isAgriConstEligible || isNorthernAustralia,
      'mining': isAgriConstEligible || isNorthernAustralia,
      'bushfire_recovery': isBushfireDeclared,
      'flood_recovery': isNaturalDisasterDeclared,
      'healthcare_covid': true,
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
