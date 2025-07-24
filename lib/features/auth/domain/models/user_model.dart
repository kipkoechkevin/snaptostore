import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
final String id;
final String email;
final String? fullName;
final String? businessType;
final String? businessName;
final String? profileImageUrl;
final DateTime createdAt;
final DateTime updatedAt;
final bool isPremium;
final DateTime? premiumExpiresAt;

const UserModel({
  required this.id,
  required this.email,
  this.fullName,
  this.businessType,
  this.businessName,
  this.profileImageUrl,
  required this.createdAt,
  required this.updatedAt,
  this.isPremium = false,
  this.premiumExpiresAt,
});

factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String?,
    businessType: json['business_type'] as String?,
    businessName: json['business_name'] as String?,
    profileImageUrl: json['profile_image_url'] as String?,
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    isPremium: json['is_premium'] as bool? ?? false,
    premiumExpiresAt: json['premium_expires_at'] != null 
        ? DateTime.parse(json['premium_expires_at'])
        : null,
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'email': email,
    'full_name': fullName,
    'business_type': businessType,
    'business_name': businessName,
    'profile_image_url': profileImageUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_premium': isPremium,
    'premium_expires_at': premiumExpiresAt?.toIso8601String(),
  };
}

UserModel copyWith({
  String? id,
  String? email,
  String? fullName,
  String? businessType,
  String? businessName,
  String? profileImageUrl,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? isPremium,
  DateTime? premiumExpiresAt,
}) {
  return UserModel(
    id: id ?? this.id,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    businessType: businessType ?? this.businessType,
    businessName: businessName ?? this.businessName,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isPremium: isPremium ?? this.isPremium,
    premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
  );
}

@override
List<Object?> get props => [
  id, email, fullName, businessType, businessName, 
  profileImageUrl, createdAt, updatedAt, isPremium, premiumExpiresAt
];
}