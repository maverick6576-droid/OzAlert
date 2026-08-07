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
      debugPrint('Error en compra mensual: $e');
      if (kDebugMode) {
        _isDemoSubscribed = true;
        return true;
      }
      return false;
    }
    if (kDebugMode) {
      _isDemoSubscribed = true;
      return true;
    }
    return false;
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
      debugPrint('Error en compra anual: $e');
      if (kDebugMode) {
        _isDemoSubscribed = true;
        return true;
      }
      return false;
    }
    if (kDebugMode) {
      _isDemoSubscribed = true;
      return true;
    }
    return false;
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

  @override
  Future<String?> getMonthlyPriceString() async {
    try {
      final offerings = await Purchases.getOfferings();
      final monthly = offerings.current?.monthly;
      if (monthly != null) {
        return monthly.storeProduct.priceString;
      }
    } catch (e) {
      debugPrint('Error obteniendo precio: $e');
    }
    return null;
  }
}
