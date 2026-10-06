import '../../models/phase2/guide_data.dart';

abstract class GuideRepository {
  Future<CategoryGuide?> getGuideForCategory(String categoryId);
}
