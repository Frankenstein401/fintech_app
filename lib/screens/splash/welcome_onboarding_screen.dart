import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/screens/auth/login_screen.dart';
import 'dart:math' as math;

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatController;
  late AnimationController _fadeController;
  
  // NEW: Entrance animation controller
  late AnimationController _entranceController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;
  
  // NEW: Entrance animations
  late Animation<double> _ringScaleAnimation;
  late Animation<double> _elementsOpacityAnimation;
  late Animation<double> _elementsScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation (will start after entrance)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    // Float animation (will start after entrance)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Page fade
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // NEW: Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // 1.8 seconds total
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotationController);
    
    _floatAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // NEW: Ring scale animation (shrink from 2x to 1x)
    // Duration: 0.0 - 1.2 seconds
    _ringScaleAnimation = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.0,
          0.67, // 1.2s of 1.8s = 0.67
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    // NEW: Elements spawn animation (all together after ring shrinks)
    // Start at 1.2s, end at 1.8s
    _elementsOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.67, // Start after ring animation
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    _elementsScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.67,
          1.0,
          curve: Curves.easeOutBack, // Slight bounce effect
        ),
      ),
    );

    // Start animations with delay
    _fadeController.forward();
    
    // Start entrance after 0.3 second delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _entranceController.forward().then((_) {
        // Start rotation and float after entrance is complete
        _rotationController.repeat();
        _floatController.repeat(reverse: true);
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatController.dispose();
    _fadeController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // 3D Animated Elements - WITH ENTRANCE ANIMATION
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _entranceController,
                    _rotationAnimation,
                    _floatAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer rotating ring - WITH SCALE ANIMATION
                            Transform.scale(
                              scale: _ringScaleAnimation.value,
                              child: Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF6366F1).withOpacity(0.25),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Middle ring - WITH SCALE ANIMATION (opposite rotation)
                            Transform.scale(
                              scale: _ringScaleAnimation.value,
                              child: Transform.rotate(
                                angle: -_rotationAnimation.value * 0.7,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF8B5CF6).withOpacity(0.25),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Floating orbs - WITH SPAWN ANIMATION
                            ..._buildFloatingOrbs(),

                            // Center 3D Card - WITH SPAWN ANIMATION
                            Opacity(
                              opacity: _elementsOpacityAnimation.value,
                              child: Transform.scale(
                                scale: _elementsScaleAnimation.value,
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(math.sin(_rotationAnimation.value) * 0.3),
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 120,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF6366F1),
                                          const Color(0xFF8B5CF6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1).withOpacity(0.5),
                                          blurRadius: 35,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Card shine effect
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withOpacity(0.25),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Card content
                                        Center(
                                          child: Icon(
                                            Icons.account_balance,
                                            size: 56,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Content - Bottom Section (NO CHANGES)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Discover modern",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        children: [
                          Text(
                            "banking with ",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                              height: 1.2,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              "OurBank",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        "The perfect banking experience\nmade just for you",
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Button with Start text
                      Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1)
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Start",
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      // Orb 1 - Top Right - WITH SPAWN ANIMATION
      Positioned(
        top: 30,
        right: 40,
        child: Opacity(
          opacity: _elementsOpacityAnimation.value,
          child: Transform.scale(
            scale: _elementsScaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.translate(
                offset: Offset(0, math.sin(_rotationAnimation.value * 2) * 8),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF6366F1).withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      
      // Orb 2 - Right - WITH SPAWN ANIMATION
      Positioned(
        right: 30,
        top: 100,
        child: Opacity(
          opacity: _elementsOpacityAnimation.value,
          child: Transform.scale(
            scale: _elementsScaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 0.8,
              child: Transform.translate(
                offset: Offset(math.cos(_rotationAnimation.value * 1.5) * 8, 0),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6),
                        const Color(0xFF8B5CF6).withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      
      // Orb 3 - Left - WITH SPAWN ANIMATION
      Positioned(
        left: 40,
        top: 80,
        child: Opacity(
          opacity: _elementsOpacityAnimation.value,
          child: Transform.scale(
            scale: _elementsScaleAnimation.value,
            child: Transform.rotate(
              angle: -_rotationAnimation.value * 0.6,
              child: Transform.translate(
                offset: Offset(0, math.cos(_rotationAnimation.value * 1.8) * 8),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF10B981),
                        const Color(0xFF10B981).withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      // Orb 4 - Bottom Left - WITH SPAWN ANIMATION
      Positioned(
        left: 50,
        bottom: 40,
        child: Opacity(
          opacity: _elementsOpacityAnimation.value,
          child: Transform.scale(
            scale: _elementsScaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 1.2,
              child: Transform.translate(
                offset: Offset(math.sin(_rotationAnimation.value * 1.3) * 8, 0),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFBBF24),
                        const Color(0xFFFBBF24).withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}