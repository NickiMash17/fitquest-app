// lib/features/home/widgets/welcome_header.dart
import 'package:flutter/material.dart';
import 'package:fitquest/shared/models/user_model.dart';

class WelcomeHeader extends StatelessWidget {
  final UserModel user;

  const WelcomeHeader({super.key, required this.user});

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Enhanced User Avatar
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            image: user.photoUrl != null
                ? DecorationImage(
                    image: NetworkImage(user.photoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: user.photoUrl == null
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                  )
                : null,
          ),
          child: user.photoUrl == null
              ? Center(
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        // Enhanced Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                user.displayName ?? 'User',
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
    );
  }
}
