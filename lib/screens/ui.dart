
import 'package:flutter/material.dart';
import '../theme.dart';

/// Página base para las pantallas secundarias de MediHora.
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
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: kFondo,
      floatingActionButton: fab,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? '',
                      style: tema.textTheme.headlineSmall?.copyWith(
                        color: kPrimarioOscuro,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (showBack)
                    IconButton(
                      tooltip: 'Regresar',
                      onPressed: () => Navigator.maybePop(context),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        backgroundColor: Colors.white,
                        foregroundColor: kAzul,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 27,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: fab == null ? 20 : 90,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta reutilizable para formularios y contenido.
class PinkCard extends StatelessWidget {
  final Widget child;

  const PinkCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD3E2F3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Encabezado para dividir secciones.
class CardHeader extends StatelessWidget {
  final String text;

  const CardHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: kAzul,
          ),
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Color(0xFFD3E2F3),
          height: 1,
        ),
      ],
    );
  }
}

/// Mensaje para listas sin registros.
class EmptyText extends StatelessWidget {
  final String text;

  const EmptyText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: kPrimarioClaro,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 42,
                color: kPrimario,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                height: 1.5,
                color: kTextoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón principal.
class DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DarkButton(
    this.label, {
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimario,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Botón secundario.
class PinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PinkButton(
    this.label, {
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimarioOscuro,
          backgroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          side: const BorderSide(
            color: kPrimario,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Campo de formulario con etiqueta y validación.
class LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscure;
  final bool readOnly;
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: kTinta,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscure,
            readOnly: readOnly,
            maxLines: obscure ? 1 : maxLines,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 17,
              color: kTinta,
            ),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: kFondo,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: Color(0xFFB5CAE2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: Color(0xFFB5CAE2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: kPrimario,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta para estados de medicamentos.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 36,
              minWidth: 96,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón flotante para acciones rápidas.
class BigFab extends StatelessWidget {
  final VoidCallback onPressed;

  const BigFab({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        heroTag: null,
        elevation: 3,
        backgroundColor: kPrimario,
        foregroundColor: Colors.white,
        tooltip: 'Agregar medicamento',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onPressed: onPressed,
        child: const Icon(
          Icons.add_rounded,
          size: 34,
        ),
      ),
    );
  }
}
