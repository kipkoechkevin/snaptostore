import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../providers/template_editor_provider.dart';
import '../../domain/models/template_editor_state.dart';
import '../../../templates/domain/models/template_model.dart';

class ElementPropertiesPanel extends ConsumerStatefulWidget {
final TemplateEditorParams params;
final VoidCallback onClose;

const ElementPropertiesPanel({
  super.key,
  required this.params,
  required this.onClose,
});

@override
ConsumerState<ElementPropertiesPanel> createState() => _ElementPropertiesPanelState();
}

class _ElementPropertiesPanelState extends ConsumerState<ElementPropertiesPanel> {
late TextEditingController _textController;
late TextEditingController _fontSizeController;

@override
void initState() {
  super.initState();
  _textController = TextEditingController();
  _fontSizeController = TextEditingController();
}

@override
void dispose() {
  _textController.dispose();
  _fontSizeController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final selectedElement = ref.watch(selectedElementProvider(widget.params));
  final colorScheme = ref.watch(currentColorSchemeProvider);

  if (selectedElement == null) {
    return const SizedBox.shrink();
  }

  // Update controllers when element changes
  _textController.text = selectedElement.content;
  _fontSizeController.text = (selectedElement.style['fontSize'] ?? 18.0).toString();

  return Container(
    width: 300,
    height: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(-5, 0),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _getElementIcon(selectedElement.type),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${selectedElement.type.toString().split('.').last} Properties',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),

        // Properties Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Position Controls
                _buildSectionHeader('Position'),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberInput(
                        'X',
                        selectedElement.position.dx,
                        (value) => _updateElementPosition(
                          Offset(value, selectedElement.position.dy),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNumberInput(
                        'Y',
                        selectedElement.position.dy,
                        (value) => _updateElementPosition(
                          Offset(selectedElement.position.dx, value),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Size Controls
                _buildSectionHeader('Size'),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberInput(
                        'Width',
                        selectedElement.size.width,
                        (value) => _updateElementSize(
                          Size(value, selectedElement.size.height),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNumberInput(
                        'Height',
                        selectedElement.size.height,
                        (value) => _updateElementSize(
                          Size(selectedElement.size.width, value),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Element-specific properties
                if (selectedElement.type == ElementType.text) ...[
                  _buildTextProperties(selectedElement),
                ] else if (selectedElement.type == ElementType.shape) ...[
                  _buildShapeProperties(selectedElement),
                ],

                const SizedBox(height: 24),

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(templateEditorProvider(widget.params).notifier)
                          .removeCustomElement(selectedElement.id);
                      widget.onClose();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Element'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
  );
}

Widget _buildNumberInput(
  String label,
  double value,
  Function(double) onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        initialValue: value.toStringAsFixed(0),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        onChanged: (text) {
          final newValue = double.tryParse(text);
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    ],
  );
}

Widget _buildTextProperties(EditableElement element) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader('Text Properties'),
      
      // Text Content
      TextField(
        controller: _textController,
        decoration: const InputDecoration(
          labelText: 'Text Content',
          border: OutlineInputBorder(),
        ),
        onChanged: (text) {
          _updateElementContent(text);
        },
      ),

      const SizedBox(height: 16),

      // Font Size
      TextField(
        controller: _fontSizeController,
        decoration: const InputDecoration(
          labelText: 'Font Size',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        onChanged: (text) {
          final fontSize = double.tryParse(text);
          if (fontSize != null) {
            _updateElementStyle('fontSize', fontSize);
          }
        },
      ),

      const SizedBox(height: 16),

      // Text Color
      Text(
        'Text Color',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(height: 8),
      _buildColorPicker(
        Color(element.style['color'] as int? ?? 0xFF000000),
        (color) => _updateElementStyle('color', color.value),
      ),

      const SizedBox(height: 16),

      // Font Weight
      Text(
        'Font Weight',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'Normal',
              element.style['fontWeight'] != 'bold',
              () => _updateElementStyle('fontWeight', 'normal'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton(
              'Bold',
              element.style['fontWeight'] == 'bold',
              () => _updateElementStyle('fontWeight', 'bold'),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildShapeProperties(EditableElement element) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader('Shape Properties'),
      
      // Shape Color
      Text(
        'Shape Color',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(height: 8),
      _buildColorPicker(
        Color(element.style['color'] as int? ?? 0xFF6B46C1),
        (color) => _updateElementStyle('color', color.value),
      ),

      const SizedBox(height: 16),

      // Fill Style
      Text(
        'Fill Style',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'Filled',
              element.style['filled'] == true,
              () => _updateElementStyle('filled', true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton(
              'Outline',
              element.style['filled'] != true,
              () => _updateElementStyle('filled', false),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildColorPicker(Color currentColor, Function(Color) onChanged) {
  final colors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    ref.watch(currentColorSchemeProvider).primary,
    ref.watch(currentColorSchemeProvider).secondary,
  ];

  return Wrap(
    spacing: 8,
    children: colors.map((color) {
      final isSelected = color.value == currentColor.value;
      return GestureDetector(
        onTap: () => onChanged(color),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  color: color == Colors.white ? Colors.black : Colors.white,
                  size: 16,
                )
              : null,
        ),
      );
    }).toList(),
  );
}

Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? colorScheme.primary : AppColors.textTertiary,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

IconData _getElementIcon(ElementType type) {
  switch (type) {
    case ElementType.text:
      return Icons.text_fields;
    case ElementType.image:
    case ElementType.logo:
      return Icons.image_outlined;
    case ElementType.shape:
      return Icons.circle_outlined;
    default:
      return Icons.widgets;
  }
}

void _updateElementPosition(Offset newPosition) {
  final selectedElement = ref.read(selectedElementProvider(widget.params));
  if (selectedElement != null) {
    final updatedElement = selectedElement.copyWith(position: newPosition);
    ref.read(templateEditorProvider(widget.params).notifier)
        .updateCustomElement(selectedElement.id, updatedElement);
  }
}

void _updateElementSize(Size newSize) {
  final selectedElement = ref.read(selectedElementProvider(widget.params));
  if (selectedElement != null) {
    final updatedElement = selectedElement.copyWith(size: newSize);
    ref.read(templateEditorProvider(widget.params).notifier)
        .updateCustomElement(selectedElement.id, updatedElement);
  }
}

void _updateElementContent(String newContent) {
  final selectedElement = ref.read(selectedElementProvider(widget.params));
  if (selectedElement != null) {
    final updatedElement = selectedElement.copyWith(content: newContent);
    ref.read(templateEditorProvider(widget.params).notifier)
        .updateCustomElement(selectedElement.id, updatedElement);
  }
}

void _updateElementStyle(String key, dynamic value) {
  final selectedElement = ref.read(selectedElementProvider(widget.params));
  if (selectedElement != null) {
    final updatedStyle = Map<String, dynamic>.from(selectedElement.style);
    updatedStyle[key] = value;
    
    final updatedElement = selectedElement.copyWith(style: updatedStyle);
    ref.read(templateEditorProvider(widget.params).notifier)
        .updateCustomElement(selectedElement.id, updatedElement);
  }
}
}