import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../providers/template_provider.dart';
import '../widgets/template_detail_screen.dart';
import '../../../../core/constants/business_types.dart';


class TemplateGrid extends ConsumerWidget {
const TemplateGrid({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final templateState = ref.watch(templateProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  if (templateState.isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (templateState.error != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load templates',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            templateState.error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(templateProvider.notifier).loadTemplates();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  if (templateState.filteredTemplates.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No templates found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              ref.read(templateProvider.notifier).clearFilters();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  return GridView.builder(
    padding: const EdgeInsets.all(24),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.8,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    itemCount: templateState.filteredTemplates.length,
    itemBuilder: (context, index) {
      final template = templateState.filteredTemplates[index];
      return _TemplateCard(
        template: template,
        onTap: () => _navigateToTemplateDetail(context, ref, template),
      );
    },
  );
}

void _navigateToTemplateDetail(BuildContext context, WidgetRef ref, template) {
  ref.read(templateProvider.notifier).selectTemplate(template);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TemplateDetailScreen(template: template),
    ),
  );
}
}

class _TemplateCard extends ConsumerStatefulWidget {
final template;
final VoidCallback onTap;

const _TemplateCard({
  required this.template,
  required this.onTap,
});

@override
ConsumerState<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends ConsumerState<_TemplateCard>
  with SingleTickerProviderStateMixin {
late AnimationController _hoverController;
late Animation<double> _scaleAnimation;

@override
void initState() {
  super.initState();
  _hoverController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
    CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
  );
}

@override
void dispose() {
  _hoverController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  
  return AnimatedBuilder(
    animation: _hoverController,
    builder: (context, child) {
      return Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              onTapDown: (_) => _hoverController.forward(),
              onTapUp: (_) => _hoverController.reverse(),
              onTapCancel: () => _hoverController.reverse(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Template Preview
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: _getTemplateGradient(widget.template.businessType),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Template preview placeholder
                            Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.white.withOpacity(0.8),
                                size: 48,
                              ),
                            ),
                            
                            // Badges
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (widget.template.isPremium)
                                    _buildBadge('PRO', AppColors.warning),
                                  if (widget.template.isPopular) ...[
                                    const SizedBox(height: 4),
                                    _buildBadge('POPULAR', AppColors.success),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Template Info
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.template.name,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.template.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.template.usageCount}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildBadge(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 9,
      ),
    ),
  );
}

LinearGradient _getTemplateGradient(BusinessType businessType) {
  switch (businessType) {
    case BusinessType.thrift:
      return const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
      );
    case BusinessType.boutique:
      return const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      );
    case BusinessType.beauty:
      return const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
      );
    case BusinessType.handmade:
      return const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF34D399)],
      );
    case BusinessType.general:
      return const LinearGradient(
        colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
      );
  }
}
}