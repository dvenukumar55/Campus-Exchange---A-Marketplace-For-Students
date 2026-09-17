import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStatusStyle(status);

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
            style.label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: style.foreground,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _getStatusStyle(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized == 'sold') {
      return const _StatusStyle(
        background: Color(0x2B6366F1),
        border: Color(0x596366F1),
        foreground: Color(0xFFA5B4FC),
        dot: Color(0xFF818CF8),
        label: 'SOLD',
      );
    }

    if (normalized == 'closed') {
      return const _StatusStyle(
        background: Color(0x2BE11D48),
        border: Color(0x59E11D48),
        foreground: Color(0xFFFDA4AF),
        dot: Color(0xFFFB7185),
        label: 'CLOSED',
      );
    }

    if (normalized == 'draft' || normalized == 'reserved') {
      return const _StatusStyle(
        background: Color(0x2BF59E0B),
        border: Color(0x59F59E0B),
        foreground: Color(0xFFFDE68A),
        dot: Color(0xFFFBBF24),
        label: 'RESERVED',
      );
    }

    return const _StatusStyle(
      background: Color(0x2B22C55E),
      border: Color(0x5922C55E),
      foreground: Color(0xFF86EFAC),
      dot: Color(0xFF22C55E),
      label: 'AVAILABLE',
    );
  }
}

class _StatusStyle {
  final Color background;
  final Color border;
  final Color foreground;
  final Color dot;
  final String label;

  const _StatusStyle({
    required this.background,
    required this.border,
    required this.foreground,
    required this.dot,
    required this.label,
  });
}
