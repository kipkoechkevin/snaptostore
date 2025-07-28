import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../providers/template_provider.dart';
import '../template_detail_screen.dart';
import '../../../../core/constants/business_types.dart';

class FeaturedTemplatesSection extends ConsumerWidget {
const FeaturedTemplatesSection({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final featuredTemplates = ref.watch(featuredTemplatesProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  if (featuredTemplates.isEmpty) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Featured Templates',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Show all featured templates
            },
            child: const Text('See All'),
          ),
        ],
      ),
      
      const SizedBox(height: 16),
      
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: featuredTemplates.length,
          itemBuilder: (context, index) {
            final template = featuredTemplates[index];
            return Container(
              width: 160,
              margin: EdgeInsets.only(
                right: index == featuredTemplates.length - 1 ? 0 : 16,
              ),
              child: _FeaturedTemplateCard(
                template: template,
                onTap: () => _navigateToTemplateDetail(context, template),
              ),
            );
          },
        ),
      ),
    ],
  );
}

void _navigateToTemplateDetail(BuildContext context, template) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TemplateDetailScreen(template: template),
    ),
  );
}
}

class _FeaturedTemplateCard extends ConsumerStatefulWidget {
final template;
final VoidCallback onTap;

const _FeaturedTemplateCard({
  required this.template,
  required this.onTap,
});

@override
ConsumerState<_FeaturedTemplateCard> createState() => _FeaturedTemplateCardState();
}

class _FeaturedTemplateCardState extends ConsumerState<_FeaturedTemplateCard>
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
  _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
                            
                            // Featured badge
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'FEATURED',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
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
                            _getBusinessTypeLabel(widget.template.businessType),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
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

String _getBusinessTypeLabel(BusinessType businessType) {
  switch (businessType) {
    case BusinessType.thrift:
      return 'Thrift';
    case BusinessType.boutique:
      return 'Boutique';
    case BusinessType.beauty:
      return 'Beauty';
    case BusinessType.handmade:
      return 'Handmade';
    case BusinessType.general:
      return 'General';
  }
}
}