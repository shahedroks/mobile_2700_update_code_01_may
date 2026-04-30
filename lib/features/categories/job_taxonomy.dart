import 'package:flutter/material.dart';

enum JobUrgency { critical, high, medium, low }

extension UrgencyStyle on JobUrgency {
  Color get foreground => switch (this) {
        JobUrgency.critical => const Color(0xFFF87171),
        JobUrgency.high => const Color(0xFFFB923C),
        JobUrgency.medium => const Color(0xFFFBBF24),
        JobUrgency.low => const Color(0xFF4ADE80),
      };

  Color get chipBg => foreground.withValues(alpha: 0.12);

  Color get chipBorder => foreground.withValues(alpha: 0.35);
}

String urgencyLabel(JobUrgency u) => switch (u) {
      JobUrgency.critical => 'CRITICAL',
      JobUrgency.high => 'HIGH',
      JobUrgency.medium => 'MEDIUM',
      JobUrgency.low => 'LOW',
    };
