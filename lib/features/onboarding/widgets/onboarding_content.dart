import 'package:flutter/material.dart';
import 'package:fitquest/features/onboarding/models/onboarding_item.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageSize = screenSize.width * 0.7; // Responsive: 70% of screen width
    const maxImageSize = 300.0; // Max size for larger screens
    const minImageSize = 200.0; // Min size for very small screens
    final finalImageSize = imageSize.clamp(minImageSize, maxImageSize);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration - responsive sizing
          Container(
            width: finalImageSize,
            height: finalImageSize,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppBorderRadius.allXL,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(item.imagePath, fit: BoxFit.contain),
          ),
          SizedBox(height: screenSize.height * 0.04), // Responsive spacing
          Text(
            item.title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
