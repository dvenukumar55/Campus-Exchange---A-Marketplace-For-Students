import 'package:flutter/material.dart';

class ConditionBadge extends StatelessWidget {
  final String condition;

  const ConditionBadge({
    super.key,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getConditionStyle(condition);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: style.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: style.dot.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              color: style.dot,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: style.dot.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            condition,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: style.foreground,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _ConditionStyle _getConditionStyle(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.contains('like new')) {
      return const _ConditionStyle(
        background: Color(0x2B38BDF8),
        border: Color(0x5938BDF8),
        foreground: Color(0xFF7DD3FC),
        dot: Color(0xFF38BDF8),
      );
    }

    if (normalized.contains('new')) {
      return const _ConditionStyle(
        background: Color(0x2B22C55E),
        border: Color(0x5922C55E),
        foreground: Color(0xFF86EFAC),
        dot: Color(0xFF22C55E),
      );
    }

    if (normalized.contains('good')) {
      return const _ConditionStyle(
        background: Color(0x2B6366F1),
        border: Color(0x596366F1),
        foreground: Color(0xFFA5B4FC),
        dot: Color(0xFF818CF8),
      );
    }

    if (normalized.contains('fair')) {
      return const _ConditionStyle(
        background: Color(0x2BF59E0B),
        border: Color(0x59F59E0B),
        foreground: Color(0xFFFDE68A),
        dot: Color(0xFFFBBF24),
      );
    }

    return const _ConditionStyle(
      background: Color(0x2494A3B8),
      border: Color(0x4094A3B8),
      foreground: Color(0xFFCBD5E1),
      dot: Color(0xFF94A3B8),
    );
  }
}

class _ConditionStyle {
  final Color background;
  final Color border;
  final Color foreground;
  final Color dot;

  const _ConditionStyle({
    required this.background,
    required this.border,
    required this.foreground,
    required this.dot,
  });
}
