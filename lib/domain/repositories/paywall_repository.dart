abstract class PaywallRepository {
  Future<void> initRevenueCat(String apiKey);
  Future<bool> isUserSubscribed();
  Future<bool> purchaseMonthlyPlan();
  Future<bool> purchaseAnnualPlan();
  Future<bool> restorePurchases();
  Future<void> setDemoSubscription(bool isSubscribed);
}
