import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/country_config.dart';
import '../../core/constants/app_constants.dart';
import 'repository_providers.dart';

class SelectedPassportNotifier extends StateNotifier<CountryConfig> {
  final Ref ref;

  SelectedPassportNotifier(this.ref)
    : super(AppConstants.supportedCountries.first) {
    _loadInitialPassport();
  }

  Future<void> _loadInitialPassport() async {
    final prefs = ref.read(sharedPrefsServiceProvider);
    final savedCode = await prefs.getSelectedCountryCode();
    final match = AppConstants.supportedCountries.firstWhere(
      (c) => c.code == savedCode,
      orElse: () => AppConstants.supportedCountries.first,
    );
    state = match;
  }

  Future<void> selectPassport(String countryCode) async {
    final match = AppConstants.supportedCountries.firstWhere(
      (c) => c.code == countryCode,
      orElse: () => state,
    );
    state = match;

    final repo = ref.read(visaRepositoryProvider);
    await repo.saveUserCountryPreference(
      uid: 'demo_user_id',
      countryCode: countryCode,
    );
  }
}

final selectedPassportProvider =
    StateNotifierProvider<SelectedPassportNotifier, CountryConfig>((ref) {
      return SelectedPassportNotifier(ref);
    });

/// Stream provider en tiempo real que emite "OPEN" o "CLOSED" del pasaporte seleccionado
final visaStatusStreamProvider = StreamProvider<String>((ref) {
  final selectedCountry = ref.watch(selectedPassportProvider);
  final visaRepo = ref.watch(visaRepositoryProvider);
  return visaRepo.watchVisaStatus(selectedCountry.code);
});
