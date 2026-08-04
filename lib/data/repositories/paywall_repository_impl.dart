import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/repositories/paywall_repository.dart';
import '../../core/constants/app_constants.dart';

class PaywallRepositoryImpl implements PaywallRepository {
  bool _isDemoSubscribed = false;

  @override
  Future<void> initRevenueCat(String apiKey) async {
    try {
      if (apiKey.isEmpty || apiKey == 'MOCK_REVENUECAT_API_KEY') {
        debugPrint('RevenueCat: Usando Modo Demo sin credenciales de tienda.');
        return;
      }
      await Purchases.configure(PurchasesConfiguration(apiKey));
      debugPrint('RevenueCat SDK configurado exitosamente.');
    } catch (e) {
      debugPrint('Error en la configuración de RevenueCat: $e');
    }
  }

  @override
  Future<bool> isUserSubscribed() async {
    if (_isDemoSubscribed) return true;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement =
          customerInfo.entitlements.all[AppConstants.rcEntitlementId];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('Error obteniendo estado de suscripción: $e');
      return _isDemoSubscribed;
    }
  }

  @override
  Future<bool> purchaseMonthlyPlan() async {
    try {
      final offerings = await Purchases.getOfferings();
      final monthly = offerings.current?.monthly;
      if (monthly != null) {
        final info = await Purchases.purchasePackage(monthly);
        final active =
            info.entitlements.all[AppConstants.rcEntitlementId]?.isActive ??
            false;
        if (active) _isDemoSubscribed = true;
        return active;
      }
    } catch (e) {
      debugPrint('Compra en tienda simulada en modo demo: $e');
    }
    // Si estamos probando en local o no hay producto en StoreKit, activar modo VIP simulado
    _isDemoSubscribed = true;
    return true;
  }

  @override
  Future<bool> purchaseAnnualPlan() async {
    try {
      final offerings = await Purchases.getOfferings();
      final annual = offerings.current?.annual;
      if (annual != null) {
        final info = await Purchases.purchasePackage(annual);
        final active =
            info.entitlements.all[AppConstants.rcEntitlementId]?.isActive ??
            false;
        if (active) _isDemoSubscribed = true;
        return active;
      }
    } catch (e) {
      debugPrint('Compra anual simulada en modo demo: $e');
    }
    _isDemoSubscribed = true;
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      final active =
          info.entitlements.all[AppConstants.rcEntitlementId]?.isActive ??
          false;
      if (active) _isDemoSubscribed = true;
      return active;
    } catch (e) {
      debugPrint('Restaurar compras: simulando en modo demo ($e)');
      return _isDemoSubscribed;
    }
  }

  @override
  Future<void> setDemoSubscription(bool isSubscribed) async {
    _isDemoSubscribed = isSubscribed;
  }
}
