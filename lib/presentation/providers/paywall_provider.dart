import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

class PaywallNotifier extends StateNotifier<bool> {
  final Ref ref;

  PaywallNotifier(this.ref) : super(false) {
    checkSubscriptionStatus();
  }

  Future<void> checkSubscriptionStatus() async {
    final repo = ref.read(paywallRepositoryProvider);
    final active = await repo.isUserSubscribed();
    if (active) await _updateFirebasePremiumStatus(true);
    state = active;
  }

  Future<bool> subscribeMonthly() async {
    final repo = ref.read(paywallRepositoryProvider);
    final success = await repo.purchaseMonthlyPlan();
    if (success) {
      await _updateFirebasePremiumStatus(true);
      state = true;
    }
    return success;
  }

  Future<bool> subscribeAnnual() async {
    final repo = ref.read(paywallRepositoryProvider);
    final success = await repo.purchaseAnnualPlan();
    if (success) {
      await _updateFirebasePremiumStatus(true);
      state = true;
    }
    return success;
  }

  Future<bool> restorePurchases() async {
    final repo = ref.read(paywallRepositoryProvider);
    final active = await repo.restorePurchases();
    if (active) {
      await _updateFirebasePremiumStatus(true);
      state = true;
    }
    return active;
  }

  Future<void> setDemoSubscribed(bool sub) async {
    final repo = ref.read(paywallRepositoryProvider);
    await repo.setDemoSubscription(sub);
    if (sub) {
      await _updateFirebasePremiumStatus(true);
    }
    state = sub;
  }

  Future<void> _updateFirebasePremiumStatus(bool isPremium) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final userRepo = ref.read(userRepositoryProvider);
      final profile = await userRepo.getUserProfile(user.uid);
      if (profile != null) {
        await userRepo.saveUserProfile(profile.copyWith(isPremium: isPremium));
      }
    }
  }
}

final paywallProvider = StateNotifierProvider<PaywallNotifier, bool>((ref) {
  return PaywallNotifier(ref);
});
