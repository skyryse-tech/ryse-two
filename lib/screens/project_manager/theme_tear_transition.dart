import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A unique page transition that creates a "tearing" effect from light to dark theme
/// with particles and smooth animations
class ThemeTearTransition extends PageRouteBuilder {
  final Widget child;
  
  ThemeTearTransition({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 1200),
          reverseTransitionDuration: const Duration(milliseconds: 900),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _ThemeTearTransitionWidget(
              animation: animation,
              child: child,
            );
          },
        );
}

class _ThemeTearTransitionWidget extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _ThemeTearTransitionWidget({
    required this.animation,
    required this.child,
  });

  static const _bgGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0A0E27),
        Color(0xFF1A1F3A),
        Color(0xFF0F1729),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          children: [
            // Background dark layer
            Container(decoration: _bgGradient),
            
            // Particle effect (only in middle of transition)
            if (animation.value > 0.15 && animation.value < 0.85)
              ..._buildParticles(),
            
            // Tear reveal effect
            ClipPath(
              clipper: _TearClipper(animation.value),
              child: child,
            ),
            
            // Energy waves
            if (animation.value > 0.25 && animation.value < 0.75)
              ..._buildEnergyWaves(),
            
            // Minimal fade overlay
            if (animation.value < 0.6)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (1.0 - animation.value) * 0.15,
                    child: Container(
                      color: const Color(0xFF00F0FF),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    final random = math.Random(42);
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      final size = 2.0 + random.nextDouble() * 3;
      final delay = i / 20;
      final particleProgress = ((animation.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      
      if (particleProgress > 0) {
        particles.add(
          Positioned(
            left: x * 400,
            top: y * 800 - (particleProgress * 80),
            child: Opacity(
              opacity: (1.0 - particleProgress) * 0.6,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i % 3 == 0
                      ? const Color(0xFF00F0FF)
                      : i % 3 == 1
                          ? const Color(0xFFB026FF)
                          : const Color(0xFF00FFA3),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return particles;
  }

  List<Widget> _buildEnergyWaves() {
    return List.generate(2, (index) {
      final waveDelay = index * 0.2;
      final waveProgress = ((animation.value - waveDelay) / (1.0 - waveDelay)).clamp(0.0, 1.0);
      
      if (waveProgress <= 0 || waveProgress >= 1) return const SizedBox.shrink();
      
      return Positioned.fill(
        child: CustomPaint(
          painter: _EnergyWavePainter(
            progress: waveProgress,
            color: index == 0
                ? const Color(0xFF00F0FF)
                : const Color(0xFFB026FF),
          ),
        ),
      );
    });
  }
}

/// Custom clipper that creates a diagonal tear effect
class _TearClipper extends CustomClipper<Path> {
  final double progress;

  _TearClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    
    if (progress <= 0.0) {
      return path..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    
    if (progress >= 1.0) {
      return path;
    }

    // Create jagged tear effect
    final tearY = size.height * (1.0 - progress);
    path.moveTo(0, tearY);
    
    // Add jagged edges for tear effect
    const segments = 20;
    for (int i = 0; i <= segments; i++) {
      final x = (size.width / segments) * i;
      final jaggedOffset = (i % 2 == 0 ? 1 : -1) * 15 * (1.0 - progress);
      final y = tearY + jaggedOffset * math.sin(progress * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_TearClipper oldClipper) => oldClipper.progress != progress;
}

/// Paints energy waves during transition
class _EnergyWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _EnergyWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final wavePath = Path();
    final waveY = size.height * progress;
    
    wavePath.moveTo(0, waveY);
    
    for (double x = 0; x <= size.width; x += 10) {
      final y = waveY + 
          math.sin((x / size.width) * math.pi * 4 + progress * math.pi * 2) * 20 * (1.0 - progress);
      wavePath.lineTo(x, y);
    }
    
    canvas.drawPath(wavePath, paint);
  }

  @override
  bool shouldRepaint(_EnergyWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Loading widget with theme tear animation
class ThemeTearLoading extends StatefulWidget {
  final String? message;
  
  const ThemeTearLoading({super.key, this.message});

  @override
  State<ThemeTearLoading> createState() => _ThemeTearLoadingState();
}

class _ThemeTearLoadingState extends State<ThemeTearLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF1A1F3A),
            Color(0xFF0F1729),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00F0FF).withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    
                    // Inner rotating ring (opposite direction)
                    Transform.rotate(
                      angle: -_controller.value * 3 * math.pi,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFB026FF).withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    
                    // Center satellite icon
                    Transform.rotate(
                      angle: math.sin(_controller.value * math.pi * 2) * 0.3,
                      child: const Icon(
                        Icons.satellite_alt_rounded,
                        color: Color(0xFF00FFA3),
                        size: 32,
                      ),
                    ),
                    
                    // Orbiting particles
                    ..._buildOrbitingParticles(),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              widget.message ?? 'INITIALIZING SYSTEMS...',
              style: const TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            // Progress bar
            SizedBox(
              width: 200,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: (_controller.value % 1.0),
                    backgroundColor: const Color(0xFF1A1F3A),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00F0FF),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrbitingParticles() {
    return List.generate(3, (index) {
      final angle = (index / 3) * 2 * math.pi + (_controller.value * 2 * math.pi);
      final radius = 45.0;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      
      return Transform.translate(
        offset: Offset(x, y),
        child: Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00FFA3),
          ),
        ),
      );
    });
  }
}
