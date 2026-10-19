import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

class PaywallNotifier extends StateNotifier<bool> {
  final Ref ref;
  static const List<String> _vipEmails = [
    'maverick6576@gmail.com',
    'juditmaynou2000@gmail.com',
  ];

  PaywallNotifier(this.ref) : super(false) {
    checkSubscriptionStatus();

    // Re-evaluar suscripción y canales FCM cuando cambia el usuario autenticado
    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null) {
        checkSubscriptionStatus();
      } else {
        state = false;
        NotificationService().setPremiumStatus(false);
        NotificationService().syncPassportSubscriptions([]);
      }
    });

    // Escuchar cambios en tiempo real de RevenueCat (renovación, alta o baja de suscripción)
    ref.read(paywallRepositoryProvider).addSubscriptionStatusListener((isActive) async {
      final user = ref.read(authStateProvider).value;
      if (user != null && user.email != null && _vipEmails.contains(user.email)) {
        await _updateFirebasePremiumStatus(true);
        state = true;
        return;
      }
      await _updateFirebasePremiumStatus(isActive);
      state = isActive;
    });
  }

  Future<void> checkSubscriptionStatus() async {
    final user = ref.read(authStateProvider).value;
    
    // 1. VIP Override: Si es el administrador, dejarle pasar siempre gratis.
    if (user != null && user.email != null && _vipEmails.contains(user.email)) {
      await _updateFirebasePremiumStatus(true);
      state = true;
      return;
    }

    // 2. Flujo normal para el resto del mundo
    final repo = ref.read(paywallRepositoryProvider);
    final active = await repo.isUserSubscribed();
    
    if (active != null) {
      // 3. ACTUALIZAR FIREBASE Y CANALES FCM EN AMBOS CASOS (Activo o Cancelado)
      await _updateFirebasePremiumStatus(active);
      state = active;
    } else {
      // Si RevenueCat falla (ej. Modo Avión), bloqueamos el acceso local pero NO quitamos el Premium en Firebase
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
    await _updateFirebasePremiumStatus(active);
    state = active;
    return active;
  }

  Future<void> setDemoSubscribed(bool sub) async {
    final repo = ref.read(paywallRepositoryProvider);
    await repo.setDemoSubscription(sub);
    await _updateFirebasePremiumStatus(sub);
    state = sub;
  }

  Future<void> _updateFirebasePremiumStatus(bool isPremium) async {
    await NotificationService().setPremiumStatus(isPremium);
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final userRepo = ref.read(userRepositoryProvider);
      final profile = await userRepo.getUserProfile(user.uid);
      if (profile != null) {
        if (profile.isPremium != isPremium) {
          await userRepo.saveUserProfile(profile.copyWith(isPremium: isPremium));
        }
        final countryCodes = profile.passports.map((pName) {
          return AppConstants.supportedCountries.firstWhere(
            (c) => c.name == pName,
            orElse: () => AppConstants.supportedCountries.first,
          ).code;
        }).toList();

        // Suscribir al canal de notificaciones al hacerse Premium (en Fase 1) y quitar del canal al dejar de pagar
        if (isPremium && profile.currentPhase == 1) {
          await NotificationService().syncPassportSubscriptions(countryCodes);
        } else {
          await NotificationService().syncPassportSubscriptions([]);
        }
        return;
      }
    }
    if (!isPremium) {
      await NotificationService().syncPassportSubscriptions([]);
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
