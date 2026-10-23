import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

  static const _icons = [
    Icons.medication, Icons.favorite, Icons.vaccines, Icons.thermostat,
    Icons.medical_services, Icons.health_and_safety, Icons.local_hospital,
    Icons.monitor_heart, Icons.healing, Icons.science,
  ];

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

  Widget _ring(double radius, int count, double size, double offset) {
    return Stack(children: [
      for (var i = 0; i < count; i++)
        Positioned(
          left: 150 + radius * cos(2 * pi * i / count + offset) - size / 2,
          top: 150 + radius * sin(2 * pi * i / count + offset) - size / 2,
          child: Icon(_icons[(i + count) % _icons.length], color: Colors.white, size: size),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kRojo, kRojoOscuro],
          ),
        ),
        child: FadeTransition(
          opacity: _c,
          child: SafeArea(
            child: Column(children: [
              const Spacer(flex: 2),
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(children: [
                  _ring(0, 1, 70, 0),
                  _ring(70, 6, 34, 0.3),
                  _ring(125, 11, 38, 0),
                ]),
              ),
              const Spacer(flex: 3),
              const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text('MediHora',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    )),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
