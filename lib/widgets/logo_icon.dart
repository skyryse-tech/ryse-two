import 'package:flutter/material.dart';

class LogoIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const LogoIcon({
    Key? key,
    this.size = 100,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF1E88E5), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // R Letter
          Center(
            child: Text(
              'R',
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Arial',
              ),
            ),
          ),
          // Arrow (growth indicator)
          Positioned(
            bottom: size * 0.15,
            right: size * 0.15,
            child: Icon(
              Icons.trending_up,
              color: const Color(0xFF42A5F5),
              size: size * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
