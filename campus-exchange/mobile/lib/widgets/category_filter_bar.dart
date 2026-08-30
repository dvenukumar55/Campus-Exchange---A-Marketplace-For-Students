import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

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
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          final catIcon = _getCategoryIcon(cat);

          return InkWell(
            onTap: () => onSelected(cat),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.secondaryColor : AppTheme.dividerColor,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    catIcon,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final value = category.toLowerCase();
    if (value == 'all') return Icons.grid_view_rounded;
    if (value.contains('book') || value.contains('academic')) return Icons.menu_book_rounded;
    if (value.contains('calculator')) return Icons.calculate_rounded;
    if (value.contains('drawing') || value.contains('graphics')) return Icons.architecture_rounded;
    if (value.contains('lab')) return Icons.biotech_rounded;
    if (value.contains('hostel')) return Icons.bed_rounded;
    if (value.contains('electronic')) return Icons.devices_rounded;
    if (value.contains('uniform') || value.contains('apron')) return Icons.checkroom_rounded;
    if (value.contains('sport')) return Icons.sports_basketball_rounded;
    return Icons.inventory_2_rounded;
  }
}
