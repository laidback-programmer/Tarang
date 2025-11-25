import 'package:flutter/material.dart';
import 'dart:math' as math;

class EnhancedOceanBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<OceanNavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool floatingCenterButton;
  final int? centerButtonIndex;

  const EnhancedOceanBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.floatingCenterButton = false,
    this.centerButtonIndex,
  }) : super(key: key);

  @override
  State<EnhancedOceanBottomNav> createState() => _EnhancedOceanBottomNavState();
}

class _EnhancedOceanBottomNavState extends State<EnhancedOceanBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _waveAnimations;
  late AnimationController _backgroundWaveController;
  late AnimationController _bubbleController;
  late List<BubbleData> _bubbles;

  @override
  void initState() {
    super.initState();

    // Initialize item animations
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _scaleAnimations = _controllers
        .map((controller) => Tween<double>(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(parent: controller, curve: Curves.elasticOut),
            ))
        .toList();

    _waveAnimations = _controllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();

    // Background wave animation
    _backgroundWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Bubble animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Generate random bubbles
    _bubbles = List.generate(
      8,
      (index) => BubbleData(
        x: (index / 8) + (math.Random().nextDouble() * 0.1),
        radius: 2 + math.Random().nextDouble() * 4,
        speed: 0.3 + math.Random().nextDouble() * 0.7,
        opacity: 0.1 + math.Random().nextDouble() * 0.3,
      ),
    );

    // Trigger animation for initially selected item
    if (widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(EnhancedOceanBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (oldWidget.currentIndex < _controllers.length) {
        _controllers[oldWidget.currentIndex].reverse();
      }
      if (widget.currentIndex < _controllers.length) {
        _controllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _backgroundWaveController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? Colors.white;
    final Color selectedColor = widget.selectedColor ?? const Color(0xFF0A6FB8);
    final Color unselectedColor =
        widget.unselectedColor ?? Colors.grey.shade600;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Main navigation bar
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background waves
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _backgroundWaveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: AnimatedWavePainter(
                        animationValue: _backgroundWaveController.value,
                        color: selectedColor,
                      ),
                    );
                  },
                ),
              ),
              // Bubbles
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _bubbleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BubblePainter(
                        animationValue: _bubbleController.value,
                        color: selectedColor,
                        bubbles: _bubbles,
                      ),
                    );
                  },
                ),
              ),
              // Navigation items
              SafeArea(
                child: SizedBox(
                  height: 65,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(widget.items.length, (index) {
                        final item = widget.items[index];
                        final isSelected = index == widget.currentIndex;
                        final isCenterButton = widget.floatingCenterButton &&
                            widget.centerButtonIndex == index;

                        if (isCenterButton) {
                          return Expanded(
                              child:
                                  Container()); // Placeholder for floating button
                        }

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onTap(index),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedBuilder(
                              animation: _controllers[index],
                              builder: (context, child) {
                                return _buildNavItem(
                                  item,
                                  isSelected,
                                  selectedColor,
                                  unselectedColor,
                                  _scaleAnimations[index].value,
                                  _waveAnimations[index].value,
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Floating center button
        if (widget.floatingCenterButton && widget.centerButtonIndex != null)
          Positioned(
            bottom: 25,
            child: _buildFloatingButton(
              widget.items[widget.centerButtonIndex!],
              widget.currentIndex == widget.centerButtonIndex,
              selectedColor,
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingButton(
    OceanNavItem item,
    bool isSelected,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => widget.onTap(widget.centerButtonIndex!),
      child: AnimatedBuilder(
        animation: widget.centerButtonIndex! < _controllers.length
            ? _controllers[widget.centerButtonIndex!]
            : _controllers.first,
        builder: (context, child) {
          final scale = widget.centerButtonIndex! < _scaleAnimations.length
              ? _scaleAnimations[widget.centerButtonIndex!].value
              : 1.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withBlue((color.blue * 0.8).toInt()),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple effect
                  if (isSelected)
                    AnimatedBuilder(
                      animation:
                          widget.centerButtonIndex! < _waveAnimations.length
                              ? _waveAnimations[widget.centerButtonIndex!]
                              : _waveAnimations.first,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(80, 80),
                          painter: RipplePainter(
                            progress: widget.centerButtonIndex! <
                                    _waveAnimations.length
                                ? _waveAnimations[widget.centerButtonIndex!]
                                    .value
                                : 0,
                            color: Colors.white,
                            rippleCount: 3,
                          ),
                        );
                      },
                    ),
                  Icon(
                    item.icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    OceanNavItem item,
    bool isSelected,
    Color selectedColor,
    Color unselectedColor,
    double scale,
    double waveProgress,
  ) {
    // Calculate responsive sizes
    final iconSize = 20.0;
    final iconPadding = 5.0;
    final containerSize = iconSize + (iconPadding * 2);
    final rippleSize =
        containerSize + 10.0; // Ripple slightly larger than container

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Wrap icon in a fixed-size container to prevent layout shift during scale animation
        SizedBox(
          height: rippleSize,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Wave ripple effect - sized relative to icon container
              if (isSelected)
                CustomPaint(
                  size: Size(rippleSize, rippleSize),
                  painter: RipplePainter(
                    progress: waveProgress,
                    color: selectedColor,
                    rippleCount: 2,
                  ),
                ),
              // Icon container
              Transform.scale(
                scale: scale,
                child: Container(
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              selectedColor.withValues(alpha: 0.2),
                              selectedColor.withValues(alpha: 0.1),
                            ],
                          )
                        : null,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: selectedColor.withValues(alpha: 0.3),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    item.icon,
                    size: iconSize,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),
                ),
              ),
              // Water droplet indicator
              if (isSelected)
                Positioned(
                  top: -2,
                  child: Transform.scale(
                    scale: 1.0 - (waveProgress * 0.5),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: 0.5),
                            blurRadius: 3,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        // Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isSelected ? 9.5 : 9,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? selectedColor : unselectedColor,
            letterSpacing: 0.2,
            height: 0.9,
          ),
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Active wave indicator (no spacing above)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isSelected ? 16 : 0,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      selectedColor.withValues(alpha: 0.3),
                      selectedColor,
                      selectedColor.withValues(alpha: 0.3),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

class OceanNavItem {
  final IconData icon;
  final String label;
  final String? tooltip;

  const OceanNavItem({
    required this.icon,
    required this.label,
    this.tooltip,
  });
}

// Painter classes
class AnimatedWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  AnimatedWavePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 8.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final y = size.height -
          15 +
          math.sin((i / waveLength + animationValue) * 2 * math.pi) *
              waveHeight;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final y = size.height -
          10 +
          math.sin((i / waveLength - animationValue) * 2 * math.pi) *
              (waveHeight * 0.7);
      path2.lineTo(i, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(AnimatedWavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int rippleCount;

  RipplePainter({
    required this.progress,
    required this.color,
    this.rippleCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < rippleCount; i++) {
      final rippleProgress = (progress - (i * 0.15)).clamp(0.0, 1.0);
      final radius = maxRadius * rippleProgress;
      final opacity = (1 - rippleProgress) * 0.4;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      if (rippleProgress > 0) {
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class BubblePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final List<BubbleData> bubbles;

  BubblePainter({
    required this.animationValue,
    required this.color,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final yOffset =
          (animationValue * bubble.speed * size.height) % (size.height + 30);
      final y = size.height - yOffset;

      if (y < size.height && y > -bubble.radius) {
        final paint = Paint()
          ..color = color.withValues(alpha: bubble.opacity * 0.5)
          ..style = PaintingStyle.fill;

        final center = Offset(bubble.x * size.width, y);
        canvas.drawCircle(center, bubble.radius, paint);

        // Shine effect
        final shinePaint = Paint()
          ..color = Colors.white.withValues(alpha: bubble.opacity * 0.4)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            center.dx - bubble.radius * 0.3,
            center.dy - bubble.radius * 0.3,
          ),
          bubble.radius * 0.25,
          shinePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class BubbleData {
  final double x;
  final double radius;
  final double speed;
  final double opacity;

  BubbleData({
    required this.x,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}
