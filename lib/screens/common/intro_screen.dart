import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'role_selection_screen.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = '/';

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Wave animation controller
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Fade animation for content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Slide animation for content
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.fastOutSlowIn),
    );

    // Start animations with staggered delays
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Animated ocean background
          AnimatedOceanBackground(animationController: _waveController),

          // Scrollable SafeArea content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.08),

                  // Logo section
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildLogoSection(),
                  ),

                  SizedBox(height: height * 0.05),

                  // Feature highlights
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFeatureHighlights(),
                    ),
                  ),

                  SizedBox(height: height * 0.05),

                  // Description
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildDescription(),
                    ),
                  ),

                  SizedBox(height: height * 0.05),

                  // Bottom section (buttons)
                  Transform.translate(
                    offset: Offset(0, sin(_waveController.value * 2 * pi) * 5),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildBottomSection(),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white.withOpacity(0.2),
                AppColors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.white.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.waves_rounded,
            size: 60,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.white, AppColors.accentLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.appTagline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
        ),
      ],
    );
  }

  Widget _buildFeatureHighlights() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureCard(
          icon: Icons.warning_amber_rounded,
          title: "Real-time\nAlerts",
          delay: 0,
        ),
        _buildFeatureCard(
          icon: Icons.report_problem_rounded,
          title: "Hazard\nReporting",
          delay: 100,
        ),
        _buildFeatureCard(
          icon: Icons.smart_toy_rounded,
          title: "AI\nAssistant",
          delay: 200,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.white.withOpacity(0.15),
                      AppColors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.white.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        AppStrings.appDescription,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _navigateToRoleSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: AppColors.accent.withOpacity(0.4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.getStarted,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _navigateToRoleSelection,
          child: Text(
            "Skip intro →",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  void _navigateToRoleSelection() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RoleSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.fastOutSlowIn;

          final slideAnimation = animation.drive(
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
          );

          final fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Animated ocean background
class AnimatedOceanBackground extends StatelessWidget {
  final AnimationController animationController;

  const AnimatedOceanBackground({
    super.key,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _OceanWavePainter(animationController.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _OceanWavePainter extends CustomPainter {
  final double animationValue;

  _OceanWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundGradient = LinearGradient(
      colors: [
        AppColors.primaryDark,
        AppColors.primary,
        AppColors.primaryLight,
        AppColors.accent.withOpacity(0.8),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    _drawWaveLayer(canvas, size, 0.65, 0.2, 40, 2.0, animationValue);
    _drawWaveLayer(canvas, size, 0.72, 0.15, 25, -1.5, animationValue);
    _drawWaveLayer(canvas, size, 0.78, 0.1, 35, 1.8, animationValue);
    _drawWaveLayer(canvas, size, 0.85, 0.05, 20, -2.2, animationValue);
  }

  void _drawWaveLayer(
    Canvas canvas,
    Size size,
    double yPosition,
    double opacity,
    double amplitude,
    double speed,
    double time,
  ) {
    final wavePaint = Paint()
      ..color = AppColors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePath.moveTo(0, size.height * yPosition);

    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * yPosition +
          amplitude * sin((x / size.width * 2 * pi) + (time * speed * pi));
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
