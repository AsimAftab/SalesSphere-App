import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sales_sphere/features/splash/vm/splash.vm.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dotsController;

  late Animation<double> _logoScale;

  final String _textSales = 'Sales';
  final String _textSphere = 'Sphere';
  final List<Animation<double>> _salesLetterAnimations = [];
  final List<Animation<double>> _sphereLetterAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // ✅ LOGO SCALE ANIMATION (Pulse/Breathing effect)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true); // Loop back and forth

    _logoScale = Tween<double>(
      begin: 0.85, // Smaller
      end: 1.0,    // Normal size
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );

    // ✅ TEXT ANIMATION (Netflix style - letter by letter)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // "Sales" letter animations
    for (int i = 0; i < _textSales.length; i++) {
      final double start = i * 0.1;
      final double end = start + 0.3;

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _textController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );

      _salesLetterAnimations.add(animation);
    }

    // "Sphere" letter animations (delayed)
    for (int i = 0; i < _textSphere.length; i++) {
      final double start = 0.3 + (i * 0.08); // Start after "Sales"
      final double end = start + 0.25;

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _textController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );

      _sphereLetterAnimations.add(animation);
    }

    // Dots animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  void _startAnimations() {
    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(splashVMProvider);

    return Scaffold(
      body: Stack(
        children: [
          // === BLUE GRADIENT BACKGROUND ===
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E88E5),
                  Color(0xFF1976D2),
                  Color(0xFF1565C0),
                ],
              ),
            ),
          ),

          // === TOP RIGHT BUBBLE (SVG) ===
          Positioned(
            top: -50.h,
            right: -50.w,
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                'assets/images/splash_bubble_top.svg',
                width: 350.w,
                height: 350.w,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // === BOTTOM LEFT BUBBLE (SVG) ===
          Positioned(
            bottom: -80.h,
            left: -80.w,
            child: Opacity(
              opacity: 0.2,
              child: SvgPicture.asset(
                'assets/images/splash_bubble_bottom.svg',
                width: 400.w,
                height: 400.w,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // === MAIN CONTENT ===
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ✅ ANIMATED TEXT - "Sales" (White, Light)
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_textSales.length, (index) {
                        final char = _textSales[index];
                        final animation = _salesLetterAnimations[index];

                        return FadeTransition(
                          opacity: animation,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              (1 - animation.value) * 30,
                            ),
                            child: Text(
                              char,
                              style: TextStyle(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                // ✅ ANIMATED TEXT - "Sphere" (Dark Blue, Bold)
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_textSphere.length, (index) {
                        final char = _textSphere[index];
                        final animation = _sphereLetterAnimations[index];

                        return FadeTransition(
                          opacity: animation,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              (1 - animation.value) * 30,
                            ),
                            child: Text(
                              char,
                              style: TextStyle(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0D47A1), // Dark blue
                                fontFamily: 'Poppins',
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                SizedBox(height: 40.h),

                // ✅ LOGO WITH SCALE/PULSE ANIMATION
                ScaleTransition(
                  scale: _logoScale,
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 140.w,
                    height: 140.w,
                  ),
                ),

                const Spacer(flex: 3),

                // === ANIMATED DOTS ===
                Padding(
                  padding: EdgeInsets.only(bottom: 50.h),
                  child: AnimatedBuilder(
                    animation: _dotsController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;

                          final opacityAnimation = Tween<double>(
                            begin: 0.3,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _dotsController,
                              curve: Interval(
                                delay,
                                delay + 0.4,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          );

                          final scaleAnimation = Tween<double>(
                            begin: 0.8,
                            end: 1.2,
                          ).animate(
                            CurvedAnimation(
                              parent: _dotsController,
                              curve: Interval(
                                delay,
                                delay + 0.4,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          );

                          return Transform.scale(
                            scale: scaleAnimation.value,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.w),
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(
                                  alpha: opacityAnimation.value,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}