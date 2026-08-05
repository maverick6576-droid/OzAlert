import '../models/user_profile.dart';

abstract class UserRepository {
  /// Obtiene el perfil del usuario desde la base de datos
  Future<UserProfile?> getUserProfile(String uid);

  /// Actualiza o crea el perfil del usuario
  Future<void> saveUserProfile(UserProfile profile);
}
