import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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

/// Tracker de empleos regionales (88 Días)
class RegionalJobsNotifier extends StateNotifier<List<RegionalJobEntry>> {
  RegionalJobsNotifier() : super([]);

  void addJob(RegionalJobEntry job) {
    state = [...state, job];
  }

  void removeJob(String id) {
    state = state.where((j) => j.id != id).toList();
  }

  int get totalDaysAccumulated {
    return state.fold(0, (sum, j) => sum + j.totalDaysCounted);
  }
}

final regionalJobsProvider = StateNotifierProvider<RegionalJobsNotifier, List<RegionalJobEntry>>((ref) {
  return RegionalJobsNotifier();
});
