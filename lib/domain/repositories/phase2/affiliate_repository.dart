import '../../models/phase2/affiliate_partner.dart';

abstract class AffiliateRepository {
  Future<void> init();
  List<AffiliatePartner> getPartnersByCategory(String category);
  List<AffiliatePartner> getAllPartners();
}
