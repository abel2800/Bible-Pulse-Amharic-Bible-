import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0B1216),
                    AppTheme.primaryIndigo,
                    const Color(0xFF071329),
                  ]
                : [
                    AppTheme.parchment,
                    AppTheme.primaryIndigo,
                    AppTheme.accentTeal,
                    AppTheme.parchment,
                  ],
            stops: isDark ? [0.0, 0.5, 1.0] : [0.0, 0.3, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            if (!isDark)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _glowAnimation.value * 0.1,
                      child: CustomPaint(
                        painter: _HeavenlyPatternPainter(),
                      ),
                    );
                  },
                ),
              ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        AppTheme.accentTeal,
                                        AppTheme.primaryIndigo,
                                      ]
                                    : [
                                        AppTheme.accentTeal,
                                        AppTheme.primaryIndigo,
                                        AppTheme.accentTeal,
                                      ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark
                                          ? const Color(0xFFD4AF37)
                                          : const Color(0xFFFFD700))
                                      .withValues(
                                    alpha: 0.5 * _glowAnimation.value,
                                  ),
                                  blurRadius: 40 + (30 * _glowAnimation.value),
                                  spreadRadius: 10 * _glowAnimation.value,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              size: 90,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: isDark
                              ? [
                                  AppTheme.accentTeal,
                                  AppTheme.primaryIndigo,
                                  AppTheme.parchment
                                ]
                              : [
                                  AppTheme.accentTeal,
                                  AppTheme.primaryIndigo,
                                  AppTheme.parchment
                                ],
                        ).createShader(bounds),
                        child: Text(
                          'BiblePulse',
                          style: GoogleFonts.crimsonText(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your Daily Faith Companion',
                        style: GoogleFonts.crimsonText(
                          fontSize: 18,
                          color: isDark
                              ? AppTheme.parchment
                              : AppTheme.primaryIndigo,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 60),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? AppTheme.accentTeal
                                : AppTheme.primaryIndigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeavenlyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 80) {
      for (double j = 0; j < size.height; j += 80) {
        canvas.drawCircle(Offset(i, j), 3, paint);
        canvas.drawLine(Offset(i - 10, j), Offset(i + 10, j), paint);
        canvas.drawLine(Offset(i, j - 10), Offset(i, j + 10), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
