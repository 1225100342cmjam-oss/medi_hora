import 'package:flutter/material.dart';
import '../theme.dart';
import 'auth_gate.dart';

/// Pantalla "Inicio" (splash).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthGate(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _FondoPainter())),
        Positioned(
          top: size.height * 0.16,
          left: size.width * 0.14,
          right: size.width * 0.14,
          child: FadeTransition(
            opacity: _c,
            child: Image.asset('assets/images/splash_icons.png', fit: BoxFit.contain),
          ),
        ),
        Positioned(
          left: 24,
          bottom: 36,
          child: FadeTransition(opacity: _c, child: Text('MediHora', style: slab(52))),
        ),
      ]),
    );
  }
}

class _FondoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = kRojo);
    final path = Path()
      ..moveTo(0, size.height * 0.10)
      ..lineTo(size.width, size.height * 0.66)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = kRojoOscuro);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
