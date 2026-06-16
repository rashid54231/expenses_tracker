import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _client = Supabase.instance.client;

  // 1. SIGN UP (Naya Account Banana)
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        // Optional: Agar aap user ka naam save karna chahte hain to yahan data bhej sakte hain
        data: {'display_name': email.split('@')[0]},
      );
      return response;
    } on AuthException catch (e) {
      // Supabase ke specific errors (e.g. Email already exists)
      throw e.message;
    } catch (e) {
      throw "An unexpected error occurred during signup.";
    }
  }

  // 2. SIGN IN (Login Karna)
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
          email: email,
          password: password
      );
      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw "Login failed. Please check your internet.";
    }
  }

  // 3. SIGN OUT (Logout Karna)
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw "Logout failed.";
    }
  }

  // 4. GET CURRENT USER (Check karna ke user logged in hai ya nahi)
  User? get currentUser => _client.auth.currentUser;

  // 5. SESSION STREAM (App ko real-time batana ke user login hai ya nahi)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // 6. RESET PASSWORD (Password reset email bhejna using OTP)
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw "An unexpected error occurred. Please try again.";
    }
  }

  // 7. VERIFY OTP AND RESET PASSWORD
  Future<void> verifyOTPAndResetPassword(String email, String token, String newPassword) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw "An unexpected error occurred. Please try again.";
    }
  }
}