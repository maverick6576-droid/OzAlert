import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/phase2/affiliate_partner.dart';
import '../../../domain/models/phase2/landing_task.dart';
import '../../../domain/models/phase2/regional_work_log.dart';
import '../../../domain/repositories/phase2/affiliate_repository.dart';
import '../../../domain/repositories/phase2/landing_repository.dart';
import '../../../domain/repositories/phase2/postcode_repository.dart';
import '../../../domain/repositories/phase2/visa_stats_repository.dart';
import '../../../domain/repositories/phase2/guide_repository.dart';
import '../../../domain/models/phase2/guide_data.dart';
import '../../../data/repositories/phase2/affiliate_repository_impl.dart';
import '../../../data/repositories/phase2/landing_repository_impl.dart';
import '../../../data/repositories/phase2/postcode_repository_impl.dart';
import '../../../data/repositories/phase2/visa_stats_repository_impl.dart';
import '../../../data/repositories/phase2/guide_repository_impl.dart';
import '../../../core/services/community_telemetry_service.dart';

// --- Repositories ---

final affiliateRepositoryProvider = Provider<AffiliateRepository>((ref) {
  FirebaseRemoteConfig? remoteConfig;
  try {
    remoteConfig = FirebaseRemoteConfig.instance;
  } catch (_) {}
  final repo = AffiliateRepositoryImpl(remoteConfig: remoteConfig);
  repo.init();
  return repo;
});

final guideRepositoryProvider = Provider<GuideRepository>((ref) {
  return GuideRepositoryImpl();
});

final postcodeRepositoryProvider = Provider<PostcodeRepository>((ref) {
  final repo = PostcodeRepositoryImpl();
  repo.init();
  return repo;
});

final landingRepositoryProvider = Provider<LandingRepository>((ref) {
  return LandingRepositoryImpl();
});

final visaStatsRepositoryProvider = Provider<VisaStatsRepository>((ref) {
  return VisaStatsRepositoryImpl();
});

// --- State Providers ---

/// Proveedor de partners B2B dinámicos por categoría
final affiliateCategoryProvider = FutureProvider.family<List<AffiliatePartner>, String>((ref, category) async {
  final repo = ref.watch(affiliateRepositoryProvider);
  return repo.getPartnersByCategory(category);
});

/// Proveedor de guías y comparativas estructuradas por categoría
final guideCategoryProvider = FutureProvider.family<CategoryGuide?, String>((ref, category) async {
  final repo = ref.watch(guideRepositoryProvider);
  return repo.getGuideForCategory(category);
});

/// Proveedor de tareas de aterrizaje
final landingTasksProvider = AsyncNotifierProvider<LandingTasksNotifier, List<LandingTask>>(() {
  return LandingTasksNotifier();
});

class LandingTasksNotifier extends AsyncNotifier<List<LandingTask>> {
  @override
  Future<List<LandingTask>> build() async {
    final repo = ref.read(landingRepositoryProvider);
    return repo.getTasks();
  }

  Future<void> toggleTask(String taskId, bool isDone) async {
    final repo = ref.read(landingRepositoryProvider);
    await repo.toggleTaskCompleted(taskId, isDone);
    state = AsyncValue.data(await repo.getTasks());
  }
}

/// Control de navegación interna de Fase 2 (Tabs y redirección directa a guías)
class Phase2NavigationState {
  final int currentTabIndex; // 0 = Aterrizaje, 1 = Guías, 2 = Empleo, 3 = 88 Días, 4 = Ajustes
  final String? activeGuideCategory;

  const Phase2NavigationState({
    this.currentTabIndex = 0,
    this.activeGuideCategory,
  });

  Phase2NavigationState copyWith({
    int? currentTabIndex,
    String? activeGuideCategory,
  }) {
    return Phase2NavigationState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      activeGuideCategory: activeGuideCategory,
    );
  }
}

class Phase2NavigationNotifier extends StateNotifier<Phase2NavigationState> {
  Phase2NavigationNotifier() : super(const Phase2NavigationState());

  void setTabIndex(int index) {
    state = state.copyWith(currentTabIndex: index, activeGuideCategory: null);
  }

  void navigateToGuide(String category) {
    state = Phase2NavigationState(currentTabIndex: 1, activeGuideCategory: category);
  }

  void returnToLanding() {
    state = const Phase2NavigationState(currentTabIndex: 0);
  }
}

final phase2NavigationProvider = StateNotifierProvider<Phase2NavigationNotifier, Phase2NavigationState>((ref) {
  return Phase2NavigationNotifier();
});

/// Tracker de empleos regionales (88 Días y 3r Año) con sincronización Cloud Firestore y persistencia local
class RegionalJobsNotifier extends StateNotifier<List<RegionalJobEntry>> {
  final FirebaseFirestore? _firestore;
  String? _syncedUid;
  bool _isLoading = false;
  final Set<String> _deletedIds = {};

  RegionalJobsNotifier({FirebaseFirestore? firestore})
      : _firestore = firestore,
        super([]);

  String _prefsKey(String? uid) => 'regional_work_logs_${uid != null && uid.isNotEmpty ? uid : "local"}';

  Future<void> _saveToLocal(String? uid, List<RegionalJobEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_prefsKey(uid), encoded);
    } catch (_) {}
  }

  Future<List<RegionalJobEntry>> _loadFromLocal(String? uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(RegionalJobEntry.fromJson)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  List<RegionalJobEntry> _mergeEntries(
    List<RegionalJobEntry> current,
    List<RegionalJobEntry> incoming,
  ) {
    final map = <String, RegionalJobEntry>{};
    for (final item in incoming) {
      if (item.id.isNotEmpty && !_deletedIds.contains(item.id)) {
        map[item.id] = item;
      }
    }
    for (final item in current) {
      if (item.id.isNotEmpty && !_deletedIds.contains(item.id)) {
        map[item.id] = item;
      }
    }
    return map.values.toList();
  }

  Future<void> loadForUser({required String? uid, bool isPremium = true}) async {
    final effectiveUid = (uid != null && uid.isNotEmpty) ? uid : null;
    if (_syncedUid == effectiveUid && (_isLoading || state.isNotEmpty)) return;
    if (_isLoading && _syncedUid == effectiveUid) return;
    _syncedUid = effectiveUid;
    _isLoading = true;

    try {
      // 1. Cargar caché local inmediata
      final localEntries = await _loadFromLocal(effectiveUid);
      if (localEntries.isNotEmpty) {
        state = _mergeEntries(state, localEntries);
      }

      if (effectiveUid == null) {
        _isLoading = false;
        return;
      }

      final fs = _firestore ?? FirebaseFirestore.instance;
      final cloudEntries = <RegionalJobEntry>[];

      // 2. Leer del documento principal users/{uid} (permitido por las reglas de seguridad de perfil)
      try {
        final userDoc = await fs.collection('users').doc(effectiveUid).get();
        final data = userDoc.data();
        if (data != null && data['regionalWorkLogs'] is List) {
          final rawList = data['regionalWorkLogs'] as List<dynamic>;
          for (final item in rawList) {
            if (item is Map) {
              cloudEntries.add(
                RegionalJobEntry.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      } catch (_) {}

      // 3. Leer también de la subcolección regional_work_logs por retrocompatibilidad
      try {
        final snapshot = await fs
            .collection('users')
            .doc(effectiveUid)
            .collection('regional_work_logs')
            .get();
        if (snapshot.docs.isNotEmpty) {
          for (final doc in snapshot.docs) {
            cloudEntries.add(RegionalJobEntry.fromJson(doc.data()));
          }
        }
      } catch (_) {}

      if (cloudEntries.isNotEmpty || state.isNotEmpty) {
        final merged = _mergeEntries(state, cloudEntries);
        state = merged;
        await _saveToLocal(effectiveUid, merged);
      }
    } catch (_) {
      // Offline fallback
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _syncAllToFirestore(String uid, List<RegionalJobEntry> entries) async {
    final fs = _firestore ?? FirebaseFirestore.instance;
    final serialized = entries.map((j) => j.toJson()).toList();
    // Guardado principal dentro de users/{uid} (garantizado por permisos de documento de usuario)
    await fs.collection('users').doc(uid).set(
      {
        'regionalWorkLogs': serialized,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> addJob(RegionalJobEntry job, {String? uid, bool isPremium = false}) async {
    _deletedIds.remove(job.id);
    final updated = [...state.where((j) => j.id != job.id), job];
    state = updated;

    final effectiveUid = (uid != null && uid.isNotEmpty) ? uid : _syncedUid;
    await _saveToLocal(effectiveUid, updated);

    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      try {
        await _syncAllToFirestore(effectiveUid, updated);
      } catch (_) {}

      try {
        final fs = _firestore ?? FirebaseFirestore.instance;
        await fs
            .collection('users')
            .doc(effectiveUid)
            .collection('regional_work_logs')
            .doc(job.id)
            .set(job.toJson());
      } catch (_) {}

      // Telemetría anónima silenciosa comunitaria (OzAlert Benchmark de Granjas)
      CommunityTelemetryService().logFarmShift(
        abn: job.employerAbn,
        postcode: job.workSitePostcode,
        industry: job.industry,
        hourlyRateAud: job.totalHours > 0 ? (job.grossEarningsAud / job.totalHours) : 0.0,
        hoursWorked: job.totalHours,
        grossPayAud: job.grossEarningsAud,
        isFairWorkCompliant: true,
        hasPiecework: job.hasPieceworkAgreement,
        form1263Signed: false,
        targetVisaYear: job.targetVisaYear,
      );
    }
  }

  Future<void> removeJob(String id, {String? uid, bool isPremium = false}) async {
    _deletedIds.add(id);
    final updated = state.where((j) => j.id != id).toList();
    state = updated;

    final effectiveUid = (uid != null && uid.isNotEmpty) ? uid : _syncedUid;
    await _saveToLocal(effectiveUid, updated);

    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      try {
        await _syncAllToFirestore(effectiveUid, updated);
      } catch (_) {}

      try {
        final fs = _firestore ?? FirebaseFirestore.instance;
        await fs
            .collection('users')
            .doc(effectiveUid)
            .collection('regional_work_logs')
            .doc(id)
            .delete();
      } catch (_) {}
    }
  }

  int get totalDaysAccumulated {
    return state.fold(0, (total, j) => total + j.totalDaysCounted);
  }

  int daysAccumulatedForYear(int targetYear) {
    return state
        .where((j) => j.targetVisaYear == targetYear)
        .fold(0, (total, j) => total + j.totalDaysCounted);
  }
}

final regionalJobsProvider = StateNotifierProvider<RegionalJobsNotifier, List<RegionalJobEntry>>((ref) {
  FirebaseFirestore? fs;
  try {
    fs = FirebaseFirestore.instance;
  } catch (_) {}
  return RegionalJobsNotifier(firestore: fs);
});
