/// User Model representing a user in the system
class UserModel {
  final String? uid;
  final String email;
  final String? name;
  final String? phone;
  final String? address;
  final String? district;
  final String? neighborhood;
  final String? avatarUrl;
  final String? role;
  final int? roleId; // 0=admin, 1=user, 2=employee
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.uid,
    required this.email,
    this.name,
    this.phone,
    this.address,
    this.district,
    this.neighborhood,
    this.avatarUrl,
    this.role,
    this.roleId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? json['displayName'] ?? json['fullName'],
      phone: json['phone'] ?? json['phoneNumber'],
      address: json['address'],
      district: json['district'],
      neighborhood: json['neighborhood'],
      avatarUrl: json['avatarUrl'] ?? json['photoURL'],
      role: json['role'],
      roleId: json['roleId'] != null ? (json['roleId'] as num).toInt() : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (uid != null) 'uid': uid,
      'email': email,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (district != null) 'district': district,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (role != null) 'role': role,
      if (roleId != null) 'roleId': roleId,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? district,
    String? neighborhood,
    String? avatarUrl,
    String? role,
    int? roleId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      district: district ?? this.district,
      neighborhood: neighborhood ?? this.neighborhood,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      roleId: roleId ?? this.roleId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Get display name (name or email)
  String get displayName => name ?? email.split('@').first;
  
  /// Get full location string (district + neighborhood)
  String get fullLocation {
    if (district != null && neighborhood != null) {
      return '$neighborhood, $district';
    } else if (district != null) {
      return district!;
    } else if (neighborhood != null) {
      return neighborhood!;
    }
    return '';
  }
}
