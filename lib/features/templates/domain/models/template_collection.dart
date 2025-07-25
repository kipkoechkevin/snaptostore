import 'package:equatable/equatable.dart';
import '../../../../core/constants/business_types.dart'; // ✅ Import shared enum
import 'template_model.dart';

class TemplateCollection extends Equatable {
final String id;
final String name;
final String description;
final BusinessType businessType;
final String iconUrl;
final String bannerUrl;
final List<TemplateModel> templates;
final bool isPremium;
final bool isNew;
final int templateCount;

const TemplateCollection({
  required this.id,
  required this.name,
  required this.description,
  required this.businessType,
  required this.iconUrl,
  required this.bannerUrl,
  required this.templates,
  this.isPremium = false,
  this.isNew = false,
  required this.templateCount,
});

@override
List<Object?> get props => [
  id, name, description, businessType, iconUrl, bannerUrl,
  templates, isPremium, isNew, templateCount,
];

// Rest of the implementation remains the same...
static List<TemplateCollection> get businessCollections => [
  TemplateCollection(
    id: 'thrift_boss',
    name: 'Thrift Boss',
    description: 'Vintage-inspired templates perfect for secondhand treasures',
    businessType: BusinessType.thrift,
    iconUrl: 'assets/icons/thrift_icon.png',
    bannerUrl: 'assets/banners/thrift_banner.jpg',
    templates: _getThriftTemplates(),
    templateCount: 12,
    isNew: true,
  ),
  
  TemplateCollection(
    id: 'boutique_boss',
    name: 'Boutique Boss',
    description: 'Clean, professional layouts for retail excellence',
    businessType: BusinessType.boutique,
    iconUrl: 'assets/icons/boutique_icon.png',
    bannerUrl: 'assets/banners/boutique_banner.jpg',
    templates: _getBoutiqueTemplates(),
    templateCount: 15,
  ),
  
  TemplateCollection(
    id: 'beauty_boss',
    name: 'Beauty Boss',
    description: 'Stunning templates for skincare and cosmetics',
    businessType: BusinessType.beauty,
    iconUrl: 'assets/icons/beauty_icon.png',
    bannerUrl: 'assets/banners/beauty_banner.jpg',
    templates: _getBeautyTemplates(),
    templateCount: 18,
    isPremium: true,
  ),
  
  TemplateCollection(
    id: 'handmade_boss',
    name: 'Handmade Boss',
    description: 'Artisan-focused designs that tell your craft story',
    businessType: BusinessType.handmade,
    iconUrl: 'assets/icons/handmade_icon.png',
    bannerUrl: 'assets/banners/handmade_banner.jpg',
    templates: _getHandmadeTemplates(),
    templateCount: 14,
  ),
];

static List<TemplateModel> _getThriftTemplates() {
  return [
    TemplateModel(
      id: 'thrift_vintage_classic',
      name: 'Vintage Classic',
      description: 'Classic vintage frame with warm tones',
      businessType: BusinessType.thrift,
      category: TemplateCategory.vintage,
      thumbnailUrl: 'assets/templates/thrift/vintage_classic_thumb.png',
      previewUrl: 'assets/templates/thrift/vintage_classic_preview.png',
      layout: TemplateLayout(
        type: 'vintage_frame',
        config: {'padding': 20, 'border_width': 3},
        elements: [],
      ),
      style: TemplateStyle(
        primaryColor: '#8B4513',
        secondaryColor: '#F4E4BC',
        textColor: '#2C1810',
        backgroundColor: '#FFF8E7',
        fontFamily: 'Serif',
        borderRadius: 8,
        customStyles: {'vintage_filter': true},
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPopular: true,
    ),
    // Add more thrift templates...
  ];
}

static List<TemplateModel> _getBoutiqueTemplates() {
  return [
    TemplateModel(
      id: 'boutique_minimal_clean',
      name: 'Minimal Clean',
      description: 'Clean, minimal design for professional listings',
      businessType: BusinessType.boutique,
      category: TemplateCategory.minimal,
      thumbnailUrl: 'assets/templates/boutique/minimal_clean_thumb.png',
      previewUrl: 'assets/templates/boutique/minimal_clean_preview.png',
      layout: TemplateLayout(
        type: 'minimal',
        config: {'padding': 40, 'alignment': 'center'},
        elements: [],
      ),
      style: TemplateStyle(
        primaryColor: '#FFFFFF',
        secondaryColor: '#F8F9FA',
        textColor: '#1F2937',
        backgroundColor: '#FFFFFF',
        fontFamily: 'Sans-serif',
        borderRadius: 12,
        customStyles: {'shadow': true},
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFeatured: true,
    ),
    // Add more boutique templates...
  ];
}

static List<TemplateModel> _getBeautyTemplates() {
  return [
    TemplateModel(
      id: 'beauty_glow_pink',
      name: 'Pink Glow',
      description: 'Soft pink gradient perfect for skincare products',
      businessType: BusinessType.beauty,
      category: TemplateCategory.modern,
      thumbnailUrl: 'assets/templates/beauty/pink_glow_thumb.png',
      previewUrl: 'assets/templates/beauty/pink_glow_preview.png',
      layout: TemplateLayout(
        type: 'gradient_frame',
        config: {'gradient_type': 'radial', 'opacity': 0.8},
        elements: [],
      ),
      style: TemplateStyle(
        primaryColor: '#EC4899',
        secondaryColor: '#F9A8D4',
        textColor: '#831843',
        backgroundColor: '#FDF2F8',
        fontFamily: 'Modern',
        borderRadius: 16,
        customStyles: {'glow_effect': true},
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPremium: true,
      isPopular: true,
    ),
    // Add more beauty templates...
  ];
}

static List<TemplateModel> _getHandmadeTemplates() {
  return [
    TemplateModel(
      id: 'handmade_craft_story',
      name: 'Craft Story',
      description: 'Showcase your artisan process and final product',
      businessType: BusinessType.handmade,
      category: TemplateCategory.creative,
      thumbnailUrl: 'assets/templates/handmade/craft_story_thumb.png',
      previewUrl: 'assets/templates/handmade/craft_story_preview.png',
      layout: TemplateLayout(
        type: 'story_layout',
        config: {'sections': 3, 'story_flow': 'vertical'},
        elements: [],
      ),
      style: TemplateStyle(
        primaryColor: '#10B981',
        secondaryColor: '#D1FAE5',
        textColor: '#064E3B',
        backgroundColor: '#ECFDF5',
        fontFamily: 'Handwritten',
        borderRadius: 20,
        customStyles: {'handmade_texture': true},
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPopular: true,
    ),
    // Add more handmade templates...
  ];
}
}