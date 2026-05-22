import 'package:flutter/material.dart';
import '../config/theme.dart';

// loading state prevents double-tap submission
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;
  final ButtonType type;
  final IconData? icon;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.type = ButtonType.primary,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final button = _buildButton();
    if (expanded) {
      return SizedBox(width: double.infinity, height: height ?? 52, child: button);
    }
    return SizedBox(height: height ?? 52, child: button);
  }

  Widget _buildButton() {
    final child = loading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          ),
          child: child,
        );
      case ButtonType.accent:
        return ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.dark,
            disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
          ),
          child: child,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: child,
        );
      case ButtonType.danger:
        return ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.5),
          ),
          child: child,
        );
    }
  }
}

enum ButtonType { primary, accent, outlined, danger }
