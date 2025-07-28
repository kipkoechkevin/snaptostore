import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../../templates/domain/models/template_model.dart'; // ✅ Add this import
import '../../domain/models/template_editor_state.dart';
import '../providers/template_editor_provider.dart';

class TemplateCanvas extends ConsumerStatefulWidget {
final TemplateEditorParams params;
final Function(String?) onElementSelected;

const TemplateCanvas({
  super.key,
  required this.params,
  required this.onElementSelected,
});

@override
ConsumerState<TemplateCanvas> createState() => _TemplateCanvasState();
}

class _TemplateCanvasState extends ConsumerState<TemplateCanvas> {
final TransformationController _transformationController = TransformationController();

@override
void dispose() {
  _transformationController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final editorState = ref.watch(templateEditorProvider(widget.params));
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 3.0,
        onInteractionUpdate: (details) {
          ref.read(templateEditorProvider(widget.params).notifier)
              .updateZoom(_transformationController.value.getMaxScaleOnAxis());
        },
        child: GestureDetector(
          onTap: () {
            // Deselect all elements when tapping on empty space
            widget.onElementSelected(null);
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: _getTemplateBackgroundGradient(editorState.selectedTemplate),
            ),
            child: Stack(
              children: [
                // Base Image
                Positioned.fill(
                  child: _buildBaseImage(editorState),
                ),

                // Template Overlay
                Positioned.fill(
                  child: _buildTemplateOverlay(editorState, colorScheme),
                ),

                // Custom Elements - ✅ Now correctly typed as EditableElement
                ...editorState.customElements.map((element) {
                  return _buildEditableElement(element, editorState);
                }),

                // Canvas Grid (when editing)
                if (editorState.isEditing)
                  Positioned.fill(
                    child: _buildCanvasGrid(),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildBaseImage(TemplateEditorState editorState) {
  return Center(
    child: Container(
      constraints: const BoxConstraints(
        maxWidth: 400,
        maxHeight: 400,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(editorState.originalImagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceVariant,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image not found',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

Widget _buildTemplateOverlay(TemplateEditorState editorState, BusinessColorScheme colorScheme) {
  final template = editorState.selectedTemplate;
  
  return CustomPaint(
    painter: TemplateOverlayPainter(
      template: template,
      config: editorState.templateConfig,
      colorScheme: colorScheme,
    ),
    child: Container(),
  );
}

// ✅ Fixed: Now correctly accepts EditableElement
Widget _buildEditableElement(EditableElement element, TemplateEditorState editorState) {
  return Positioned(
    left: element.position.dx,
    top: element.position.dy,
    child: GestureDetector(
      onTap: () {
        widget.onElementSelected(element.id);
      },
      onPanUpdate: (details) {
        if (element.isSelected) {
          final newPosition = Offset(
            element.position.dx + details.delta.dx,
            element.position.dy + details.delta.dy,
          );
          
          final updatedElement = element.copyWith(position: newPosition);
          ref.read(templateEditorProvider(widget.params).notifier)
              .updateCustomElement(element.id, updatedElement);
        }
      },
      child: Container(
        width: element.size.width,
        height: element.size.height,
        decoration: BoxDecoration(
          border: element.isSelected
              ? Border.all(
                  color: ref.watch(currentColorSchemeProvider).primary,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: _buildElementContent(element),
      ),
    ),
  );
}

Widget _buildElementContent(EditableElement element) {
  switch (element.type) {
    case ElementType.text:
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(element.style['backgroundColor'] as int? ?? 0x00FFFFFF),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          element.content,
          style: TextStyle(
            color: Color(element.style['color'] as int? ?? 0xFF000000),
            fontSize: element.style['fontSize'] as double? ?? 18.0,
            fontWeight: element.style['fontWeight'] == 'bold' 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      );
    
    case ElementType.logo:
    case ElementType.image:
      if (element.content.isNotEmpty && File(element.content).existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            File(element.content),
            fit: BoxFit.cover,
          ),
        );
      }
      return Container(
        color: AppColors.surfaceVariant,
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textTertiary,
          size: element.size.width * 0.4,
        ),
      );
    
    case ElementType.shape:
      return Container(
        decoration: BoxDecoration(
          color: element.style['filled'] == true
              ? Color(element.style['color'] as int? ?? AppColors.primary.value)
              : Colors.transparent,
          border: element.style['filled'] != true
              ? Border.all(
                  color: Color(element.style['color'] as int? ?? AppColors.primary.value),
                  width: 2,
                )
              : null,
          borderRadius: element.content == 'circle'
              ? BorderRadius.circular(element.size.width / 2)
              : BorderRadius.circular(4),
        ),
      );
    
    default:
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            element.type.toString().split('.').last.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
  }
}

Widget _buildCanvasGrid() {
  return CustomPaint(
    painter: GridPainter(),
    child: Container(),
  );
}

LinearGradient _getTemplateBackgroundGradient(TemplateModel template) {
  switch (template.businessType.toString().split('.').last) {
    case 'thrift':
      return const LinearGradient(
        colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
      );
    case 'boutique':
      return const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
      );
    case 'beauty':
      return const LinearGradient(
        colors: [Color(0xFFFDF2F8), Color(0xFFFCE7F3)],
      );
    case 'handmade':
      return const LinearGradient(
        colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
      );
    default:
      return const LinearGradient(
        colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
      );
  }
}
}

// Template Overlay Painter
class TemplateOverlayPainter extends CustomPainter {
final TemplateModel template;
final Map<String, dynamic> config;
final BusinessColorScheme colorScheme;

TemplateOverlayPainter({
  required this.template,
  required this.config,
  required this.colorScheme,
});

@override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  switch (template.layout.type) {
    case 'minimal':
      // Draw minimal border
      paint.color = colorScheme.primary.withOpacity(0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
          const Radius.circular(8),
        ),
        paint,
      );
      break;
    
    case 'vintage_frame':
      // Draw vintage-style frame
      paint.color = const Color(0xFF8B4513);
      paint.strokeWidth = 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
          const Radius.circular(4),
        ),
        paint,
      );
      
      // Inner frame
      paint.strokeWidth = 2;
      paint.color = const Color(0xFF8B4513).withOpacity(0.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(25, 25, size.width - 50, size.height - 50),
          const Radius.circular(4),
        ),
        paint,
      );
      break;
    
    case 'gradient_frame':
      // Draw gradient frame effect
      final rect = Rect.fromLTWH(15, 15, size.width - 30, size.height - 30);
      final gradient = LinearGradient(
        colors: [colorScheme.primary, colorScheme.secondary],
      );
      
      paint
        ..shader = gradient.createShader(rect)
        ..strokeWidth = 4;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
      break;
  }
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Grid Painter for editing mode
class GridPainter extends CustomPainter {
@override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = Colors.grey.withOpacity(0.3)
    ..strokeWidth = 0.5;

  const gridSize = 20.0;

  // Vertical lines
  for (double x = 0; x < size.width; x += gridSize) {
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }

  // Horizontal lines
  for (double y = 0; y < size.height; y += gridSize) {
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}