import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/widgets/liquid_wave_painter.dart';
import 'package:fintech_app/screens/splash/welcome_onboarding_screen.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _logoController;
  late Animation<double> _waveAnimation;
  late Animation<double> _logoFallAnimation;
  late Animation<double> _logoWaveAnimation;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Epic wave animation (3.5 seconds - longer for full sweep)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Logo greeting animation (2.5 seconds - longer display)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Wave rises smoothly
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOutCubic),
    );

    // Logo falls down (greeting) - stays longer
    _logoFallAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -200.0, end: 30.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 30.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 50, // Logo stays visible longer
      ),
    ]).animate(_logoController);

    // Logo waves (like greeting hand) - starts later
    _logoWaveAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 20, // Stay still after wave
      ),
    ]).animate(_logoController);

    // Logo stays visible - swept away by wave naturally
    _logoFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 100, // Always visible until wave sweeps
      ),
    ]).animate(_logoController);

    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation first
    _logoController.forward();
    
    // Start wave animation after logo greeting (longer delay)
    await Future.delayed(const Duration(milliseconds: 1500));
    _waveController.forward();
    
    // Wait for wave to sweep entire screen
    await Future.delayed(const Duration(milliseconds: 3200));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WelcomeOnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Stack(
        children: [
          // Logo BEHIND the wave (rendered first)
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _logoFallAnimation.value),
                    child: Transform.rotate(
                      angle: _logoWaveAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // OurBank text with gradient
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              "OurBank",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -2,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF6366F1).withOpacity(0.5),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Simple tagline
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "Modern Banking",
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Epic animated wave background ON TOP (sweeps over logo)
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: LiquidWavePainter(
                  animationValue: _waveAnimation.value,
                  color1: const Color(0xFF6366F1),
                  color2: const Color(0xFF8B5CF6),
                ),
                child: Container(),
              );
            },
          ),
        ],
      ),
    );
  }
}