import 'package:flutter/material.dart';
import '../theme.dart';

/// Página base: fondo rojo, título slab y flecha de regreso.
class RedPage extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showBack;
  final Widget? fab;
  const RedPage({
    super.key,
    this.title,
    required this.child,
    this.showBack = true,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kRojo,
      floatingActionButton: fab,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(title ?? '', style: slab(26)),
                ),
              ),
              if (showBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 34, color: kTinta),
                  onPressed: () => Navigator.maybePop(context),
                ),
            ]),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: fab == null ? 24 : 100),
                child: child,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class PinkCard extends StatelessWidget {
  final Widget child;
  const PinkCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kRosa,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: child,
      );
}

class CardHeader extends StatelessWidget {
  final String text;
  const CardHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Divider(color: Colors.black54, height: 1),
        ],
      );
}

class EmptyText extends StatelessWidget {
  final String text;
  const EmptyText(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
        ),
      );
}

class DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const DarkButton(this.label, {super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: kOscuro,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
      );
}

class PinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PinkButton(this.label, {super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 42,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: kRosaBoton,
            foregroundColor: kTinta,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0x55000000)),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
      );
}

class LabeledField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscure, readOnly;
  final int maxLines;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscure = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscure,
            readOnly: readOnly,
            maxLines: maxLines,
            onTap: onTap,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hint),
          ),
        ]),
      );
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const StatusChip({super.key, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 96,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      );
}

class BigFab extends StatelessWidget {
  final VoidCallback onPressed;
  const BigFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 76,
        height: 76,
        child: FloatingActionButton(
          heroTag: null,
          elevation: 3,
          backgroundColor: const Color(0xFFE3E3E3),
          foregroundColor: kTinta,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          onPressed: onPressed,
          child: const Icon(Icons.add, size: 32),
        ),
      );
}
