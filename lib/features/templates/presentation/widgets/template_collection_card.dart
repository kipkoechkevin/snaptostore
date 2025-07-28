import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../domain/models/template_collection.dart';
import '../../../../core/constants/business_types.dart';

class TemplateCollectionCard extends ConsumerStatefulWidget {
final TemplateCollection collection;
final VoidCallback onTap;

const TemplateCollectionCard({
  super.key,
  required this.collection,
  required this.onTap,
});

@override
ConsumerState<TemplateCollectionCard> createState() => _TemplateCollectionCardState();
}

class _TemplateCollectionCardState extends ConsumerState<TemplateCollectionCard>
  with SingleTickerProviderStateMixin {
late AnimationController _hoverController;
late Animation<double> _scaleAnimation;
late Animation<double> _shadowAnimation;

@override
void initState() {
  super.initState();
  _hoverController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
    CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
  );
  _shadowAnimation = Tween<double>(begin: 0.1, end: 0.2).animate(
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
  
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_shadowAnimation.value),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                onTapDown: (_) => _hoverController.forward(),
                onTapUp: (_) => _hoverController.reverse(),
                onTapCancel: () => _hoverController.reverse(),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: _getBusinessGradient(widget.collection.businessType),
                  ),
                  child: Row(
                    children: [
                      // Content Section
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20), // ✅ Reduced padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ Changed from center
                            children: [
                              // Title and badges section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and badges
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.collection.name,
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16, // ✅ Reduced font size
                                          ),
                                          maxLines: 1, // ✅ Added maxLines
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Badges
                                      if (widget.collection.isNew) ...[
                                        const SizedBox(width: 6), // ✅ Reduced spacing
                                        _buildBadge('NEW', AppColors.success),
                                      ],
                                      if (widget.collection.isPremium) ...[
                                        const SizedBox(width: 6), // ✅ Reduced spacing
                                        _buildBadge('PRO', AppColors.warning),
                                      ],
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 4), // ✅ Reduced height
                                  
                                  // Description
                                  Text(
                                    widget.collection.description,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12, // ✅ Reduced font size
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              
                              // Template count (bottom section)
                              Row(
                                children: [
                                  Icon(
                                    Icons.collections_outlined,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 14, // ✅ Reduced icon size
                                  ),
                                  const SizedBox(width: 4), // ✅ Reduced spacing
                                  Text(
                                    '${widget.collection.templateCount} templates',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11, // ✅ Reduced font size
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Preview Section
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // Template preview thumbnails
                                _buildTemplatePreview(),
                                
                                // Arrow indicator
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    ),
  );
}

Widget _buildBadge(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // ✅ Reduced padding
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 9, // ✅ Reduced font size
      ),
    ),
  );
}

Widget _buildTemplatePreview() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getBusinessIcon(widget.collection.businessType),
            color: Colors.white.withOpacity(0.8),
            size: 28, // ✅ Reduced icon size
          ),
          const SizedBox(height: 6), // ✅ Reduced spacing
          Text(
            '${widget.collection.templateCount}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16, // ✅ Reduced font size
            ),
          ),
        ],
      ),
    ),
  );
}

LinearGradient _getBusinessGradient(BusinessType businessType) {
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

IconData _getBusinessIcon(BusinessType businessType) {
  switch (businessType) {
    case BusinessType.thrift:
      return Icons.shopping_bag_outlined;
    case BusinessType.boutique:
      return Icons.store_outlined;
    case BusinessType.beauty:
      return Icons.face_retouching_natural;
    case BusinessType.handmade:
      return Icons.palette_outlined;
    case BusinessType.general:
      return Icons.collections_outlined;
  }
}
}