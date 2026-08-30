import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFECFDF5);
    Color border = const Color(0xFFA7F3D0);
    Color fg = const Color(0xFF047857);
    Color dotColor = const Color(0xFF10B981);
    String label = 'AVAILABLE';

    final normalized = status.toLowerCase();

    if (normalized == 'sold') {
      bg = const Color(0xFFF1F5F9);
      border = const Color(0xFFCBD5E1);
      fg = const Color(0xFF475569);
      dotColor = const Color(0xFF94A3B8);
      label = 'SOLD';
    } else if (normalized == 'closed') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFECACA);
      fg = const Color(0xFFB91C1C);
      dotColor = const Color(0xFFEF4444);
      label = 'CLOSED';
    } else if (normalized == 'draft') {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      fg = const Color(0xFFB45309);
      dotColor = const Color(0xFFF59E0B);
      label = 'DRAFT';
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
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
