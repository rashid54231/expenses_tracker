import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc.dart';
import '../data/auth_repository.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../dashboard/ui/home_wrapper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            // FIX: Donon success states ko listen karna zaroori hai
            if (state is AuthSuccess || state is AuthAuthenticated) {
              print("DEBUG: Navigation triggered to HomeWrapper");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeWrapper()),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(state.error)),
                    ],
                  ),
                  backgroundColor: const Color(0xFFE53935),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B2A3B),
                    Color(0xFF0D1B2A),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative background circles
                  Positioned(
                    top: -80,
                    right: -60,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00C6FF).withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -80,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF0072FF).withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Main content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),

                              // Logo area
                              Center(
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0072FF).withOpacity(0.45),
                                        blurRadius: 28,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Heading
                              const Center(
                                child: Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  "Sign in to continue",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.45),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 44),

                              // Email field
                              _buildLabel("Email Address"),
                              const SizedBox(height: 8),
                              _GlassTextField(
                                controller: emailController,
                                hint: "you@example.com",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 20),

                              // Password field
                              _buildLabel("Password"),
                              const SizedBox(height: 8),
                              _GlassTextField(
                                controller: passwordController,
                                hint: "••••••••",
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),

                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Color(0xFF00C6FF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Login button
                              state is AuthLoading
                                  ? Center(
                                child: Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0072FF).withOpacity(0.4),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              )
                                  : Container(
                                width: double.infinity,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0072FF).withOpacity(0.45),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () {
                                    final email = emailController.text.trim();
                                    final password = passwordController.text.trim();

                                    if (email.isNotEmpty && password.isNotEmpty) {
                                      print("DEBUG: Calling Cubit Login for $email");
                                      context.read<AuthCubit>().login(email, password);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.white, size: 20),
                                              SizedBox(width: 10),
                                              Text("Please fill all fields"),
                                            ],
                                          ),
                                          backgroundColor: const Color(0xFF1565C0),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.12),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Text(
                                      "or",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.12),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Sign up link
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SignupScreen()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.12),
                                        width: 1,
                                      ),
                                    ),
                                    backgroundColor: Colors.white.withOpacity(0.04),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: "Don't have an account? ",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.45),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: "Sign Up",
                                          style: TextStyle(
                                            color: Color(0xFF00C6FF),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
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
                ],
              ),
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
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.55),
        letterSpacing: 0.6,
      ),
    );
  }
}

class _GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _GlassTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<_GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<_GlassTextField> {
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(
            color: _isFocused
                ? const Color(0xFF00C6FF).withOpacity(0.7)
                : Colors.white.withOpacity(0.1),
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow: _isFocused
              ? [
            BoxShadow(
              color: const Color(0xFF00C6FF).withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText ? _obscureText : false,
          keyboardType: widget.keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused
                  ? const Color(0xFF00C6FF)
                  : Colors.white.withOpacity(0.35),
              size: 20,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.35),
                size: 20,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
      ),
    );
  }
}