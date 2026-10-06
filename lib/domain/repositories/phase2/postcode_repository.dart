import '../../models/phase2/postcode_info.dart';

abstract class PostcodeRepository {
  Future<void> init();
  PostcodeInfo? findPostcode(String code);
  List<PostcodeInfo> getAllPostcodes();
}
