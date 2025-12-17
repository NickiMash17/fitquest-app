// lib/shared/widgets/time_based_background.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Time-based background gradient that changes throughout the day
/// Phase 3: Day/night sky gradient transitions
class TimeBasedBackground extends StatelessWidget {
  final Widget child;
  final DateTime? currentTime;

  const TimeBasedBackground({
    super.key,
    required this.child,
    this.currentTime,
  });

  Gradient _getTimeBasedGradient(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final timeOfDay = hour + (minute / 60.0);

    // Morning: 5:00 - 8:00 (sunrise)
    if (timeOfDay >= 5 && timeOfDay < 8) {
      final progress = (timeOfDay - 5) / 3;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(
            const Color(0xFF1A1A2E), // Night blue
            const Color(0xFFFFB347), // Sunrise orange
            progress,
          )!,
          Color.lerp(
            const Color(0xFF16213E), // Dark blue
            const Color(0xFFFFD89B), // Light orange
            progress,
          )!,
        ],
      );
    }

    // Day: 8:00 - 18:00 (blue sky)
    if (timeOfDay >= 8 && timeOfDay < 18) {
      return AppColors.gradientSky;
    }

    // Evening: 18:00 - 21:00 (sunset)
    if (timeOfDay >= 18 && timeOfDay < 21) {
      final progress = (timeOfDay - 18) / 3;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(
            const Color(0xFF87CEEB), // Sky blue
            const Color(0xFFFF6B6B), // Sunset red
            progress,
          )!,
          Color.lerp(
            const Color(0xFFE0F2F1), // Light blue
            const Color(0xFFFF8E53), // Sunset orange
            progress,
          )!,
        ],
      );
    }

    // Night: 21:00 - 5:00 (dark with stars)
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF1A1A2E), // Deep blue
        Color(0xFF16213E), // Darker blue
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final time = currentTime ?? DateTime.now();
    final gradient = _getTimeBasedGradient(time);

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Stack(
        children: [
          // Stars overlay for night time
          if (_isNightTime(time)) _StarsOverlay(),
          child,
        ],
      ),
    );
  }

  bool _isNightTime(DateTime time) {
    final hour = time.hour;
    return hour >= 21 || hour < 5;
  }
}

class _StarsOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _StarsPainter(),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final List<Offset> _stars = [
    const Offset(50, 100),
    const Offset(150, 80),
    const Offset(250, 120),
    const Offset(350, 90),
    const Offset(450, 110),
    const Offset(100, 200),
    const Offset(200, 180),
    const Offset(300, 220),
    const Offset(400, 190),
    const Offset(500, 210),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (var star in _stars) {
      if (star.dx < size.width && star.dy < size.height) {
        // Draw twinkling star
        canvas.drawCircle(star, 1.5, paint);
        canvas.drawCircle(
            star, 3, paint..color = Colors.white.withValues(alpha: 0.3),);
      }
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => false;
}
