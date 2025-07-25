import 'package:equatable/equatable.dart';

class BackgroundRemovalResult extends Equatable {
final String originalImagePath;
final String processedImagePath;
final BackgroundType backgroundType;
final String? backgroundColor;
final String? backgroundImagePath;
final int processingTimeMs;
final bool isSuccess;
final String? error;

const BackgroundRemovalResult({
  required this.originalImagePath,
  required this.processedImagePath,
  required this.backgroundType,
  this.backgroundColor,
  this.backgroundImagePath,
  required this.processingTimeMs,
  required this.isSuccess,
  this.error,
});

@override
List<Object?> get props => [
  originalImagePath,
  processedImagePath,
  backgroundType,
  backgroundColor,
  backgroundImagePath,
  processingTimeMs,
  isSuccess,
  error,
];
}

enum BackgroundType {
transparent,
solidColor,
gradient,
aiGenerated,
customImage,
}

class BackgroundOption {
final String id;
final String name;
final BackgroundType type;
final String? color;
final List<String>? colors; // For gradients
final String? imagePath;
final String? previewUrl;
final bool isPremium;

const BackgroundOption({
  required this.id,
  required this.name,
  required this.type,
  this.color,
  this.colors,
  this.imagePath,
  this.previewUrl,
  this.isPremium = false,
});

static List<BackgroundOption> get defaultOptions => [
  const BackgroundOption(
    id: 'transparent',
    name: 'Transparent',
    type: BackgroundType.transparent,
  ),
  const BackgroundOption(
    id: 'white',
    name: 'White',
    type: BackgroundType.solidColor,
    color: '#FFFFFF',
  ),
  const BackgroundOption(
    id: 'black',
    name: 'Black',
    type: BackgroundType.solidColor,
    color: '#000000',
  ),
  const BackgroundOption(
    id: 'gradient_purple',
    name: 'Purple Gradient',
    type: BackgroundType.gradient,
    colors: ['#6B46C1', '#8B5CF6'],
  ),
  const BackgroundOption(
    id: 'gradient_blue',
    name: 'Blue Gradient',
    type: BackgroundType.gradient,
    colors: ['#3B82F6', '#06B6D4'],
  ),
  const BackgroundOption(
    id: 'gradient_pink',
    name: 'Pink Gradient',
    type: BackgroundType.gradient,
    colors: ['#EC4899', '#F472B6'],
  ),
];
}