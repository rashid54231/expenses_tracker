import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/biometric_service.dart';
import '../../auth/ui/login_screen.dart';
import '../../dashboard/ui/home_wrapper.dart';
import '../../onboarding/ui/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    // Wait for the animation to play beautifully
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      // First time user -> Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      // Check auth state
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Logged in -> Prompt Biometrics
        _promptBiometric();
      } else {
        // Not logged in -> Login Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _promptBiometric() async {
    final canCheck = await BiometricService.isBiometricAvailable();
    if (canCheck) {
      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeWrapper()),
        );
      } else {
        // User cancelled or failed. Show a retry button on splash.
        if (mounted) {
          setState(() {
            _showRetryButton = true;
          });
        }
      }
    } else {
      // Biometrics not available, just proceed
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A), // Deep Navy
              Color(0xFF1B2A3B), // Navy lighter
              Color(0xFF0D1B2A), // Deep Navy
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0072FF).withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 800.ms)
                  .then(delay: 200.ms)
                  .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 30),
              // App Name Text
              const Text(
                "Expense Tracker",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                "Manage your wealth smartly",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.6),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 800.ms),
              if (_showRetryButton)
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: ElevatedButton.icon(
                    onPressed: _promptBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text("Unlock App"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0072FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
//