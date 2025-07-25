import 'package:equatable/equatable.dart';
import '../../../../core/constants/business_types.dart'; // ✅ Import shared enum

class TemplateModel extends Equatable {
final String id;
final String name;
final String description;
final BusinessType businessType;
final TemplateCategory category;
final String thumbnailUrl;
final String previewUrl;
final TemplateLayout layout;
final TemplateStyle style;
final bool isPremium;
final bool isPopular;
final bool isFeatured;
final int usageCount;
final DateTime createdAt;
final DateTime updatedAt;

const TemplateModel({
  required this.id,
  required this.name,
  required this.description,
  required this.businessType,
  required this.category,
  required this.thumbnailUrl,
  required this.previewUrl,
  required this.layout,
  required this.style,
  this.isPremium = false,
  this.isPopular = false,
  this.isFeatured = false,
  this.usageCount = 0,
  required this.createdAt,
  required this.updatedAt,
});

@override
List<Object?> get props => [
  id, name, description, businessType, category, thumbnailUrl, previewUrl,
  layout, style, isPremium, isPopular, isFeatured, usageCount, createdAt, updatedAt,
];
}

// ✅ Remove the BusinessType enum from here since it's now in shared constants

enum TemplateCategory {
product,
lifestyle,
minimal,
vintage,
modern,
professional,
creative,
social,
}

class TemplateLayout {
final String type;
final Map<String, dynamic> config;
final List<TemplateElement> elements;

const TemplateLayout({
  required this.type,
  required this.config,
  required this.elements,
});
}

class TemplateElement {
final String id;
final ElementType type;
final Map<String, dynamic> properties;
final ElementPosition position;
final ElementSize size;

const TemplateElement({
  required this.id,
  required this.type,
  required this.properties,
  required this.position,
  required this.size,
});
}

enum ElementType {
image,
text,
logo,
badge,
border,
background,
shape,
}

class ElementPosition {
final double x;
final double y;
final PositionType type;

const ElementPosition({
  required this.x,
  required this.y,
  required this.type,
});
}

enum PositionType {
absolute,
relative,
center,
}

class ElementSize {
final double width;
final double height;
final SizeType type;

const ElementSize({
  required this.width,
  required this.height,
  required this.type,
});
}

enum SizeType {
fixed,
percentage,
auto,
}

class TemplateStyle {
final String primaryColor;
final String secondaryColor;
final String textColor;
final String backgroundColor;
final String fontFamily;
final double borderRadius;
final Map<String, dynamic> customStyles;

const TemplateStyle({
  required this.primaryColor,
  required this.secondaryColor,
  required this.textColor,
  required this.backgroundColor,
  required this.fontFamily,
  required this.borderRadius,
  required this.customStyles,
});
}