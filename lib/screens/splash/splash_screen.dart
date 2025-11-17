import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import 'connection_checker.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _barsController;
  late AnimationController _orbitalController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;

  ConnectionStatus? _connectionStatus;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkConnection();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _barsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _orbitalController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _mainController.forward();
  }

  Future<void> _checkConnection() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final status = await ConnectionChecker.getDetailedStatus();

    setState(() {
      _connectionStatus = status;
      _isChecking = false;
    });

    if (status.isConnected) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
    // Auto-retry after 5 seconds if connection failed
    // Uncomment below for auto-retry:
    // else {
    //   await Future.delayed(const Duration(seconds: 5));
    //   if (mounted) {
    //     setState(() => _isChecking = true);
    //     _checkConnection();
    //   }
    // }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _barsController.dispose();
    _orbitalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Column(
        children: [
          // Top spacer for margin
          const SizedBox(height: 40),
          
          // Logo and text area
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Business-focused Ryse Logo with unique animation
                _buildRyseLogo(),
                const SizedBox(height: 30),

                // App branding
                SlideTransition(
                  position: _textSlide,
                  child: Column(
                    children: [
                      Text(
                        'RYSE TWO',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Platform for Founders',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Connection Status Section - Expanded to push footer down
          Expanded(
            child: Center(
              child: _isChecking
                  ? _buildBusinessLoadingState()
                  : _connectionStatus != null
                      ? _buildConnectionStatus()
                      : SizedBox.shrink(),
            ),
          ),

          // Footer - Pinned to bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                Text(
                  'Powered by Skyryse Tech',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRyseLogo() {
    return FadeTransition(
      opacity: _logoOpacity,
      child: ScaleTransition(
        scale: _logoScale,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle animation
              _buildAnimatedBackgroundCircles(),
              // Center - App Icon (Circular)
              ClipOval(
                child: Image.asset(
                  'assets/ryse_two.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackgroundCircles() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(3, (index) {
        return RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _barsController,
              curve: Curves.linear,
            ),
          ),
          child: Container(
            width: 120 + (index * 20).toDouble(),
            height: 120 + (index * 20).toDouble(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity((0.5 - index * 0.15).clamp(0, 1)),
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBusinessLoadingState() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          // Futuristic data stream visualization
          SizedBox(
            width: 140,
            height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbital data points
              ...List.generate(3, (orbitIndex) {
                return AnimatedBuilder(
                  animation: _orbitalController,
                  builder: (context, child) {
                    final angle = (_orbitalController.value * 2 * pi) +
                        (orbitIndex * 2.094); // 2.094 = 120 degrees
                    // Add random variation to radius (±5 pixels within bounds)
                    final baseRadius = 25 + (orbitIndex * 11.5).toDouble();
                    final randomVariation = sin(_orbitalController.value * pi * 2.5 + orbitIndex) * 5;
                    final radius = baseRadius + randomVariation;
                    final x = radius * cos(angle);
                    final y = radius * sin(angle);

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondary,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
              // Center core
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondary,
                      AppTheme.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary.withOpacity(0.8),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
        // Data sync progress bars
        SizedBox(
          width: 180,
          child: Column(
            children: List.generate(3, (index) {
              final labels = ['Connecting', 'Syncing', 'Verifying'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedBuilder(
                      animation: _barsController,
                      builder: (context, child) {
                        final value = (_barsController.value +
                                (index * 0.3)) %
                            1.0;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 5,
                            backgroundColor:
                                Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.lerp(
                                AppTheme.secondary,
                                AppTheme.primary,
                                value,
                              )!,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Initializing Quantum Link',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Establishing secure connection...',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.3,
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final isConnected = _connectionStatus?.isConnected ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // Futuristic connection indicator
          SizedBox(
            width: 120,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing background rings - Moved down with padding
                Padding(
                  padding: EdgeInsets.only(top: isConnected ? 20 : 0),
                  child: SizedBox(
                    width: 120,
                    height: 150,
                    child: isConnected
                        ? Stack(
                            alignment: Alignment.center,
                            children: List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _barsController,
                                builder: (context, child) {
                                  final scale = 1.0 +
                                      ((_barsController.value + index * 0.15) % 1.0) *
                                          0.8;
                                  final opacity = (1.0 -
                                          ((_barsController.value + index * 0.15) %
                                              1.0)) *
                                      0.6;
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.secondary
                                              .withOpacity(opacity),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          )
                        : Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                // Inner circle with status - Moved down with padding
                Padding(
                  padding: EdgeInsets.only(top: isConnected ? 20 : 0),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isConnected
                            ? [
                                AppTheme.secondary.withOpacity(0.3),
                                AppTheme.primary.withOpacity(0.2),
                              ]
                            : [
                                Colors.orange.withOpacity(0.15),
                                Colors.red.withOpacity(0.1),
                              ],
                      ),
                      border: Border.all(
                        color: isConnected
                            ? AppTheme.secondary
                            : Colors.orange,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isConnected
                              ? AppTheme.secondary.withOpacity(0.4)
                              : Colors.orange.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isConnected)
                          // Success checkmark
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _mainController,
                                curve: const Interval(0.6, 1.0,
                                    curve: Curves.elasticOut),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.secondary,
                                    AppTheme.accent,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 55,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          // Error icon
                          Icon(
                            Icons.warning_rounded,
                            size: 45,
                            color: Colors.orange,
                          ),
                    ],
                  ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isConnected ? 80 : 40),
          Text(
            isConnected ? 'System Online' : 'Connection Failed',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: isConnected ? 6 : 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isConnected
                  ? AppTheme.secondary.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              border: Border.all(
                color: isConnected
                    ? AppTheme.secondary.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Text(
              _connectionStatus?.message ?? 'Checking connection...',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isConnected
                    ? AppTheme.secondary
                    : Colors.orange,
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (!isConnected) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isChecking = true;
                  });
                  _checkConnection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: AppTheme.secondary.withOpacity(0.4),
                ),
                child: Text(
                  'Retry Connection',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Continue Offline',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
