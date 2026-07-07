import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc.dart';
import '../data/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();

  bool _emailFocused = false;
  bool _otpFocused = false;
  bool _passwordFocused = false;
  bool _otpSent = false;
  bool _obscurePassword = true;

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Design tokens aligned with login/signup style
  static const Color _bg = Color(0xFF0D1B2A);
  static const Color _surface = Color(0xFF1B2A3B);
  static const Color _surfaceHigh = Color(0xFF243B55);
  static const Color _accent = Color(0xFF00C6FF);
  static const Color _accentGlow = Color(0xFF0072FF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0x99FFFFFF);
  static const Color _borderDefault = Color(0x1AFFFFFF);
  static const Color _borderFocused = Color(0xB300C6FF);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: Scaffold(
        backgroundColor: _bg,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthResetPasswordSuccess) {
              setState(() {
                _otpSent = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF2E7D32),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            } else if (state is AuthResetPasswordVerifySuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF2E7D32),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
              Navigator.pop(context);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.error,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFFD32F2F),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                // Ambient background glows
                Positioned(
                  top: -120,
                  left: -80,
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _accentGlow.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  right: -100,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _accentGlow.withOpacity(0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // Back button
                              GestureDetector(
                                onTap: () {
                                  if (_otpSent) {
                                    setState(() {
                                      _otpSent = false;
                                    });
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _borderDefault),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 52),

                              // Icon Badge
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_accent, _accentGlow],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _accentGlow.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _otpSent ? Icons.vpn_key_rounded : Icons.lock_reset_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Headline
                              Text(
                                _otpSent ? "Reset your\npassword" : "Forgot your\npassword?",
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                  height: 1.18,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                _otpSent
                                    ? "We have sent a 6-digit OTP code to ${emailController.text}. Enter the OTP code and set your new password below."
                                    : "Enter your email address to receive a 6-digit OTP code to reset your password.",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: _textSecondary,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 36),

                              if (!_otpSent) ...[
                                // Step 1: Request OTP (Email Address)
                                _buildLabel("Email Address"),
                                const SizedBox(height: 8),
                                Focus(
                                  onFocusChange: (v) => setState(() => _emailFocused = v),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _emailFocused ? _borderFocused : _borderDefault,
                                        width: _emailFocused ? 1.5 : 1,
                                      ),
                                      boxShadow: _emailFocused
                                          ? [
                                              BoxShadow(
                                                color: _accentGlow.withOpacity(0.15),
                                                blurRadius: 16,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: TextField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(
                                        color: _textPrimary,
                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "you@example.com",
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.25),
                                          fontSize: 14,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.mail_outline_rounded,
                                          color: _emailFocused ? _accent : Colors.white.withOpacity(0.35),
                                          size: 20,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 36),
                              ] else ...[
                                // Step 2: Enter OTP and New Password
                                _buildLabel("OTP / Reset Code"),
                                const SizedBox(height: 8),
                                Focus(
                                  onFocusChange: (v) => setState(() => _otpFocused = v),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _otpFocused ? _borderFocused : _borderDefault,
                                        width: _otpFocused ? 1.5 : 1,
                                      ),
                                      boxShadow: _otpFocused
                                          ? [
                                              BoxShadow(
                                                color: _accentGlow.withOpacity(0.15),
                                                blurRadius: 16,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: TextField(
                                      controller: otpController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        color: _textPrimary,
                                        fontSize: 15,
                                        letterSpacing: 2.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "123456",
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.25),
                                          fontSize: 14,
                                          letterSpacing: 0.0,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.pin_rounded,
                                          color: _otpFocused ? _accent : Colors.white.withOpacity(0.35),
                                          size: 20,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                _buildLabel("New Password"),
                                const SizedBox(height: 8),
                                Focus(
                                  onFocusChange: (v) => setState(() => _passwordFocused = v),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _passwordFocused ? _borderFocused : _borderDefault,
                                        width: _passwordFocused ? 1.5 : 1,
                                      ),
                                      boxShadow: _passwordFocused
                                          ? [
                                              BoxShadow(
                                                color: _accentGlow.withOpacity(0.15),
                                                blurRadius: 16,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(
                                        color: _textPrimary,
                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "••••••••",
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.25),
                                          fontSize: 14,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline_rounded,
                                          color: _passwordFocused ? _accent : Colors.white.withOpacity(0.35),
                                          size: 20,
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () => setState(
                                              () => _obscurePassword = !_obscurePassword),
                                          child: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.white.withOpacity(0.35),
                                            size: 20,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 36),
                              ],

                              // Action Button
                              state is AuthLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation(_accent),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        if (!_otpSent) {
                                          final email = emailController.text.trim();
                                          if (email.isNotEmpty) {
                                            context.read<AuthCubit>().sendPasswordResetEmail(email);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Please enter your email address"),
                                                backgroundColor: Color(0xFF1565C0),
                                              ),
                                            );
                                          }
                                        } else {
                                          final email = emailController.text.trim();
                                          final token = otpController.text.trim();
                                          final newPassword = passwordController.text.trim();

                                          if (token.isNotEmpty && newPassword.isNotEmpty) {
                                            if (newPassword.length < 6) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Password must be at least 6 characters"),
                                                  backgroundColor: Color(0xFFD32F2F),
                                                ),
                                              );
                                              return;
                                            }
                                            context.read<AuthCubit>().verifyOTPAndResetPassword(
                                                  email,
                                                  token,
                                                  newPassword,
                                                );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Please fill all fields"),
                                                backgroundColor: Color(0xFF1565C0),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [_accent, _accentGlow],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _accentGlow.withOpacity(0.45),
                                              blurRadius: 24,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _otpSent ? "Change Password" : "Send OTP Code",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(_otpSent ? Icons.check_circle_outline : Icons.send_rounded,
                                                color: Colors.white, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.55),
        fontSize: 13,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
