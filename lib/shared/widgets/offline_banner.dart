import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_spacing.dart';

/// Banner widget that displays when device is offline
class OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const OfflineBanner({
    super.key,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: Colors.orange,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No internet connection. Some features may be limited.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

