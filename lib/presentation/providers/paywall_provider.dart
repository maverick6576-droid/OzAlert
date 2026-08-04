import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repository_providers.dart';

class PaywallNotifier extends StateNotifier<bool> {
  final Ref ref;

  PaywallNotifier(this.ref) : super(false) {
    checkSubscriptionStatus();
  }

  Future<void> checkSubscriptionStatus() async {
    final repo = ref.read(paywallRepositoryProvider);
    final active = await repo.isUserSubscribed();
    state = active;
  }

  Future<bool> subscribeMonthly() async {
    final repo = ref.read(paywallRepositoryProvider);
    final success = await repo.purchaseMonthlyPlan();
    if (success) state = true;
    return success;
  }

  Future<bool> subscribeAnnual() async {
    final repo = ref.read(paywallRepositoryProvider);
    final success = await repo.purchaseAnnualPlan();
    if (success) state = true;
    return success;
  }

  Future<bool> restorePurchases() async {
    final repo = ref.read(paywallRepositoryProvider);
    final active = await repo.restorePurchases();
    state = active;
    return active;
  }

  Future<void> setDemoSubscribed(bool sub) async {
    final repo = ref.read(paywallRepositoryProvider);
    await repo.setDemoSubscription(sub);
    state = sub;
  }
}

final paywallProvider = StateNotifierProvider<PaywallNotifier, bool>((ref) {
  return PaywallNotifier(ref);
});
