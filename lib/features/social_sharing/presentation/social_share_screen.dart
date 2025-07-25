import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../domain/models/social_platform.dart';
import '../domain/models/share_result.dart';
import 'providers/social_sharing_provider.dart';
import 'widgets/platform_selection_grid.dart';
import 'widgets/image_preview_card.dart';
import 'widgets/share_customization_panel.dart';
import 'widgets/share_success_dialog.dart';

class SocialShareScreen extends ConsumerStatefulWidget {
final String imagePath;
final String? defaultCaption;

const SocialShareScreen({
  super.key,
  required this.imagePath,
  this.defaultCaption,
});

@override
ConsumerState<SocialShareScreen> createState() => _SocialShareScreenState();
}

class _SocialShareScreenState extends ConsumerState<SocialShareScreen>
  with TickerProviderStateMixin {
late AnimationController _slideController;
late AnimationController _fadeController;
late Animation<Offset> _slideAnimation;
late Animation<double> _fadeAnimation;

SocialPlatform? _selectedPlatform;
String _caption = '';
bool _showCustomization = false;

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

  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
  );

  _caption = widget.defaultCaption ?? '';
  _fadeController.forward();
}

@override
void dispose() {
  _slideController.dispose();
  _fadeController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final sharingState = ref.watch(socialSharingProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  // Listen for share results
  ref.listen<SocialSharingState>(socialSharingProvider, (previous, next) {
    if (next.lastShareResult != null && next.lastShareResult!.isSuccess) {
      _showShareSuccessDialog(next.lastShareResult!);
    } else if (next.lastShareResult != null && !next.lastShareResult!.isSuccess) {
      _showShareErrorDialog(next.lastShareResult!);
    }
  });

  return Scaffold(
    backgroundColor: AppColors.background,
    body: Stack(
      children: [
        // Main Content
        FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildAppBar(context, colorScheme),

              // Image Preview
              SliverToBoxAdapter(
                child: ImagePreviewCard(
                  imagePath: widget.imagePath,
                  selectedPlatform: _selectedPlatform,
                ),
              ),

              // Platform Selection
              SliverToBoxAdapter(
                child: PlatformSelectionGrid(
                  selectedPlatform: _selectedPlatform,
                  onPlatformSelected: (platform) {
                    setState(() {
                      _selectedPlatform = platform;
                      _showCustomization = true;
                    });
                    _slideController.forward();
                  },
                ),
              ),

              // Quick Share Buttons
              SliverToBoxAdapter(
                child: _buildQuickShareButtons(sharingState),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        ),

        // Customization Panel
        if (_showCustomization)
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ShareCustomizationPanel(
                platform: _selectedPlatform!,
                imagePath: widget.imagePath,
                initialCaption: _caption,
                onShare: _handleShare,
                onClose: () {
                  _slideController.reverse().then((_) {
                    setState(() {
                      _showCustomization = false;
                      _selectedPlatform = null;
                    });
                  });
                },
              ),
            ),
          ),

        // Loading Overlay
        if (sharingState.isSharing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Sharing to ${_selectedPlatform?.displayName ?? 'Platform'}...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildAppBar(BuildContext context, BusinessColorScheme colorScheme) {
  return SliverAppBar(
    expandedHeight: 100,
    floating: false,
    pinned: true,
    backgroundColor: colorScheme.primary,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: colorScheme.gradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Share Your Creation',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose your platform and customize your post',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ),
    leading: IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.help_outline, color: Colors.white),
        onPressed: () => _showHelpDialog(context),
      ),
    ],
  );
}

Widget _buildQuickShareButtons(SocialSharingState sharingState) {
  return Container(
    margin: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickShareButton(
                title: 'Share Everywhere',
                icon: Icons.share_rounded,
                color: AppColors.primary,
                onTap: () => _handleQuickShare('generic'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickShareButton(
                title: 'Save to Gallery',
                icon: Icons.download_rounded,
                color: AppColors.accent,
                onTap: () => _saveToGallery(),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _handleShare({
  required SocialPlatform platform,
  required String caption,
  String? url,
}) async {
  setState(() {
    _caption = caption;
  });

  switch (platform.type) {
    case SocialPlatformType.instagram:
      await ref.read(socialSharingProvider.notifier).shareToInstagram(
        imagePath: widget.imagePath,
        caption: caption,
      );
      break;
    case SocialPlatformType.facebook:
      await ref.read(socialSharingProvider.notifier).shareToFacebook(
        imagePath: widget.imagePath,
        caption: caption,
        url: url,
      );
      break;
    case SocialPlatformType.pinterest:
      await ref.read(socialSharingProvider.notifier).shareToPinterest(
        imagePath: widget.imagePath,
        description: caption,
        url: url,
      );
      break;
    default:
      await ref.read(socialSharingProvider.notifier).shareGeneric(
        imagePath: widget.imagePath,
        text: caption,
      );
  }
}

Future<void> _handleQuickShare(String type) async {
  await ref.read(socialSharingProvider.notifier).shareGeneric(
    imagePath: widget.imagePath,
    text: _caption,
  );
}

void _saveToGallery() {
  // TODO: Implement save to gallery
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Image saved to gallery!')),
  );
}

void _showShareSuccessDialog(ShareResult result) {
  showDialog(
    context: context,
    builder: (context) => ShareSuccessDialog(result: result),
  );
}

void _showShareErrorDialog(ShareResult result) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Share Failed'),
      content: Text(result.error ?? 'An unknown error occurred'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void _showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sharing Help'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Choose a platform to customize your post'),
          SizedBox(height: 8),
          Text('• Images are automatically optimized for each platform'),
          SizedBox(height: 8),
          Text('• Add captions and hashtags for better reach'),
          SizedBox(height: 8),
          Text('• Use "Share Everywhere" for quick sharing to multiple platforms'),
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
}

class _QuickShareButton extends StatelessWidget {
final String title;
final IconData icon;
final Color color;
final VoidCallback onTap;

const _QuickShareButton({
  required this.title,
  required this.icon,
  required this.color,
  required this.onTap,
});

@override
Widget build(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
}