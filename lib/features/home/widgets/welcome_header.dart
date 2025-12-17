// lib/features/home/widgets/welcome_header.dart
import 'package:flutter/material.dart';
import 'package:fitquest/shared/models/user_model.dart';
import 'package:fitquest/shared/widgets/premium_avatar.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

class WelcomeHeader extends StatefulWidget {
  final UserModel user;

  const WelcomeHeader({super.key, required this.user});

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getMotivationalMessage() {
    final streak = widget.user.currentStreak;
    final level = widget.user.currentLevel;

    if (streak >= 30) {
      return '$streak-day streak! You\'re unstoppable!';
    } else if (streak >= 7) {
      return '$streak-day streak! Keep it going!';
    } else if (streak >= 3) {
      return '$streak-day streak! Building momentum!';
    } else if (level >= 10) {
      return 'Level $level! You\'re a wellness champion!';
    } else if (level >= 5) {
      return 'Level $level! Growing stronger every day!';
    } else {
      return 'Let\'s make today amazing!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedPremiumAvatar(
              user: widget.user,
              size: 64,
              showBadge: true,
              showLevelRing: true,
              usePlantAvatar: true,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.user.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: AppBorderRadius.allXL,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _getMotivationalMessage(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
