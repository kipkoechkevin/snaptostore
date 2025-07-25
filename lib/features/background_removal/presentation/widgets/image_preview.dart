import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import 'checkered_background_painter.dart'; // ✅ Use shared painter

class ImagePreview extends ConsumerStatefulWidget {
final String originalImagePath;
final String? processedImagePath;
final bool isProcessing;

const ImagePreview({
  super.key,
  required this.originalImagePath,
  this.processedImagePath,
  this.isProcessing = false,
});

@override
ConsumerState<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends ConsumerState<ImagePreview>
  with SingleTickerProviderStateMixin {
late AnimationController _flipController;
late Animation<double> _flipAnimation;
bool _showOriginal = false;

@override
void initState() {
  super.initState();
  _flipController = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );
  _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
  );
}

@override
void dispose() {
  _flipController.dispose();
  super.dispose();
}

void _toggleView() {
  setState(() {
    _showOriginal = !_showOriginal;
  });
  
  if (_showOriginal) {
    _flipController.forward();
  } else {
    _flipController.reverse();
  }
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Stack(
      children: [
        // Main Image Display
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: widget.isProcessing
                ? _buildProcessingState(colorScheme)
                : _buildImageDisplay(),
          ),
        ),

        // Compare Button
        if (widget.processedImagePath != null && !widget.isProcessing)
          Positioned(
            top: 16,
            right: 16,
            child: _buildCompareButton(colorScheme),
          ),

        // Image Info
        if (widget.processedImagePath != null && !widget.isProcessing)
          Positioned(
            bottom: 16,
            left: 16,
            child: _buildImageInfo(),
          ),
      ],
    ),
  );
}

Widget _buildImageDisplay() {
  return AnimatedBuilder(
    animation: _flipAnimation,
    builder: (context, child) {
      final isShowingFront = _flipAnimation.value < 0.5;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(_flipAnimation.value * 3.14159),
        child: isShowingFront
            ? _buildProcessedImage()
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(3.14159),
                child: _buildOriginalImage(),
              ),
      );
    },
  );
}

Widget _buildProcessedImage() {
  if (widget.processedImagePath == null) {
    return _buildPlaceholder();
  }

  return Stack(
    children: [
      // Checkered background for transparency
      _buildTransparencyBackground(),
      
      // Processed image
      Positioned.fill(
        child: Image.file(
          File(widget.processedImagePath!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorState();
          },
        ),
      ),
    ],
  );
}

Widget _buildOriginalImage() {
  return Image.file(
    File(widget.originalImagePath),
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return _buildErrorState();
    },
  );
}

Widget _buildTransparencyBackground() {
  return CustomPaint(
    painter: CheckeredBackgroundPainter(), // ✅ Now using shared painter
    child: Container(),
  );
}

Widget _buildProcessingState(BusinessColorScheme colorScheme) {
return Container(
  decoration: BoxDecoration(
    // ✅ Create new LinearGradient instead of using copyWith
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primary.withOpacity(0.1),
        colorScheme.primary.withOpacity(0.05),
      ],
    ),
  ),
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Processing...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  ),
);
}

Widget _buildPlaceholder() {
  return Container(
    color: AppColors.surfaceVariant,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Choose a background to preview',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorState() {
  return Container(
    color: AppColors.error.withOpacity(0.1),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCompareButton(BusinessColorScheme colorScheme) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _toggleView,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.compare_arrows,
                color: colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                _showOriginal ? 'Processed' : 'Original',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildImageInfo() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          'Background Removed',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
}