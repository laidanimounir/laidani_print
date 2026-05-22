import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/connectivity_service.dart';

// green=local, blue=internet, red=offline
class ConnectionIndicator extends StatelessWidget {
  final bool compact;

  const ConnectionIndicator({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        return GestureDetector(
          onTap: () => connectivity.detectAndSwitch(),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: _bgColor(connectivity.mode),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(connectivity.statusIcon, style: TextStyle(fontSize: compact ? 10 : 14)),
                if (!compact) ...[
                  const SizedBox(width: 6),
                  Text(
                    connectivity.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _bgColor(ConnectionMode mode) {
    switch (mode) {
      case ConnectionMode.local:
        return AppColors.success;
      case ConnectionMode.supabase:
        return AppColors.info;
      case ConnectionMode.offline:
        return AppColors.danger;
      case ConnectionMode.unknown:
        return AppColors.warning;
    }
  }
}
