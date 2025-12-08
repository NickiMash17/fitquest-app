import 'package:flutter/material.dart';
import 'package:fitquest/shared/widgets/premium_loading_widget.dart';

/// Reusable loading widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool usePremiumLoader;

  const LoadingWidget({
    super.key,
    this.message,
    this.usePremiumLoader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (usePremiumLoader) {
      return PremiumLoadingWidget(message: message);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

