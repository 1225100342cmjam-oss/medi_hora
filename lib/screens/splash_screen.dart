
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'auth_gate.dart';

/// Pantalla inicial de MediHora.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.8, curve: Curves.easeIn),
    );

    _scale = Tween<double>(
      begin: 0.78,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthGate(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimario,
      body: Stack(
        children: [
          // Fondo decorativo
          const Positioned.fill(
            child: CustomPaint(
              painter: _FondoPainter(),
            ),
          ),

          // Contenido central
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _opacity,
                  child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                      scale: _scale,
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 190,
                    height: 190,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kPrimarioOscuro,
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/splash_icons.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.medication_rounded,
                          size: 110,
                          color: kPrimario,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'MediHora',
                    style: TextStyle(
                      color: kBlanco,
                      fontSize: 43,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Tu salud, a tiempo.',
                    style: TextStyle(
                      color: kBlanco.withValues(alpha: 0.90),
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),

                  const SizedBox(height: 34),

                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: kBlanco.withValues(alpha: 0.90),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pie de pantalla
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Text(
              'Cuidarte también es parte de tu rutina',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kBlanco.withValues(alpha: 0.82),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FondoPainter extends CustomPainter {
  const _FondoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()
      ..color = kPrimarioOscuro.withValues(alpha: 0.55);

    // Curva inferior
    final inferior = Path()
      ..moveTo(0, size.height * 0.72)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.60,
        size.width * 0.68,
        size.height * 0.90,
        size.width,
        size.height * 0.70,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(inferior, pintura);

    // Círculo decorativo superior
    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.12),
      size.width * 0.30,
      Paint()..color = kPrimarioClaro.withValues(alpha: 0.12),
    );

    // Círculo decorativo lateral
    canvas.drawCircle(
      Offset(size.width * 0.02, size.height * 0.83),
      size.width * 0.22,
      Paint()..color = kBlanco.withValues(alpha: 0.06),
    );

    // Pequeños puntos decorativos
    final puntos = Paint()
      ..color = kBlanco.withValues(alpha: 0.25);

    for (var i = 0; i < 12; i++) {
      final x = size.width * (0.08 + (i % 4) * 0.06);
      final y = size.height * (0.12 + (i ~/ 4) * 0.035);

      canvas.drawCircle(
        Offset(x, y),
        2,
        puntos,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
