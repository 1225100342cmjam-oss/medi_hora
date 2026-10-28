import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'ui.dart';

/// Pantalla "Noti2": confirmación exitosa + racha.
class ConfirmacionScreen extends StatefulWidget {
  final int racha;
  const ConfirmacionScreen({super.key, required this.racha});
  @override
  State<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends State<ConfirmacionScreen> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(seconds: 5), () {
      if (mounted) Navigator.maybePop(context);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimario,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_outline, size: 190, color: kBlanco),
                const SizedBox(height: 24),
                Text('Confirmación exitosa', textAlign: TextAlign.center, style: slab(22, color: kBlanco)),
                const SizedBox(height: 28),
                Text('Ya se ha registrado la actividad',
                    textAlign: TextAlign.center, style: slab(16, color: kBlanco)),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: kAzulSuave,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0x331565C0)),
                  ),
                  child: Text(
                    'Racha de: ${widget.racha} ${widget.racha == 1 ? 'día' : 'días'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: kAzul, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
