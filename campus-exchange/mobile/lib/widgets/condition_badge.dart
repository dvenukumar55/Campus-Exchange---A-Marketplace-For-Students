import 'package:flutter/material.dart';

class ConditionBadge extends StatelessWidget {
  final String condition;

  const ConditionBadge({Key? key, required this.condition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFE0E7FF);
    Color fg = const Color(0xFF3730A3);

    if (condition.contains('New')) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (condition.contains('Like New')) {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0369A1);
    } else if (condition.contains('Good')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
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
        condition,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
