import 'package:flutter/material.dart';

class ConditionBadge extends StatelessWidget {
  final String condition;

  const ConditionBadge({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFF1F5F9);
    Color border = const Color(0xFFCBD5E1);
    Color fg = const Color(0xFF334155);
    Color dotColor = const Color(0xFF64748B);

    final normalized = condition.toLowerCase();

    if (normalized.contains('new') && !normalized.contains('like')) {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFFA7F3D0);
      fg = const Color(0xFF065F46);
      dotColor = const Color(0xFF10B981);
    } else if (normalized.contains('like new')) {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFFBFDBFE);
      fg = const Color(0xFF1E40AF);
      dotColor = const Color(0xFF3B82F6);
    } else if (normalized.contains('good')) {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      fg = const Color(0xFF92400E);
      dotColor = const Color(0xFFF59E0B);
    } else if (normalized.contains('fair')) {
      bg = const Color(0xFFF8FAFC);
      border = const Color(0xFFE2E8F0);
      fg = const Color(0xFF475569);
      dotColor = const Color(0xFF94A3B8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            condition,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
