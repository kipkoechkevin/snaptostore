import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/background_removal_result.dart';
import '../../domain/models/remove_bg_response.dart';
import 'remove_bg_service.dart';

class BackgroundProcessor {
final RemoveBgService _removeBgService;

BackgroundProcessor() : _removeBgService = RemoveBgService();

Future<BackgroundRemovalResult> processImage({
required String imagePath,
required BackgroundOption backgroundOption,
}) async {
final stopwatch = Stopwatch()..start();

try {
  print('Starting background processing...');
  
  // ✅ Cleanup old files first
  await _removeBgService.cleanupTempFiles();
  
  // ✅ Add delay to ensure camera resources are freed
  await Future.delayed(const Duration(milliseconds: 200));
  
  // Step 1: Remove background
  final removeBgResult = await _removeBgService.removeBackground(
    imagePath: imagePath,
  );
  
  if (!removeBgResult.success) {
    return BackgroundRemovalResult(
      originalImagePath: imagePath,
      processedImagePath: '',
      backgroundType: backgroundOption.type,
      processingTimeMs: stopwatch.elapsedMilliseconds,
      isSuccess: false,
      error: removeBgResult.error,
    );
  }
  
  // ✅ Add delay between operations
  await Future.delayed(const Duration(milliseconds: 100));
  
  // Step 2: Save background-removed image
  final transparentImagePath = await _removeBgService.saveProcessedImage(
    removeBgResult.imageData!,
  );
  
  // ✅ Add delay before background application
  await Future.delayed(const Duration(milliseconds: 100));
  
  // Step 3: Apply new background if needed
  String finalImagePath = transparentImagePath;
  
  if (backgroundOption.type != BackgroundType.transparent) {
    finalImagePath = await _applyBackground(
      transparentImagePath,
      backgroundOption,
    );
  }
  
  stopwatch.stop();
  print('Background processing completed in ${stopwatch.elapsedMilliseconds}ms');
  
  return BackgroundRemovalResult(
    originalImagePath: imagePath,
    processedImagePath: finalImagePath,
    backgroundType: backgroundOption.type,
    backgroundColor: backgroundOption.color,
    backgroundImagePath: backgroundOption.imagePath,
    processingTimeMs: stopwatch.elapsedMilliseconds,
    isSuccess: true,
  );
  
} catch (e) {
  stopwatch.stop();
  print('Background processing error: $e');
  return BackgroundRemovalResult(
    originalImagePath: imagePath,
    processedImagePath: '',
    backgroundType: backgroundOption.type,
    processingTimeMs: stopwatch.elapsedMilliseconds,
    isSuccess: false,
    error: e.toString(),
  );
}
}

Future<String> _applyBackground(
  String transparentImagePath,
  BackgroundOption backgroundOption,
) async {
  try {
    final transparentImage = img.decodeImage(
      await File(transparentImagePath).readAsBytes(),
    );
    
    if (transparentImage == null) {
      throw Exception('Failed to decode transparent image');
    }
    
    late img.Image backgroundImage;
    
    switch (backgroundOption.type) {
      case BackgroundType.solidColor:
        backgroundImage = _createSolidColorBackground(
          transparentImage.width,
          transparentImage.height,
          backgroundOption.color!,
        );
        break;
        
      case BackgroundType.gradient:
        backgroundImage = await _createGradientBackground(
          transparentImage.width,
          transparentImage.height,
          backgroundOption.colors!,
        );
        break;
        
      case BackgroundType.customImage:
        backgroundImage = await _loadCustomBackground(
          transparentImage.width,
          transparentImage.height,
          backgroundOption.imagePath!,
        );
        break;
        
      default:
        throw Exception('Unsupported background type');
    }
    
    // Composite the images
    final compositeImage = img.compositeImage(
      backgroundImage,
      transparentImage,
    );
    
    // Save the final image
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'final_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = path.join(directory.path, fileName);
    
    await File(filePath).writeAsBytes(img.encodePng(compositeImage));
    
    return filePath;
    
  } catch (e) {
    throw Exception('Failed to apply background: $e');
  }
}

img.Image _createSolidColorBackground(int width, int height, String colorHex) {
  final color = _hexToColor(colorHex);
  final background = img.Image(width: width, height: height);
  img.fill(background, color: img.ColorRgb8(color.red, color.green, color.blue));
  return background;
}

Future<img.Image> _createGradientBackground(
  int width,
  int height,
  List<String> colors,
) async {
  // Create a gradient background using Canvas
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  final gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colors.map((c) => _hexToColor(c)).toList(),
  );
  
  final paint = Paint()
    ..shader = gradient.createShader(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
  
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    paint,
  );
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  return img.decodeImage(byteData!.buffer.asUint8List())!;
}

Future<img.Image> _loadCustomBackground(
  int width,
  int height,
  String imagePath,
) async {
  final backgroundBytes = await File(imagePath).readAsBytes();
  final backgroundImage = img.decodeImage(backgroundBytes);
  
  if (backgroundImage == null) {
    throw Exception('Failed to load custom background');
  }
  
  // Resize to match the foreground image
  return img.copyResize(
    backgroundImage,
    width: width,
    height: height,
    interpolation: img.Interpolation.cubic,
  );
}

Color _hexToColor(String hex) {
  final hexColor = hex.replaceAll('#', '');
  return Color(int.parse('FF$hexColor', radix: 16));
}
}