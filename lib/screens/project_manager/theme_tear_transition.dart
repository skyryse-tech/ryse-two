import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Loading widget with animated satellite theme
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
              builder: (context, _) {
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
                builder: (context, _) {
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
        child: const _OrbitParticle(),
      );
    });
  }
}

class _OrbitParticle extends StatelessWidget {
  const _OrbitParticle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF00FFA3),
      ),
    );
  }
}

