import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../domain/models/template_collection.dart';
import 'providers/template_provider.dart';
import 'widgets/template_collection_card.dart';
import 'widgets/template_grid.dart';
import 'widgets/template_filter_bar.dart';
import 'widgets/featured_templates_section.dart';

class TemplateBrowserScreen extends ConsumerStatefulWidget {
final BusinessType? initialBusinessType;

const TemplateBrowserScreen({
  super.key,
  this.initialBusinessType,
});

@override
ConsumerState<TemplateBrowserScreen> createState() => _TemplateBrowserScreenState();
}

class _TemplateBrowserScreenState extends ConsumerState<TemplateBrowserScreen>
  with TickerProviderStateMixin {
late TabController _tabController;
late AnimationController _fadeController;
late Animation<double> _fadeAnimation;

@override
void initState() {
  super.initState();
  
  _tabController = TabController(length: 2, vsync: this);
  _fadeController = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );
  
  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
  );

  // Set initial business type filter if provided
  if (widget.initialBusinessType != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(templateProvider.notifier).filterByBusinessType(widget.initialBusinessType);
    });
  }

  _fadeController.forward();
}

@override
void dispose() {
  _tabController.dispose();
  _fadeController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final templateState = ref.watch(templateProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Scaffold(
    backgroundColor: AppColors.background,
    body: FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildAppBar(context, colorScheme),

          // Tab Bar
          SliverToBoxAdapter(
            child: _buildTabBar(colorScheme),
          ),

          // Tab Bar View Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Collections Tab
                _buildCollectionsTab(),
                
                // Browse Tab
                _buildBrowseTab(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAppBar(BuildContext context, BusinessColorScheme colorScheme) {
  return SliverAppBar(
    expandedHeight: 120,
    floating: false,
    pinned: true,
    backgroundColor: colorScheme.primary,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: colorScheme.gradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Templates',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional designs for your business',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.search, color: Colors.white),
        onPressed: () => _showSearchDialog(context),
      ),
    ],
  );
}

Widget _buildTabBar(BusinessColorScheme colorScheme) {
  return Container(
    margin: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TabBar(
      controller: _tabController,
      labelColor: colorScheme.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.primary.withOpacity(0.1),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: 'Collections'),
        Tab(text: 'Browse All'),
      ],
    ),
  );
}

Widget _buildCollectionsTab() {
  final collections = ref.watch(templateCollectionsProvider);
  
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Templates
        const FeaturedTemplatesSection(),
        
        const SizedBox(height: 32),
        
        // Business Collections
        Text(
          'Business Collections',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collection = collections[index];
            return TemplateCollectionCard(
              collection: collection,
              onTap: () => _navigateToCollection(collection),
            );
          },
        ),
        
        const SizedBox(height: 32),
      ],
    ),
  );
}

Widget _buildBrowseTab() {
  return Column(
    children: [
      // Filter Bar
      const TemplateFilterBar(),
      
      // Template Grid
      const Expanded(
        child: TemplateGrid(),
      ),
    ],
  );
}

void _navigateToCollection(TemplateCollection collection) {
  ref.read(templateProvider.notifier).filterByBusinessType(collection.businessType);
  _tabController.animateTo(1);
}

void _showSearchDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Search Templates'),
      content: const TextField(
        decoration: InputDecoration(
          hintText: 'Search by name, category, or business type...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // TODO: Implement search functionality
          },
          child: const Text('Search'),
        ),
      ],
    ),
  );
}
}