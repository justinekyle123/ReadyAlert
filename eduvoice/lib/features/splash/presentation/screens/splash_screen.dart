import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/emergency_hero.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.35, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic),
          ),
        );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.95, curve: Curves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onFinished();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.splashStart,
                AppColors.primary,
                AppColors.splashEnd,
              ],
              stops: [0, 0.52, 1],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -120,
                left: -90,
                child: _SplashBlob(size: 320, opacity: 0.07),
              ),
              const Positioned(
                bottom: -140,
                right: -100,
                child: _SplashBlob(size: 360, opacity: 0.06),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 20),
                  child: Column(
                    children: [
                      const Spacer(flex: 4),
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: const EmergencyHero(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeTransition(
                        opacity: _textOpacity,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'READY ALERT',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Prepare. Respond. Stay connected.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'POLOMOLOK NATIONAL HIGH SCHOOL',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.6,
                                  color: Colors.white.withValues(alpha: 0.62),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(flex: 5),
                      _SplashProgress(progress: _progress),
                      const SizedBox(height: 14),
                      FadeTransition(
                        opacity: _textOpacity,
                        child: Text(
                          'Preparing your dashboard',
                          style: TextStyle(
                            fontSize: 10.5,
                            letterSpacing: 0.2,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            Container(color: Colors.white.withValues(alpha: 0.22)),
            AnimatedBuilder(
              animation: progress,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: progress.value,
                  heightFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: child,
                );
              },
              child: Container(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBlob extends StatelessWidget {
  const _SplashBlob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
