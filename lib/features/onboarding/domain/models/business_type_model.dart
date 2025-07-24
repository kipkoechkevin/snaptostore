import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BusinessTypeModel {
final String id;
final String title;
final String subtitle;
final String description;
final String detailDescription;
final IconData icon;
final BusinessColorScheme colorScheme;
final List<String> features;
final String templateCount;
final bool isPopular;

const BusinessTypeModel({
  required this.id,
  required this.title,
  required this.subtitle,
  required this.description,
  required this.detailDescription,
  required this.icon,
  required this.colorScheme,
  required this.features,
  required this.templateCount,
  this.isPopular = false,
});

static List<BusinessTypeModel> get allBusinessTypes => [
  const BusinessTypeModel(
    id: 'thrift',
    title: 'Thrift Boss',
    subtitle: 'Vintage & Secondhand',
    description: 'Perfect for vintage finds and thrift treasures',
    detailDescription: 'Transform your thrift finds into irresistible listings with vintage-inspired templates and authentic styling.',
    icon: Icons.shopping_bag_outlined,
    colorScheme: BusinessColorScheme.thriftBoss,
    features: [
      'Vintage-style templates',
      'Before/after layouts',
      'Authenticity badges',
      'Size & condition tags',
    ],
    templateCount: '25+',
    isPopular: true,
  ),
  
  const BusinessTypeModel(
    id: 'boutique',
    title: 'Boutique Boss',
    subtitle: 'Clean & Professional',
    description: 'Clean, professional layouts for retail items',
    detailDescription: 'Create stunning product displays with clean, minimalist templates that make your inventory look premium.',
    icon: Icons.store_outlined,
    colorScheme: BusinessColorScheme.boutiqueBoss,
    features: [
      'Clean minimal layouts',
      'Multi-angle views',
      'Professional backgrounds',
      'Brand consistency tools',
    ],
    templateCount: '30+',
  ),
  
  const BusinessTypeModel(
    id: 'beauty',
    title: 'Beauty Boss',
    subtitle: 'Skincare & Cosmetics',
    description: 'Stunning templates for beauty products',
    detailDescription: 'Showcase your beauty products with elegant, Instagram-ready templates designed for skincare and cosmetics.',
    icon: Icons.face_retouching_natural,
    colorScheme: BusinessColorScheme.beautyBoss,
    features: [
      'Ingredient highlights',
      'Before/after layouts',
      'Lifestyle integration',
      'Skin tone matching',
    ],
    templateCount: '35+',
    isPopular: true,
  ),
  
  const BusinessTypeModel(
    id: 'handmade',
    title: 'Handmade Boss',
    subtitle: 'Artisan & Crafts',
    description: 'Showcase your handmade creations beautifully',
    detailDescription: 'Highlight the artisan quality of your handmade items with warm, authentic templates that tell your craft story.',
    icon: Icons.palette_outlined,
    colorScheme: BusinessColorScheme.handmadeBoss,
    features: [
      'Craft process stories',
      'Material showcases',
      'Artisan branding',
      'Custom color palettes',
    ],
    templateCount: '28+',
  ),
];
}