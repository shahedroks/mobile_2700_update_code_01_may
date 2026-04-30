import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AuthButtonVariant.primary,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AuthButtonVariant variant;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;
    switch (variant) {
      case AuthButtonVariant.primary:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            child: Text(label.toUpperCase()),
          ),
        );
      case AuthButtonVariant.ghost:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: effectiveOnPressed,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        );
    }
  }
}

enum AuthButtonVariant { primary, ghost }
