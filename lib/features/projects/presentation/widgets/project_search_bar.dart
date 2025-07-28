import 'package:flutter/material.dart';
import 'package:snaptostore/core/theme/app_colors.dart';

class ProjectSearchBar extends StatelessWidget {
final String? hintText;
final Function(String) onChanged;
final VoidCallback? onClear;

const ProjectSearchBar({
  super.key,
  this.hintText,
  required this.onChanged,
  this.onClear,
});

@override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search projects...',
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textTertiary,
          size: 20,
        ),
        suffixIcon: onClear != null
            ? IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
  );
}
}