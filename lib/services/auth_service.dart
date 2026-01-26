import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== INSCRIPTION =====
  Future<User?> registerWithEmail(
      String email, String password) async {
    try {
      final userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Erreur inscription';
    }
  }

  // ===== CONNEXION =====
  Future<User?> loginWithEmail(
      String email, String password) async {
    try {
      final userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Erreur connexion';
    }
  }

  // ===== DÉCONNEXION =====
  Future<void> logout() async {
    await _auth.signOut();
  }
}
