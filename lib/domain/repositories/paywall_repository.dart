abstract class PaywallRepository {
  Future<void> initRevenueCat(String apiKey);
  Future<bool> isUserSubscribed();
  Future<bool> purchaseMonthlyPlan();
  Future<bool> purchaseAnnualPlan();
  Future<bool> restorePurchases();
  Future<String?> getMonthlyPriceString();
  Future<void> setDemoSubscription(bool isSubscribed);
}
