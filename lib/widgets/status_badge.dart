import 'package:flutter/material.dart';
import '../config/theme.dart';

// pulse animation draws attention to unhandled orders
class StatusBadge extends StatelessWidget {
  final String status;
  final bool animated;

  const StatusBadge({super.key, required this.status, this.animated = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (animated && status == 'new')
            _pulsingDot(),
          if (animated && status == 'new')
            const SizedBox(width: 6),
          Text(
            _text,
            style: TextStyle(
              color: _textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulsingDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Color get _bgColor {
    switch (status) {
      case 'new':
        return AppColors.accent;
      case 'printing':
        return AppColors.info;
      case 'done':
        return AppColors.success;
      case 'transferred':
        return AppColors.textLight;
      default:
        return Colors.grey;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'new':
        return AppColors.dark;
      case 'printing':
      case 'done':
      case 'transferred':
      default:
        return Colors.white;
    }
  }

  String get _text {
    switch (status) {
      case 'new':
        return 'جديد';
      case 'printing':
        return 'قيد الطباعة';
      case 'done':
        return 'منجز';
      case 'transferred':
        return 'محوّل';
      default:
        return status;
    }
  }
}
