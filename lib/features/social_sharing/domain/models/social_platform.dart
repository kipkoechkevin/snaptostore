import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SocialPlatformType {
instagram,
facebook,
tiktok,
pinterest,
twitter,
whatsapp,
}

class SocialPlatform extends Equatable {
final SocialPlatformType type;
final String name;
final String displayName;
final IconData icon;
final Color brandColor;
final List<ImageFormat> supportedFormats;
final ImageDimensions recommendedSize;
final String shareUrl;
final bool isInstalled;

const SocialPlatform({
  required this.type,
  required this.name,
  required this.displayName,
  required this.icon,
  required this.brandColor,
  required this.supportedFormats,
  required this.recommendedSize,
  required this.shareUrl,
  this.isInstalled = false,
});

@override
List<Object?> get props => [
  type, name, displayName, icon, brandColor, supportedFormats,
  recommendedSize, shareUrl, isInstalled,
];

static List<SocialPlatform> get allPlatforms => [
  const SocialPlatform(
    type: SocialPlatformType.instagram,
    name: 'instagram',
    displayName: 'Instagram',
    icon: Icons.camera_alt_rounded,
    brandColor: Color(0xFFE4405F),
    supportedFormats: [ImageFormat.jpg, ImageFormat.png],
    recommendedSize: ImageDimensions(1080, 1080), // ✅ Now works with const
    shareUrl: 'instagram://app',
  ),
  
  const SocialPlatform(
    type: SocialPlatformType.facebook,
    name: 'facebook',
    displayName: 'Facebook',
    icon: Icons.facebook,
    brandColor: Color(0xFF1877F2),
    supportedFormats: [ImageFormat.jpg, ImageFormat.png],
    recommendedSize: ImageDimensions(1200, 630), // ✅ Now works with const
    shareUrl: 'fb://facewebmodal/f?href=',
  ),
  
  const SocialPlatform(
    type: SocialPlatformType.tiktok,
    name: 'tiktok',
    displayName: 'TikTok',
    icon: Icons.music_note,
    brandColor: Color(0xFF000000),
    supportedFormats: [ImageFormat.jpg, ImageFormat.png],
    recommendedSize: ImageDimensions(1080, 1920), // ✅ Now works with const
    shareUrl: 'snssdk1233://share',
  ),
  
  const SocialPlatform(
    type: SocialPlatformType.pinterest,
    name: 'pinterest',
    displayName: 'Pinterest',
    icon: Icons.push_pin,
    brandColor: Color(0xFFBD081C),
    supportedFormats: [ImageFormat.jpg, ImageFormat.png],
    recommendedSize: ImageDimensions(1000, 1500), // ✅ Now works with const
    shareUrl: 'pinterest://pin',
  ),
  
  const SocialPlatform(
    type: SocialPlatformType.twitter,
    name: 'twitter',
    displayName: 'Twitter',
    icon: Icons.alternate_email,
    brandColor: Color(0xFF1DA1F2),
    supportedFormats: [ImageFormat.jpg, ImageFormat.png],
    recommendedSize: ImageDimensions(1200, 675), // ✅ Now works with const
    shareUrl: 'twitter://post?message=',
  ),
  
  const SocialPlatform(
    type: SocialPlatformType.whatsapp,
    name: 'whatsapp',
    displayName: 'WhatsApp',
    icon: Icons.message,
    brandColor: Color(0xFF25D366),
    supportedFormats: [ImageFormat.jpg, ImageFormat.png],
    recommendedSize: ImageDimensions(800, 800), // ✅ Now works with const
    shareUrl: 'whatsapp://send?text=',
  ),
];
}

enum ImageFormat {
jpg,
png,
webp,
}

class ImageDimensions extends Equatable {
final int width;
final int height;
final String aspectRatio;

// ✅ Made constructor const
const ImageDimensions(this.width, this.height)
    : aspectRatio = '${width}:${height}';

double get ratio => width / height;

@override
List<Object?> get props => [width, height, aspectRatio];
}

class ShareContent {
final String imagePath;
final String? caption;
final String? hashtags;
final String? url;
final Map<String, dynamic> metadata;

const ShareContent({
  required this.imagePath,
  this.caption,
  this.hashtags,
  this.url,
  this.metadata = const {},
});
}