import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../domain/models/background_removal_result.dart';
import '../presentation/providers/background_removal_provider.dart';
import '../presentation/widgets/background_options_grid.dart';
import '../presentation/widgets/image_preview.dart';
import '../presentation/widgets/processing_overlay.dart';
import '../presentation/widgets/bottom_action_bar.dart';

class BackgroundRemovalScreen extends ConsumerStatefulWidget {
final String imagePath;

const BackgroundRemovalScreen({
  super.key,
  required this.imagePath,
});

@override
ConsumerState<BackgroundRemovalScreen> createState() => _BackgroundRemovalScreenState();
}

class _BackgroundRemovalScreenState extends ConsumerState<BackgroundRemovalScreen>
  with TickerProviderStateMixin {
late AnimationController _slideController;
late AnimationController _fadeController;
late Animation<Offset> _slideAnimation;
late Animation<double> _fadeAnimation;

BackgroundOption? _selectedBackground;
bool _showBackgroundOptions = false;

@override
void initState() {
  super.initState();
  
  _slideController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );
  
  _fadeController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeOutCubic,
  ));

  _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeOut,
  ));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _fadeController.forward();
  });

  // Auto-start with transparent background
  _selectedBackground = BackgroundOption.defaultOptions.first;
  _processImage();
}

@override
void dispose() {
  _slideController.dispose();
  _fadeController.dispose();
  super.dispose();
}

void _processImage() {
  if (_selectedBackground == null) return;

  ref.read(backgroundRemovalProvider.notifier).processImage(
    imagePath: widget.imagePath,
    backgroundOption: _selectedBackground!,
  );
}

void _toggleBackgroundOptions() {
  setState(() {
    _showBackgroundOptions = !_showBackgroundOptions;
  });

  if (_showBackgroundOptions) {
    _slideController.forward();
  } else {
    _slideController.reverse();
  }
}

@override
Widget build(BuildContext context) {
  final backgroundState = ref.watch(backgroundRemovalProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Scaffold(
    backgroundColor: AppColors.background,
    body: Stack(
      children: [
        // Main Content
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(context, colorScheme),

              // Image Preview
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ImagePreview(
                      originalImagePath: widget.imagePath,
                      processedImagePath: backgroundState.result?.processedImagePath,
                      isProcessing: backgroundState.isProcessing,
                    ),
                  ),
                ),
              ),

              // Background Selection Button
              _buildBackgroundToggle(colorScheme),

              // Bottom spacing for action bar
              const SizedBox(height: 80),
            ],
          ),
        ),

        // Background Options Panel
        SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BackgroundOptionsGrid(
                selectedOption: _selectedBackground,
                onOptionSelected: (option) {
                  setState(() {
                    _selectedBackground = option;
                  });
                  _processImage();
                },
                onClose: _toggleBackgroundOptions,
              ),
            ),
          ),
        ),

        // Processing Overlay
        if (backgroundState.isProcessing)
          ProcessingOverlay(
            progress: backgroundState.progress,
            currentStep: backgroundState.currentStep ?? 'Processing...',
          ),

        // Bottom Action Bar
        if (!backgroundState.isProcessing && backgroundState.result != null)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 24,
            right: 24,
            child: BottomActionBar(
              result: backgroundState.result!,
              onSave: () => _saveImage(),
              onShare: () => _shareImage(),
              onRetry: () => _processImage(),
            ),
          ),
      ],
    ),
  );
}

Widget _buildAppBar(BuildContext context, BusinessColorScheme colorScheme) {
  return Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 8,
      left: 24,
      right: 24,
      bottom: 16,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colorScheme.primary,
          colorScheme.primary.withOpacity(0.9),
        ],
      ),
    ),
    child: Row(
      children: [
        // Back Button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),

        const Spacer(),

        // Title
        Text(
          'Background Magic',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),

        const Spacer(),

        // Help Button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showHelpDialog(context),
              child: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildBackgroundToggle(BusinessColorScheme colorScheme) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _toggleBackgroundOptions,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Preview of selected background
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _selectedBackground?.color != null
                      ? Color(int.parse(_selectedBackground!.color!.replaceAll('#', '0xFF')))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.textTertiary,
                    width: 1,
                  ),
                ),
                child: _selectedBackground?.type == BackgroundType.transparent
                    ? Icon(
                        Icons.grid_on,
                        color: AppColors.textSecondary,
                        size: 16,
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Background',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _selectedBackground?.name ?? 'Select Background',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                _showBackgroundOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('Background Magic Help'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Tap "Background" to choose different options'),
          SizedBox(height: 8),
          Text('• Transparent background removes everything behind your product'),
          SizedBox(height: 8),
          Text('• Color backgrounds give your product a professional look'),
          SizedBox(height: 8),
          Text('• Processing usually takes 5-10 seconds'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it!'),
        ),
      ],
    ),
  );
}

void _saveImage() {
  // TODO: Implement save to gallery
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Image saved to gallery!')),
  );
}

void _shareImage() {
  // TODO: Implement sharing
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Share feature coming soon!')),
  );
}
}