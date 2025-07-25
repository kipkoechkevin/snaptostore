import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../domain/models/social_platform.dart';
import '../providers/social_sharing_provider.dart';

class ShareCustomizationPanel extends ConsumerStatefulWidget {
final SocialPlatform platform;
final String imagePath;
final String initialCaption;
final Function({
  required SocialPlatform platform,
  required String caption,
  String? url,
}) onShare;
final VoidCallback onClose;

const ShareCustomizationPanel({
  super.key,
  required this.platform,
  required this.imagePath,
  required this.initialCaption,
  required this.onShare,
  required this.onClose,
});

@override
ConsumerState<ShareCustomizationPanel> createState() => _ShareCustomizationPanelState();
}

class _ShareCustomizationPanelState extends ConsumerState<ShareCustomizationPanel> {
late TextEditingController _captionController;
late TextEditingController _urlController;

@override
void initState() {
  super.initState();
  _captionController = TextEditingController(text: widget.initialCaption);
  _urlController = TextEditingController();
}

@override
void dispose() {
  _captionController.dispose();
  _urlController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  final isSharing = ref.watch(isSharingProvider);

  return Container(
    height: MediaQuery.of(context).size.height * 0.6,
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
    child: Column(
      children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.platform.brandColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.platform.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share to ${widget.platform.displayName}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Customize your post',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ),

        // Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption field
                Text(
                  _getCaptionLabel(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: _getCaptionHint(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.platform.brandColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // URL field (for Facebook, Pinterest)
                if (_needsUrlField())
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Website URL (Optional)',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: 'https://yourstore.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: widget.platform.brandColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Hashtag suggestions
                _buildHashtagSuggestions(),

                const SizedBox(height: 24),

                // Platform tips
                _buildPlatformTips(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Share button
        Container(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSharing ? null : _handleShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.platform.brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSharing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Share to ${widget.platform.displayName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    ),
  );
}

String _getCaptionLabel() {
  switch (widget.platform.type) {
    case SocialPlatformType.pinterest:
      return 'Description';
    case SocialPlatformType.twitter:
      return 'Tweet';
    default:
      return 'Caption';
  }
}

String _getCaptionHint() {
  switch (widget.platform.type) {
    case SocialPlatformType.instagram:
      return 'Write a caption... #hashtags #work #great';
    case SocialPlatformType.facebook:
      return 'What\'s on your mind?';
    case SocialPlatformType.pinterest:
      return 'Describe your pin...';
    case SocialPlatformType.twitter:
      return 'What\'s happening?';
    default:
      return 'Write something...';
  }
}

bool _needsUrlField() {
  return widget.platform.type == SocialPlatformType.facebook ||
         widget.platform.type == SocialPlatformType.pinterest;
}

Widget _buildHashtagSuggestions() {
  final suggestions = _getHashtagSuggestions();
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Suggested Hashtags',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions.map((hashtag) {
          return GestureDetector(
            onTap: () => _addHashtag(hashtag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.platform.brandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.platform.brandColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                hashtag,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: widget.platform.brandColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

Widget _buildPlatformTips() {
  final tips = _getPlatformTips();
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.info.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.info,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.platform.displayName} Tips',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '• $tip',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.info,
            ),
          ),
        )),
      ],
    ),
  );
}

List<String> _getHashtagSuggestions() {
  switch (widget.platform.type) {
    case SocialPlatformType.instagram:
      return ['#smallbusiness', '#handmade', '#forsale', '#boutique', '#style'];
    case SocialPlatformType.facebook:
      return ['#business', '#sale', '#local', '#shop', '#deals'];
    case SocialPlatformType.pinterest:
      return ['#diy', '#style', '#fashion', '#home', '#inspiration'];
    case SocialPlatformType.twitter:
      return ['#smallbiz', '#entrepreneur', '#sale', '#deals'];
    default:
      return ['#business', '#sale', '#shop'];
  }
}

List<String> _getPlatformTips() {
  switch (widget.platform.type) {
    case SocialPlatformType.instagram:
      return [
        'Use 3-5 relevant hashtags',
        'Post during peak hours (6-9 PM)',
        'Engage with comments quickly',
      ];
    case SocialPlatformType.facebook:
      return [
        'Ask questions to boost engagement',
        'Include a website link',
        'Post when your audience is most active',
      ];
    case SocialPlatformType.pinterest:
      return [
        'Use descriptive, keyword-rich descriptions',
        'Add your website URL',
        'Pin to relevant boards',
      ];
    case SocialPlatformType.twitter:
      return [
        'Keep it concise and engaging',
        'Use trending hashtags',
        'Include a call-to-action',
      ];
    default:
      return ['Add relevant hashtags', 'Keep content engaging'];
  }
}

void _addHashtag(String hashtag) {
  final currentText = _captionController.text;
  final newText = currentText.isEmpty ? hashtag : '$currentText $hashtag';
  _captionController.text = newText;
}

void _handleShare() {
  widget.onShare(
    platform: widget.platform,
    caption: _captionController.text,
    url: _urlController.text.isNotEmpty ? _urlController.text : null,
  );
}
}