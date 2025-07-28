import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../templates/domain/models/template_model.dart';
import '../domain/models/template_editor_state.dart'; // ✅ Add this import
import '../../social_sharing/presentation/social_share_screen.dart';
import 'providers/template_editor_provider.dart';
import 'widgets/template_canvas.dart';
import 'widgets/editor_toolbar.dart';
import 'widgets/element_properties_panel.dart';
import 'widgets/template_preview_dialog.dart';

// Rest of the file remains the same, but now EditableElement is available
class TemplateEditorScreen extends ConsumerStatefulWidget {
final String imagePath;
final TemplateModel template;

const TemplateEditorScreen({
  super.key,
  required this.imagePath,
  required this.template,
});

@override
ConsumerState<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen>
  with TickerProviderStateMixin {
late TemplateEditorParams _params;
late AnimationController _slideController;
late Animation<Offset> _slideAnimation;
bool _showPropertiesPanel = false;

@override
void initState() {
  super.initState();
  _params = TemplateEditorParams(
    imagePath: widget.imagePath,
    template: widget.template,
  );

  _slideController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  _slideAnimation = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeOutCubic,
  ));
}

@override
void dispose() {
  _slideController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final editorState = ref.watch(templateEditorProvider(_params));
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: _buildAppBar(context, colorScheme),
    body: Stack(
      children: [
        // Main Editor Area
        Column(
          children: [
            // Canvas
            Expanded(
              child: TemplateCanvas(
                params: _params,
                onElementSelected: (elementId) {
                  ref.read(templateEditorProvider(_params).notifier).selectElement(elementId);
                  setState(() {
                    _showPropertiesPanel = elementId != null;
                  });
                  if (_showPropertiesPanel) {
                    _slideController.forward();
                  } else {
                    _slideController.reverse();
                  }
                },
              ),
            ),
            
            // Bottom Toolbar
            EditorToolbar(
              params: _params,
              onAddText: () => _addTextElement(),
              onAddLogo: () => _addLogoElement(),
              onPreview: () => _showPreview(),
              onApply: () => _applyTemplate(),
            ),
          ],
        ),

        // Properties Panel
        if (_showPropertiesPanel)
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: ElementPropertiesPanel(
                params: _params,
                onClose: () {
                  _slideController.reverse().then((_) {
                    setState(() {
                      _showPropertiesPanel = false;
                    });
                  });
                },
              ),
            ),
          ),

        // Loading Overlay
        if (editorState.isApplying)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Applying Template...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a few seconds',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

PreferredSizeWidget _buildAppBar(BuildContext context, BusinessColorScheme colorScheme) {
  return AppBar(
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Template Editor',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          widget.template.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    ),
    backgroundColor: colorScheme.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () => Navigator.of(context).pop(),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          ref.read(templateEditorProvider(_params).notifier).resetEditor();
        },
      ),
      IconButton(
        icon: const Icon(Icons.help_outline),
        onPressed: () => _showHelpDialog(),
      ),
    ],
  );
}

void _addTextElement() {
  // ✅ Now EditableElement is available
  final element = EditableElement(
    id: 'text_${DateTime.now().millisecondsSinceEpoch}',
    type: ElementType.text,
    content: 'Your Text',
    position: const Offset(100, 100),
    size: const Size(200, 50),
    style: {
      'color': 0xFF000000,
      'fontSize': 18.0,
      'fontWeight': 'bold',
      'backgroundColor': 0x00FFFFFF,
    },
  );

  ref.read(templateEditorProvider(_params).notifier).addCustomElement(element);
}

void _addLogoElement() {
  // TODO: Implement logo picker
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Logo picker coming soon!')),
  );
}

void _showPreview() {
  showDialog(
    context: context,
    builder: (context) => TemplatePreviewDialog(
      params: _params,
      onApply: () {
        Navigator.of(context).pop();
        _applyTemplate();
      },
    ),
  );
}

Future<void> _applyTemplate() async {
  final result = await ref.read(templateEditorProvider(_params).notifier).applyTemplate();
  
  if (result.isSuccess && mounted) {
    // Show success and navigate to sharing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Template Applied!'),
        content: Text(
          'Your template has been applied successfully in ${result.processingTimeMs}ms.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SocialShareScreen(
                    imagePath: result.finalImagePath,
                    defaultCaption: 'Check out my creation using ${widget.template.name}! ✨',
                  ),
                ),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  } else if (result.error != null && mounted) {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to apply template: ${result.error}'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

void _showHelpDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Template Editor Help'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Tap elements to select and edit them'),
          SizedBox(height: 8),
          Text('• Use toolbar to add text, logos, and shapes'),
          SizedBox(height: 8),
          Text('• Pinch to zoom, drag to pan around the canvas'),
          SizedBox(height: 8),
          Text('• Preview your work before applying the template'),
          SizedBox(height: 8),
          Text('• Applied templates can be shared directly to social media'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it!'),
        ),
      ],
    ),
  );
}
}