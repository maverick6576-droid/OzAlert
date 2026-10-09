import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

/// Tracker de empleos regionales (88 Días y 3r Año) con sincronización Cloud Firestore para Premium
class RegionalJobsNotifier extends StateNotifier<List<RegionalJobEntry>> {
  final FirebaseFirestore? _firestore;
  String? _syncedUid;

  RegionalJobsNotifier({FirebaseFirestore? firestore})
      : _firestore = firestore,
        super([]);

  Future<void> loadForUser({required String? uid, required bool isPremium}) async {
    if (uid == null || uid.isEmpty || !isPremium) return;
    if (_syncedUid == uid) return;
    _syncedUid = uid;

    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await fs
          .collection('users')
          .doc(uid)
          .collection('regional_work_logs')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final loaded = snapshot.docs
            .map((doc) => RegionalJobEntry.fromJson(doc.data()))
            .toList();
        state = loaded;
      }
    } catch (_) {
      // Offline fallback
    }
  }

  Future<void> addJob(RegionalJobEntry job, {String? uid, bool isPremium = false}) async {
    state = [...state, job];

    if (isPremium && uid != null && uid.isNotEmpty) {
      try {
        final fs = _firestore ?? FirebaseFirestore.instance;
        await fs
            .collection('users')
            .doc(uid)
            .collection('regional_work_logs')
            .doc(job.id)
            .set(job.toJson());
      } catch (_) {}
    }
  }

  Future<void> removeJob(String id, {String? uid, bool isPremium = false}) async {
    state = state.where((j) => j.id != id).toList();

    if (isPremium && uid != null && uid.isNotEmpty) {
      try {
        final fs = _firestore ?? FirebaseFirestore.instance;
        await fs
            .collection('users')
            .doc(uid)
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
