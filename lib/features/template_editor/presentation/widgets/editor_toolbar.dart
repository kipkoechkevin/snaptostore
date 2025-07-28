import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../domain/models/template_editor_state.dart'; // ✅ Add this import
import '../providers/template_editor_provider.dart';
import '../../../templates/domain/models/template_model.dart';

class EditorToolbar extends ConsumerWidget {
final TemplateEditorParams params;
final VoidCallback onAddText;
final VoidCallback onAddLogo;
final VoidCallback onPreview;
final VoidCallback onApply;

const EditorToolbar({
  super.key,
  required this.params,
  required this.onAddText,
  required this.onAddLogo,
  required this.onPreview,
  required this.onApply,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final editorState = ref.watch(templateEditorProvider(params));
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        children: [
          // Edit Mode Toggle
          _ToolbarButton(
            icon: editorState.isEditing ? Icons.edit_off : Icons.edit,
            label: editorState.isEditing ? 'View' : 'Edit',
            isActive: editorState.isEditing,
            onTap: () {
              ref.read(templateEditorProvider(params).notifier).toggleEditing();
            },
          ),

          const SizedBox(width: 12),

          // Add Text
          _ToolbarButton(
            icon: Icons.text_fields,
            label: 'Text',
            onTap: onAddText,
          ),

          const SizedBox(width: 12),

          // Add Logo
          _ToolbarButton(
            icon: Icons.image_outlined,
            label: 'Logo',
            onTap: onAddLogo,
          ),

          const SizedBox(width: 12),

          // Add Shape
          _ToolbarButton(
            icon: Icons.circle_outlined,
            label: 'Shape',
            onTap: () => _showShapeDialog(context, ref),
          ),

          const Spacer(),

          // Preview
          OutlinedButton.icon(
            onPressed: onPreview,
            icon: const Icon(Icons.visibility),
            label: const Text('Preview'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
            ),
          ),

          const SizedBox(width: 12),

          // Apply Template
          ElevatedButton.icon(
            onPressed: editorState.isApplying ? null : onApply,
            icon: editorState.isApplying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(editorState.isApplying ? 'Applying...' : 'Apply'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
          ),
        ],
      ),
    ),
  );
}

void _showShapeDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Shape'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.circle_outlined),
            title: const Text('Circle'),
            onTap: () {
              Navigator.of(context).pop();
              _addShape(ref, 'circle');
            },
          ),
          ListTile(
            leading: const Icon(Icons.square_outlined),
            title: const Text('Rectangle'),
            onTap: () {
              Navigator.of(context).pop();
              _addShape(ref, 'rectangle');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Star'),
            onTap: () {
              Navigator.of(context).pop();
              _addShape(ref, 'star');
            },
          ),
        ],
      ),
    ),
  );
}

void _addShape(WidgetRef ref, String shapeType) {
  // ✅ Now EditableElement is available
  final element = EditableElement(
    id: 'shape_${DateTime.now().millisecondsSinceEpoch}',
    type: ElementType.shape,
    content: shapeType,
    position: const Offset(150, 150),
    size: const Size(80, 80),
    style: {
      'color': ref.watch(currentColorSchemeProvider).primary.value,
      'filled': true,
    },
  );

  ref.read(templateEditorProvider(params).notifier).addCustomElement(element);
}
}

class _ToolbarButton extends ConsumerWidget {
final IconData icon;
final String label;
final VoidCallback onTap;
final bool isActive;

const _ToolbarButton({
  required this.icon,
  required this.label,
  required this.onTap,
  this.isActive = false,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: colorScheme.primary.withOpacity(0.3))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? colorScheme.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? colorScheme.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
}