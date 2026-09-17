import 'package:flutter/material.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          final icon = _getCategoryIcon(category);
          final accentColor = _getCategoryAccentColor(category);

          return _CategoryChip(
            category: category,
            icon: icon,
            accentColor: accentColor,
            isSelected: isSelected,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final value = category.toLowerCase();

    if (value == 'all') {
      return Icons.grid_view_rounded;
    }

    if (value.contains('book') || value.contains('academic')) {
      return Icons.menu_book_rounded;
    }

    if (value.contains('calculator')) {
      return Icons.calculate_rounded;
    }

    if (value.contains('drawing') || value.contains('graphics')) {
      return Icons.architecture_rounded;
    }

    if (value.contains('lab')) {
      return Icons.biotech_rounded;
    }

    if (value.contains('hostel')) {
      return Icons.bed_rounded;
    }

    if (value.contains('electronic')) {
      return Icons.devices_rounded;
    }

    if (value.contains('uniform') || value.contains('apron')) {
      return Icons.checkroom_rounded;
    }

    if (value.contains('sport')) {
      return Icons.sports_basketball_rounded;
    }

    return Icons.inventory_2_rounded;
  }

  Color _getCategoryAccentColor(String category) {
    final value = category.toLowerCase();

    if (value == 'all') {
      return const Color(0xFF6366F1);
    }

    if (value.contains('book') || value.contains('academic')) {
      return const Color(0xFF818CF8);
    }

    if (value.contains('calculator')) {
      return const Color(0xFF38BDF8);
    }

    if (value.contains('drawing') || value.contains('graphics')) {
      return const Color(0xFFA78BFA);
    }

    if (value.contains('lab')) {
      return const Color(0xFF2DD4BF);
    }

    if (value.contains('hostel')) {
      return const Color(0xFFFB923C);
    }

    if (value.contains('electronic')) {
      return const Color(0xFF60A5FA);
    }

    if (value.contains('uniform') || value.contains('apron')) {
      return const Color(0xFFF472B6);
    }

    if (value.contains('sport')) {
      return const Color(0xFFFB7185);
    }

    return const Color(0xFF818CF8);
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: accentColor.withValues(alpha: 0.15),
        highlightColor: accentColor.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 13 : 11,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.82),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : const Color(0xFF111936),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.09),
              width: isSelected ? 1.2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : accentColor,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                  letterSpacing: isSelected ? 0.1 : 0,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
