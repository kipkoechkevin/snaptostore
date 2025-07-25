import 'dart:io';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' as share_plus; // ✅ Add prefix
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../../domain/models/social_platform.dart';
import '../../domain/models/share_result.dart';

class SocialSharingService {
static const MethodChannel _channel = MethodChannel('social_sharing');

Future<List<SocialPlatform>> getInstalledPlatforms() async {
  try {
    final installedApps = await _channel.invokeMethod<List<String>>('getInstalledApps');
    
    return SocialPlatform.allPlatforms.map((platform) {
      final isInstalled = installedApps?.contains(platform.name) ?? false;
      return SocialPlatform(
        type: platform.type,
        name: platform.name,
        displayName: platform.displayName,
        icon: platform.icon,
        brandColor: platform.brandColor,
        supportedFormats: platform.supportedFormats,
        recommendedSize: platform.recommendedSize,
        shareUrl: platform.shareUrl,
        isInstalled: isInstalled,
      );
    }).toList();
  } catch (e) {
    // Fallback: return all platforms without installation check
    return SocialPlatform.allPlatforms;
  }
}

Future<ShareResult> shareToInstagram({
  required String imagePath,
  String? caption,
}) async {
  try {
    // Optimize image for Instagram (1080x1080)
    final optimizedPath = await _optimizeImageForPlatform(
      imagePath,
      SocialPlatformType.instagram,
    );

    if (Platform.isIOS) {
      return await _shareToInstagramIOS(optimizedPath, caption);
    } else {
      return await _shareToInstagramAndroid(optimizedPath, caption);
    }
  } catch (e) {
    return ShareResult(
      platform: SocialPlatformType.instagram,
      isSuccess: false,
      error: e.toString(),
      timestamp: DateTime.now(),
    );
  }
}

Future<ShareResult> shareToFacebook({
  required String imagePath,
  String? caption,
  String? url,
}) async {
  try {
    final optimizedPath = await _optimizeImageForPlatform(
      imagePath,
      SocialPlatformType.facebook,
    );

    final shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url ?? '')}';
    
    if (await canLaunchUrl(Uri.parse('fb://facewebmodal/f?href=$shareUrl'))) {
      await launchUrl(Uri.parse('fb://facewebmodal/f?href=$shareUrl'));
    } else {
      await launchUrl(Uri.parse(shareUrl));
    }

    return ShareResult(
      platform: SocialPlatformType.facebook,
      isSuccess: true,
      timestamp: DateTime.now(),
      metadata: {'optimized_image': optimizedPath},
    );
  } catch (e) {
    return ShareResult(
      platform: SocialPlatformType.facebook,
      isSuccess: false,
      error: e.toString(),
      timestamp: DateTime.now(),
    );
  }
}

Future<ShareResult> shareToPinterest({
  required String imagePath,
  String? description,
  String? url,
}) async {
  try {
    final optimizedPath = await _optimizeImageForPlatform(
      imagePath,
      SocialPlatformType.pinterest,
    );

    // Pinterest requires uploading the image first, then sharing
    // This is a simplified version - in production you'd upload to your server
    final shareUrl = 'https://pinterest.com/pin/create/button/'
        '?url=${Uri.encodeComponent(url ?? '')}'
        '&description=${Uri.encodeComponent(description ?? '')}';

    if (await canLaunchUrl(Uri.parse('pinterest://pin'))) {
      await launchUrl(Uri.parse('pinterest://pin'));
    } else {
      await launchUrl(Uri.parse(shareUrl));
    }

    return ShareResult(
      platform: SocialPlatformType.pinterest,
      isSuccess: true,
      timestamp: DateTime.now(),
      metadata: {'optimized_image': optimizedPath},
    );
  } catch (e) {
    return ShareResult(
      platform: SocialPlatformType.pinterest,
      isSuccess: false,
      error: e.toString(),
      timestamp: DateTime.now(),
    );
  }
}

Future<ShareResult> shareGeneric({
  required String imagePath,
  String? text,
}) async {
  try {
    // ✅ Use prefixed import for share_plus
    final result = await share_plus.Share.shareXFiles(
      [share_plus.XFile(imagePath)],
      text: text,
    );

    return ShareResult(
      platform: SocialPlatformType.whatsapp, // Generic share
      isSuccess: result.status == share_plus.ShareResultStatus.success, // ✅ Use prefixed enum
      timestamp: DateTime.now(),
      metadata: {'result': result.status.toString()},
    );
  } catch (e) {
    return ShareResult(
      platform: SocialPlatformType.whatsapp,
      isSuccess: false,
      error: e.toString(),
      timestamp: DateTime.now(),
    );
  }
}

Future<String> _optimizeImageForPlatform(
  String imagePath,
  SocialPlatformType platform,
) async {
  try {
    final originalImage = img.decodeImage(await File(imagePath).readAsBytes());
    if (originalImage == null) return imagePath;

    final platformData = SocialPlatform.allPlatforms
        .firstWhere((p) => p.type == platform);

    // Resize image to platform's recommended dimensions
    final resizedImage = img.copyResize(
      originalImage,
      width: platformData.recommendedSize.width,
      height: platformData.recommendedSize.height,
      interpolation: img.Interpolation.cubic,
    );

    // Save optimized image
    final directory = await getTemporaryDirectory();
    final optimizedPath = '${directory.path}/optimized_${platform.name}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    await File(optimizedPath).writeAsBytes(img.encodeJpg(resizedImage, quality: 85));
    
    return optimizedPath;
  } catch (e) {
    return imagePath; // Return original if optimization fails
  }
}

Future<ShareResult> _shareToInstagramIOS(String imagePath, String? caption) async {
  try {
    await _channel.invokeMethod('shareToInstagramIOS', {
      'imagePath': imagePath,
      'caption': caption ?? '',
    });

    return ShareResult(
      platform: SocialPlatformType.instagram,
      isSuccess: true,
      timestamp: DateTime.now(),
    );
  } catch (e) {
    return ShareResult(
      platform: SocialPlatformType.instagram,
      isSuccess: false,
      error: e.toString(),
      timestamp: DateTime.now(),
    );
  }
}

Future<ShareResult> _shareToInstagramAndroid(String imagePath, String? caption) async {
  try {
    await _channel.invokeMethod('shareToInstagramAndroid', {
      'imagePath': imagePath,
      'caption': caption ?? '',
    });

    return ShareResult(
      platform: SocialPlatformType.instagram,
      isSuccess: true,
      timestamp: DateTime.now(),
    );
  } catch (e) {
    return ShareResult(
      platform: SocialPlatformType.instagram,
      isSuccess: false,
      error: e.toString(),
      timestamp: DateTime.now(),
    );
  }
}
}