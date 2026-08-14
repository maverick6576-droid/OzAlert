import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  /// Devuelve el usuario actual, si lo hay.
  User? get currentUser;

  /// Emite cambios en el estado de autenticación.
  Stream<User?> get authStateChanges;

  /// Iniciar sesión con Google.
  Future<UserCredential> signInWithGoogle();

  /// Iniciar sesión con Apple.
  Future<UserCredential> signInWithApple();

  /// Iniciar sesión como Invitado (Anónimo - temporal para debug).
  Future<UserCredential> signInAnonymously();

  /// Cerrar sesión.
  Future<void> signOut();

  /// Eliminar cuenta permanentemente.
  Future<void> deleteAccount();
}
