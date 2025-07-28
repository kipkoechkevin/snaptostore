import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../../../templates/domain/models/template_model.dart';
import '../../domain/models/template_application_result.dart';
import '../../domain/models/template_editor_state.dart';

class TemplateApplicationService {
Future<TemplateApplicationResult> applyTemplate({
  required String imagePath,
  required TemplateModel template,
  required Map<String, dynamic> config,
  List<EditableElement> customElements = const [],
}) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    // Load the original image
    final originalImage = img.decodeImage(await File(imagePath).readAsBytes());
    if (originalImage == null) {
      throw Exception('Failed to load original image');
    }

    // Create the composite image with template
    final compositeImage = await _createCompositeImage(
      originalImage,
      template,
      config,
      customElements,
    );

    // Save the final image
    final finalImagePath = await _saveFinalImage(compositeImage, template.id);

    stopwatch.stop();

    return TemplateApplicationResult(
      originalImagePath: imagePath,
      templateId: template.id,
      finalImagePath: finalImagePath,
      isSuccess: true,
      processingTimeMs: stopwatch.elapsedMilliseconds,
      appliedConfig: config,
    );
  } catch (e) {
    stopwatch.stop();
    
    return TemplateApplicationResult(
      originalImagePath: imagePath,
      templateId: template.id,
      finalImagePath: '',
      isSuccess: false,
      error: e.toString(),
      processingTimeMs: stopwatch.elapsedMilliseconds,
    );
  }
}

Future<img.Image> _createCompositeImage(
  img.Image originalImage,
  TemplateModel template,
  Map<String, dynamic> config,
  List<EditableElement> customElements,
) async {
  // Start with the original image as base
  final compositeImage = img.copyResize(
    originalImage,
    width: 1080,
    height: 1080,
  );

  // Apply template background if specified
  await _applyTemplateBackground(compositeImage, template, config);

  // Apply template elements
  await _applyTemplateElements(compositeImage, template, config);

  // Apply custom elements (text, logos, etc.)
  await _applyCustomElements(compositeImage, customElements);

  // Apply template overlay effects
  await _applyTemplateEffects(compositeImage, template, config);

  return compositeImage;
}

Future<void> _applyTemplateBackground(
  img.Image compositeImage,
  TemplateModel template,
  Map<String, dynamic> config,
) async {
  final backgroundColor = _parseColor(template.style.backgroundColor);
  
  switch (template.layout.type) {
    case 'minimal':
      // Add subtle gradient background
      _addGradientBackground(compositeImage, [
        backgroundColor,
        _lightenColor(backgroundColor, 0.1),
      ]);
      break;
    
    case 'vintage_frame':
      // Add vintage border and background
      _addVintageFrame(compositeImage, template.style);
      break;
    
    case 'gradient_frame':
      // Add gradient frame
      final primaryColor = _parseColor(template.style.primaryColor);
      final secondaryColor = _parseColor(template.style.secondaryColor);
      _addGradientFrame(compositeImage, [primaryColor, secondaryColor]);
      break;
      
    case 'story_layout':
      // Add storytelling sections
      _addStoryLayout(compositeImage, template.style);
      break;
  }
}

Future<void> _applyTemplateElements(
  img.Image compositeImage,
  TemplateModel template,
  Map<String, dynamic> config,
) async {
  for (final element in template.layout.elements) {
    switch (element.type) {
      case ElementType.border:
        _addBorder(compositeImage, element, template.style);
        break;
      
      case ElementType.shape:
        _addShape(compositeImage, element, template.style);
        break;
      
      case ElementType.badge:
        await _addBadge(compositeImage, element, template.style);
        break;
      
      case ElementType.image:
        await _addTemplateImage(compositeImage, element, template.style);
        break;
        
      case ElementType.text:
        await _addTemplateText(compositeImage, element, template.style);
        break;
        
      case ElementType.logo:
        await _addTemplateLogo(compositeImage, element, template.style);
        break;
        
      case ElementType.background:
        // Background is handled separately
        break;
    }
  }
}

Future<void> _applyCustomElements(
  img.Image compositeImage,
  List<EditableElement> customElements,
) async {
  for (final element in customElements) {
    switch (element.type) {
      case ElementType.text:
        await _addTextElement(compositeImage, element);
        break;
      
      case ElementType.logo:
        await _addLogoElement(compositeImage, element);
        break;
      
      case ElementType.image:
        await _addImageElement(compositeImage, element);
        break;
        
      case ElementType.shape:
        await _addShapeElement(compositeImage, element);
        break;
        
      case ElementType.badge:
      case ElementType.border:
      case ElementType.background:
        // These are handled in template elements
        break;
    }
  }
}

Future<void> _applyTemplateEffects(
  img.Image compositeImage,
  TemplateModel template,
  Map<String, dynamic> config,
) async {
  // Apply template-specific effects
  if (template.style.customStyles.containsKey('vintage_filter')) {
    _applyVintageFilter(compositeImage);
  }
  
  if (template.style.customStyles.containsKey('glow_effect')) {
    _applyGlowEffect(compositeImage);
  }
  
  if (template.style.customStyles.containsKey('shadow')) {
    _applyShadowEffect(compositeImage);
  }
}

// Background and frame methods
void _addGradientBackground(img.Image image, List<img.Color> colors) {
  // Create gradient background
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final progress = y / image.height;
      final color = _interpolateColor(colors[0], colors[1], progress);
      
      // Blend with existing pixel
      final existingPixel = image.getPixel(x, y);
      final blendedColor = _blendColors(existingPixel, color, 0.3);
      image.setPixel(x, y, blendedColor);
    }
  }
}

void _addVintageFrame(img.Image image, TemplateStyle style) {
  final frameColor = _parseColor(style.primaryColor);
  final frameWidth = 20;
  
  // ✅ Fixed: Use correct parameter names and convert to int
  img.drawRect(
    image,
    x1: 0, 
    y1: 0, 
    x2: image.width - 1, 
    y2: image.height - 1,
    color: frameColor,
    thickness: frameWidth,
  );
  
  // Add inner shadow
  for (int i = frameWidth; i < frameWidth * 2; i++) {
    final alpha = ((frameWidth * 2 - i) / frameWidth * 0.5 * 255).toInt();
    final shadowColor = img.ColorRgba8(0, 0, 0, alpha);
    
    img.drawRect(
      image,
      x1: i, 
      y1: i,
      x2: image.width - i - 1, 
      y2: image.height - i - 1,
      color: shadowColor,
      thickness: 1,
    );
  }
}

void _addGradientFrame(img.Image image, List<img.Color> colors) {
  final frameWidth = 30;
  
  for (int i = 0; i < frameWidth; i++) {
    final progress = i / frameWidth;
    final color = _interpolateColor(colors[0], colors[1], progress);
    
    img.drawRect(
      image,
      x1: i, 
      y1: i,
      x2: image.width - i - 1, 
      y2: image.height - i - 1,
      color: color,
      thickness: 1,
    );
  }
}

void _addStoryLayout(img.Image image, TemplateStyle style) {
  final sectionHeight = image.height ~/ 3;
  final lineColor = _parseColor(style.primaryColor);
  
  // Add section dividers
  for (int i = 1; i < 3; i++) {
    final y = sectionHeight * i;
    img.drawLine(
      image,
      x1: 50, 
      y1: y,
      x2: image.width - 50, 
      y2: y,
      color: lineColor,
      thickness: 2,
    );
  }
}

// Element drawing methods
void _addBorder(img.Image image, TemplateElement element, TemplateStyle style) {
  final borderColor = _parseColor(style.primaryColor);
  final thickness = (element.properties['thickness']?.toDouble() ?? 2.0).toInt();
  
  img.drawRect(
    image,
    x1: 0, 
    y1: 0,
    x2: image.width - 1, 
    y2: image.height - 1,
    color: borderColor,
    thickness: thickness,
  );
}

void _addShape(img.Image image, TemplateElement element, TemplateStyle style) {
final shapeColor = _parseColor(style.secondaryColor);
final shape = element.properties['shape'] as String? ?? 'circle';

final centerX = (element.position.x * image.width).toInt();
final centerY = (element.position.y * image.height).toInt();
final radius = (element.size.width * image.width * 0.5).toInt();

if (shape == 'circle') {
  // ✅ Fixed: Use correct parameter names for image package
  img.fillCircle(
    image,
    x: centerX,
    y: centerY,
    radius: radius,
    color: shapeColor,
  );
}
}

Future<void> _addBadge(img.Image image, TemplateElement element, TemplateStyle style) async {
  final badgeColor = _parseColor(style.primaryColor);
  
  final x = (element.position.x * image.width).toInt();
  final y = (element.position.y * image.height).toInt();
  final width = (element.size.width * image.width).toInt();
  final height = (element.size.height * image.height).toInt();
  
  // ✅ Fixed: Use correct parameter names
  img.fillRect(
    image,
    x1: x, 
    y1: y,
    x2: x + width, 
    y2: y + height,
    color: badgeColor,
  );
}

Future<void> _addTemplateImage(img.Image image, TemplateElement element, TemplateStyle style) async {
  final imagePath = element.properties['imagePath'] as String?;
  if (imagePath != null && File(imagePath).existsSync()) {
    final overlayImage = img.decodeImage(await File(imagePath).readAsBytes());
    if (overlayImage != null) {
      final x = (element.position.x * image.width).toInt();
      final y = (element.position.y * image.height).toInt();
      final width = (element.size.width * image.width).toInt();
      final height = (element.size.height * image.height).toInt();
      
      final resizedOverlay = img.copyResize(overlayImage, width: width, height: height);
      
      // ✅ Fixed: Use correct parameter names
      img.compositeImage(image, resizedOverlay, dstX: x, dstY: y);
    }
  }
}

Future<void> _addTemplateText(img.Image image, TemplateElement element, TemplateStyle style) async {
  await _addSimpleTextPlaceholder(image, element, style);
}

Future<void> _addTemplateLogo(img.Image image, TemplateElement element, TemplateStyle style) async {
  await _addTemplateImage(image, element, style);
}

Future<void> _addTextElement(img.Image image, EditableElement element) async {
  final x = element.position.dx.toInt();
  final y = element.position.dy.toInt();
  final width = element.size.width.toInt();
  final height = element.size.height.toInt();
  
  // Add simple text background
  img.fillRect(
    image,
    x1: x, 
    y1: y,
    x2: x + width, 
    y2: y + height,
    color: img.ColorRgba8(255, 255, 255, 128), // Semi-transparent white
  );
}

Future<void> _addLogoElement(img.Image image, EditableElement element) async {
  if (element.content.isNotEmpty && File(element.content).existsSync()) {
    final logoImage = img.decodeImage(await File(element.content).readAsBytes());
    if (logoImage != null) {
      final resizedLogo = img.copyResize(
        logoImage,
        width: element.size.width.toInt(),
        height: element.size.height.toInt(),
      );
      
      // ✅ Fixed: Use correct parameter names and convert to int
      img.compositeImage(
        image,
        resizedLogo,
        dstX: element.position.dx.toInt(),
        dstY: element.position.dy.toInt(),
      );
    }
  }
}

Future<void> _addImageElement(img.Image image, EditableElement element) async {
  await _addLogoElement(image, element);
}

Future<void> _addShapeElement(img.Image image, EditableElement element) async {
final shapeColor = _parseColor('#${(element.style['color'] as int).toRadixString(16).padLeft(8, '0')}');
final filled = element.style['filled'] as bool? ?? true;
final x = element.position.dx.toInt();
final y = element.position.dy.toInt();
final width = element.size.width.toInt();
final height = element.size.height.toInt();

if (element.content == 'circle') {
  final centerX = x + width ~/ 2;
  final centerY = y + height ~/ 2;
  final radius = (width < height ? width : height) ~/ 2;
  
  if (filled) {
    // ✅ Fixed: Use correct parameter names
    img.fillCircle(image, x: centerX, y: centerY, radius: radius, color: shapeColor);
  } else {
    // ✅ Fixed: Use correct parameter names
    img.drawCircle(image, x: centerX, y: centerY, radius: radius, color: shapeColor);
  }
} else if (element.content == 'rectangle') {
  if (filled) {
    img.fillRect(image, x1: x, y1: y, x2: x + width, y2: y + height, color: shapeColor);
  } else {
    img.drawRect(image, x1: x, y1: y, x2: x + width, y2: y + height, color: shapeColor);
  }
}
}

Future<void> _addSimpleTextPlaceholder(img.Image image, TemplateElement element, TemplateStyle style) async {
  final textColor = _parseColor(style.textColor);
  final x = (element.position.x * image.width).toInt();
  final y = (element.position.y * image.height).toInt();
  final width = (element.size.width * image.width).toInt();
  final height = (element.size.height * image.height).toInt();
  
  img.fillRect(
    image,
    x1: x, 
    y1: y,
    x2: x + width, 
    y2: y + height,
    color: textColor,
  );
}

// Effect methods
void _applyVintageFilter(img.Image image) {
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      
      // Sepia transformation
      final newR = ((r * 0.393) + (g * 0.769) + (b * 0.189)).clamp(0, 255).toInt();
      final newG = ((r * 0.349) + (g * 0.686) + (b * 0.168)).clamp(0, 255).toInt();
      final newB = ((r * 0.272) + (g * 0.534) + (b * 0.131)).clamp(0, 255).toInt();
      
      image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
    }
  }
}

void _applyGlowEffect(img.Image image) {
  // ✅ Fixed: Use correct parameter names
  final glowImage = img.copyCrop(image, x: 0, y: 0, width: image.width, height: image.height);
  img.gaussianBlur(glowImage, radius: 5);
  
  img.compositeImage(image, glowImage, blend: img.BlendMode.overlay);
}

void _applyShadowEffect(img.Image image) {
  final shadowOffset = 10;
  // ✅ Fixed: Use correct parameter names
  final shadowImage = img.copyCrop(image, x: 0, y: 0, width: image.width, height: image.height);
  
  // Darken and blur for shadow
  img.adjustColor(shadowImage, brightness: -0.8);
  img.gaussianBlur(shadowImage, radius: 8);
  
  // ✅ Fixed: Use correct parameter names
  img.compositeImage(image, shadowImage, dstX: shadowOffset, dstY: shadowOffset);
}

// Utility methods
img.Color _parseColor(String colorString) {
  if (colorString.startsWith('#')) {
    final hex = colorString.substring(1);
    final value = int.parse(hex, radix: 16);
    if (hex.length == 6) {
      return img.ColorRgb8((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
    } else if (hex.length == 8) {
      return img.ColorRgba8((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF, (value >> 24) & 0xFF);
    }
  }
  return img.ColorRgb8(0, 0, 0);
}

img.Color _lightenColor(img.Color color, double amount) {
  final r = color.r;
  final g = color.g;
  final b = color.b;
  
  final newR = (r + (255 - r) * amount).clamp(0, 255).toInt();
  final newG = (g + (255 - g) * amount).clamp(0, 255).toInt();
  final newB = (b + (255 - b) * amount).clamp(0, 255).toInt();
  
  return img.ColorRgb8(newR, newG, newB);
}

img.Color _interpolateColor(img.Color color1, img.Color color2, double progress) {
  final r1 = color1.r;
  final g1 = color1.g;
  final b1 = color1.b;
  
  final r2 = color2.r;
  final g2 = color2.g;
  final b2 = color2.b;
  
  final r = (r1 + (r2 - r1) * progress).toInt();
  final g = (g1 + (g2 - g1) * progress).toInt();
  final b = (b1 + (b2 - b1) * progress).toInt();
  
  return img.ColorRgb8(r, g, b);
}

img.Color _blendColors(img.Color baseColor, img.Color overlayColor, double opacity) {
  final baseR = baseColor.r;
  final baseG = baseColor.g;
  final baseB = baseColor.b;
  
  final overlayR = overlayColor.r;
  final overlayG = overlayColor.g;
  final overlayB = overlayColor.b;
  
  final r = (baseR + (overlayR - baseR) * opacity).toInt();
  final g = (baseG + (overlayG - baseG) * opacity).toInt();
  final b = (baseB + (overlayB - baseB) * opacity).toInt();
  
  return img.ColorRgb8(r, g, b);
}

Future<String> _saveFinalImage(img.Image finalImage, String templateId) async {
  final directory = await getApplicationDocumentsDirectory();
  final fileName = 'template_applied_${templateId}_${DateTime.now().millisecondsSinceEpoch}.png';
  final filePath = path.join(directory.path, fileName);
  
  await File(filePath).writeAsBytes(img.encodePng(finalImage));
  
  return filePath;
}
}