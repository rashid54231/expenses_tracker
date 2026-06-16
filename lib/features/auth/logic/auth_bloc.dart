import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// States (Same as before)
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthAuthenticated extends AuthState { final User user; AuthAuthenticated(this.user); }
class AuthUnauthenticated extends AuthState {}
class AuthFailure extends AuthState { final String error; AuthFailure(this.error); }
class AuthResetPasswordSuccess extends AuthState { final String message; AuthResetPasswordSuccess(this.message); }
class AuthResetPasswordVerifySuccess extends AuthState { final String message; AuthResetPasswordVerifySuccess(this.message); }

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final _supabase = Supabase.instance.client;

  AuthCubit(this._repository) : super(AuthInitial());

  // 1. Check Auth Status with Logs
  void checkAuthStatus() {
    print("DEBUG: Checking current auth status...");
    final session = _supabase.auth.currentSession;

    if (session != null && session.user != null) {
      print("DEBUG: User found in session: ${session.user!.email}");
      emit(AuthAuthenticated(session.user!));
    } else {
      print("DEBUG: No active session found.");
      emit(AuthUnauthenticated());
    }
  }

  // 2. Login Logic with Logs
  Future<void> login(String email, String password) async {
    print("DEBUG: Attempting login for: $email");
    emit(AuthLoading());
    try {
      await _repository.signIn(email, password);
      final user = _supabase.auth.currentUser;

      if (user != null) {
        print("DEBUG: Login Successful! User ID: ${user.id}");
        emit(AuthAuthenticated(user));
      } else {
        print("DEBUG: Login response received but user is null.");
        emit(AuthSuccess());
      }
    } catch (e) {
      print("DEBUG ERROR (Login): ${e.toString()}");
      emit(AuthFailure(e.toString()));
    }
  }

  // 3. Register Logic with Logs (Most Important for you right now)
  Future<void> register(String email, String password) async {
    print("DEBUG: Starting registration for: $email");
    emit(AuthLoading());
    try {
      final response = await _repository.signUp(email, password);

      print("DEBUG: Supabase signup response received.");
      print("DEBUG: User created: ${response.user?.email}");
      print("DEBUG: Confirmation status: ${response.session == null ? 'Pending Email Confirmation' : 'Auto-confirmed'}");

      // Agar foran login ho jaye to session mil jayega
      if (response.session != null) {
        print("DEBUG: Signup & Auto-login Successful.");
        emit(AuthAuthenticated(response.user!));
      } else {
        print("DEBUG: Signup Success - Waiting for login or confirmation.");
        emit(AuthSuccess());
      }
    } catch (e) {
      print("DEBUG ERROR (Signup): ${e.toString()}");
      emit(AuthFailure(e.toString()));
    }
  }

  // 4. Logout Logic with Logs
  Future<void> logout() async {
    print("DEBUG: Logging out user...");
    try {
      await _repository.signOut();
      print("DEBUG: User logged out successfully.");
      emit(AuthUnauthenticated());
    } catch (e) {
      print("DEBUG ERROR (Logout): ${e.toString()}");
    }
  }

  // 5. Send Password Reset Email with Logs
  Future<void> sendPasswordResetEmail(String email) async {
    print("DEBUG: Requesting password reset email for: $email");
    emit(AuthLoading());
    try {
      await _repository.resetPassword(email);
      print("DEBUG: Password reset email sent successfully.");
      emit(AuthResetPasswordSuccess("OTP code has been sent to your email."));
    } catch (e) {
      print("DEBUG ERROR (Reset Password): ${e.toString()}");
      emit(AuthFailure(e.toString()));
    }
  }

  // 6. Verify OTP and Update Password with Logs
  Future<void> verifyOTPAndResetPassword(String email, String token, String newPassword) async {
    print("DEBUG: Verifying OTP and updating password for: $email");
    emit(AuthLoading());
    try {
      await _repository.verifyOTPAndResetPassword(email, token, newPassword);
      print("DEBUG: Password updated successfully.");
      emit(AuthResetPasswordVerifySuccess("Password updated successfully. Please login with your new password."));
    } catch (e) {
      print("DEBUG ERROR (Verify OTP & Reset Password): ${e.toString()}");
      emit(AuthFailure(e.toString()));
    }
  }
}