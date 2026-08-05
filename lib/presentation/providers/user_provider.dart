import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import 'auth_provider.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(firestoreProvider));
});

// StreamProvider para obtener el perfil del usuario actual
final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final authState = ref.watch(authStateProvider);
  
  final user = authState.value;
  if (user == null) {
    yield null;
    return;
  }

  // Stream directo desde Firestore
  yield* ref.watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (doc.exists && doc.data() != null) {
          return UserProfile.fromMap(doc.data()!, user.uid);
        }
        return null;
      });
});

class OnboardingController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> completeOnboarding(String language, List<String> passports) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Usuario no autenticado');

      final profile = UserProfile(
        uid: user.uid,
        language: language,
        passports: passports,
        onboardingCompleted: true,
      );

      await ref.read(userRepositoryProvider).saveUserProfile(profile);
    });
  }
}

final onboardingControllerProvider = AutoDisposeAsyncNotifierProvider<OnboardingController, void>(() {
  return OnboardingController();
});
