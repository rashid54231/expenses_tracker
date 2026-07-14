import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc.dart';
import '../data/auth_repository.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Design tokens
  static const Color _bg = Color(0xFF0A0A0F);
  static const Color _surface = Color(0xFF13131A);
  static const Color _surfaceHigh = Color(0xFF1C1C27);
  static const Color _accent = Color(0xFFB8A9FF);
  static const Color _accentGlow = Color(0xFF7C6AE8);
  static const Color _textPrimary = Color(0xFFF0EEF9);
  static const Color _textSecondary = Color(0xFF7A7890);
  static const Color _borderDefault = Color(0xFF252535);
  static const Color _borderFocused = Color(0xFF7C6AE8);

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
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Color(0xFFB8A9FF), size: 18),
                      SizedBox(width: 10),
                      Text(
                        "Account created! Please login.",
                        style: TextStyle(color: Colors.white, fontFamily: 'Georgia'),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF1C1C27),
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
                      const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        state.error,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Georgia'),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF2A1A1A),
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
                // ── Ambient background glow ──────────────────────────────
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

                // ── Main content ─────────────────────────────────────────
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // ── Back button ───────────────────────────
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _surfaceHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _borderDefault),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: _textSecondary,
                                    size: 16,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 52),

                              // ── Monogram badge ────────────────────────
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF9B8AF0), Color(0xFF6A5AE0)],
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
                                child: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ── Headlines ─────────────────────────────
                              const Text(
                                "Create your\naccount",
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                  fontFamily: 'Georgia',
                                  height: 1.18,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Start your journey with us today.",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _textSecondary,
                                  fontFamily: 'Georgia',
                                  letterSpacing: 0.1,
                                ),
                              ),

                              const SizedBox(height: 48),

                              // ── Email field ───────────────────────────
                              _buildLabel("Email address"),
                              const SizedBox(height: 8),
                              Focus(
                                onFocusChange: (v) => setState(() => _emailFocused = v),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _surface,
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
                                        spreadRadius: 0,
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
                                      fontFamily: 'Georgia',
                                    ),
                                    decoration: InputDecoration(
                                      filled: false,
                                      hintText: "you@example.com",
                                      hintStyle: TextStyle(
                                        color: _textSecondary.withOpacity(0.6),
                                        fontFamily: 'Georgia',
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                        color: _emailFocused ? _accent : _textSecondary,
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

                              // ── Password field ────────────────────────
                              _buildLabel("Password"),
                              const SizedBox(height: 8),
                              Focus(
                                onFocusChange: (v) => setState(() => _passwordFocused = v),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _surface,
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
                                        spreadRadius: 0,
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
                                      fontFamily: 'Georgia',
                                      letterSpacing: 1.5,
                                    ),
                                    decoration: InputDecoration(
                                      filled: false,
                                      hintText: "Min. 8 characters",
                                      hintStyle: TextStyle(
                                        color: _textSecondary.withOpacity(0.6),
                                        fontFamily: 'Georgia',
                                        fontSize: 14,
                                        letterSpacing: 0,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: _passwordFocused ? _accent : _textSecondary,
                                        size: 20,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(
                                                () => _obscurePassword = !_obscurePassword),
                                        child: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _textSecondary,
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

                              const SizedBox(height: 12),

                              // ── Password hint ─────────────────────────
                              Row(
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      size: 13, color: _textSecondary.withOpacity(0.6)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Use letters, numbers & special characters.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textSecondary.withOpacity(0.6),
                                      fontFamily: 'Georgia',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 44),

                              // ── Sign Up button ────────────────────────
                              state is AuthLoading
                                  ? Center(
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
                                onTap: () => context
                                    .read<AuthCubit>()
                                    .register(emailController.text,
                                    passwordController.text),
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9B8AF0),
                                        Color(0xFF6A5AE0),
                                      ],
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
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Create Account",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Georgia',
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_forward_rounded,
                                          color: Colors.white, size: 18),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ── Divider ───────────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                        color: _borderDefault, thickness: 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Text(
                                      "or continue with",
                                      style: TextStyle(
                                        color: _textSecondary.withOpacity(0.7),
                                        fontSize: 12,
                                        fontFamily: 'Georgia',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                        color: _borderDefault, thickness: 1),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // ── Social buttons ────────────────────────
                              Row(
                                children: [
                                  Expanded(child: _socialButton("Google", Icons.g_mobiledata_rounded)),
                                  const SizedBox(width: 14),
                                  Expanded(child: _socialButton("Apple", Icons.apple_rounded)),
                                ],
                              ),

                              const SizedBox(height: 36),

                              // ── Login link ────────────────────────────
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: RichText(
                                    text: const TextSpan(
                                      text: "Already have an account?  ",
                                      style: TextStyle(
                                        color: _textSecondary,
                                        fontSize: 14,
                                        fontFamily: 'Georgia',
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Sign In",
                                          style: TextStyle(
                                            color: _accent,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                            decorationColor: _accent,
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
      style: const TextStyle(
        color: _textSecondary,
        fontSize: 13,
        fontFamily: 'Georgia',
        letterSpacing: 0.3,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _socialButton(String label, IconData icon) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _textSecondary, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}