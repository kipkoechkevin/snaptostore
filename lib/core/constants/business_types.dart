enum BusinessType {
thrift,
boutique,
beauty,
handmade,
general,
}

extension BusinessTypeExtension on BusinessType {
String get displayName {
  switch (this) {
    case BusinessType.thrift:
      return 'Thrift Boss';
    case BusinessType.boutique:
      return 'Boutique Boss';
    case BusinessType.beauty:
      return 'Beauty Boss';
    case BusinessType.handmade:
      return 'Handmade Boss';
    case BusinessType.general:
      return 'General';
  }
}

String get shortName {
  switch (this) {
    case BusinessType.thrift:
      return 'Thrift';
    case BusinessType.boutique:
      return 'Boutique';
    case BusinessType.beauty:
      return 'Beauty';
    case BusinessType.handmade:
      return 'Handmade';
    case BusinessType.general:
      return 'General';
  }
}
}