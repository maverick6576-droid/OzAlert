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
    final user = ref.read(authStateProvider).value;
    
    // 1. VIP Override: Si es el administrador, dejarle pasar siempre gratis.
    final vipEmails = ['maverick6576@gmail.com', 'juditmaynou2000@gmail.com'];
    if (user != null && user.email != null && vipEmails.contains(user.email)) {
      await _updateFirebasePremiumStatus(true);
      state = true;
      return;
    }

    // 2. Flujo normal para el resto del mundo
    final repo = ref.read(paywallRepositoryProvider);
    final active = await repo.isUserSubscribed();
    
    if (active != null) {
      // 3. ACTUALIZAR FIREBASE SOLO SI NO HUBO ERROR DE RED
      await _updateFirebasePremiumStatus(active);
      state = active;
    } else {
      // Si RevenueCat falla (ej. Modo Avion), bloqueamos el acceso local pero NO quitamos el Premium en Firebase
      state = false;
    }
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

final monthlyPriceProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(paywallRepositoryProvider);
  return await repo.getMonthlyPriceString();
});
