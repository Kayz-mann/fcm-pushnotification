import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create account with email and password
  static Future<String> createAccountWithEmail(
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Email and password cannot be empty";
      }

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  // Login with email and password
  static Future<String> loginWithEmail(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Email and password cannot be empty";
      }

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: ${e.toString()}');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final user = _auth.currentUser;
      return user != null;
    } catch (e) {
      print('Error checking login status: ${e.toString()}');
      return false;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
