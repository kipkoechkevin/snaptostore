import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class CameraState extends Equatable {
final CameraController? controller;
final bool isInitialized;
final bool isCapturing;
final FlashMode flashMode;
final int selectedCameraIndex;
final List<CameraDescription> availableCameras;
final String? capturedImagePath;
final String? error;
final bool hasPermission;

const CameraState({
  this.controller,
  this.isInitialized = false,
  this.isCapturing = false,
  this.flashMode = FlashMode.auto,
  this.selectedCameraIndex = 0,
  this.availableCameras = const [],
  this.capturedImagePath,
  this.error,
  this.hasPermission = false,
});

CameraState copyWith({
  CameraController? controller,
  bool? isInitialized,
  bool? isCapturing,
  FlashMode? flashMode,
  int? selectedCameraIndex,
  List<CameraDescription>? availableCameras,
  String? capturedImagePath,
  String? error,
  bool? hasPermission,
}) {
  return CameraState(
    controller: controller ?? this.controller,
    isInitialized: isInitialized ?? this.isInitialized,
    isCapturing: isCapturing ?? this.isCapturing,
    flashMode: flashMode ?? this.flashMode,
    selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
    availableCameras: availableCameras ?? this.availableCameras,
    capturedImagePath: capturedImagePath ?? this.capturedImagePath,
    error: error,
    hasPermission: hasPermission ?? this.hasPermission,
  );
}

@override
List<Object?> get props => [
  controller,
  isInitialized,
  isCapturing,
  flashMode,
  selectedCameraIndex,
  availableCameras,
  capturedImagePath,
  error,
  hasPermission,
];
}