import 'package:flutter/material.dart';
import 'package:snaptostore/core/theme/app_colors.dart';

enum ProjectFilter {
all('All'),
drafts('Drafts'),
completed('Completed'),
recent('Recent'),
favorites('Favorites'),
archived('Archived');

const ProjectFilter(this.label);
final String label;
}

class ProjectFilters extends StatelessWidget {
final ProjectFilter selectedFilter;
final Function(ProjectFilter) onFilterChanged;

const ProjectFilters({
  super.key,
  required this.selectedFilter,
  required this.onFilterChanged,
});

@override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: ProjectFilter.values.map((filter) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildFilterChip(filter),
        );
      }).toList(),
    ),
  );
}

Widget _buildFilterChip(ProjectFilter filter) {
  final isSelected = filter == selectedFilter;
  
  return FilterChip(
    label: Text(filter.label),
    selected: isSelected,
    onSelected: (selected) => onFilterChanged(filter),
    selectedColor: AppColors.primary.withOpacity(0.1),
    backgroundColor: AppColors.surfaceVariant,
    labelStyle: TextStyle(
      color: isSelected ? AppColors.primary : AppColors.textSecondary,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      fontSize: 13,
    ),
    side: BorderSide(
      color: isSelected ? AppColors.primary : Colors.transparent,
      width: 1.5,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}
}