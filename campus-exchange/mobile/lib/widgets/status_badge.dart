import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFDCFCE7);
    Color fg = const Color(0xFF15803D);
    String label = 'ACTIVE';

    if (status == 'sold') {
      bg = const Color(0xFFE2E8F0);
      fg = const Color(0xFF475569);
      label = 'SOLD';
    } else if (status == 'closed') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF991B1B);
      label = 'CLOSED';
    } else if (status == 'draft') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
      label = 'DRAFT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: fg,
        ),
      ),
    );
  }
}
