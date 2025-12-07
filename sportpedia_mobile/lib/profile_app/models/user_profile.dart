// Model untuk User Profile
// Sesuai dengan response dari Django API /profile/api/profile/

import 'dart:convert';

/// Parse single UserProfile dari API response
UserProfile userProfileFromJson(String str) {
  final json = jsonDecode(str);
  // API returns {status: true, data: {...}}
  if (json['status'] == true && json['data'] != null) {
    return UserProfile.fromJson(json['data']);
  }
  throw Exception('Invalid response format');
}

/// Convert UserProfile ke JSON string
String userProfileToJson(UserProfile data) => jsonEncode(data.toJson());

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final bool isStaff;
  final bool isSuperuser;
  final ProfileData profile;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.dateJoined,
    this.lastLogin,
    this.isStaff = false,
    this.isSuperuser = false,
    required this.profile,
  });

  /// Factory constructor untuk parsing dari Django API response
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json["id"],
    username: json["username"],
    email: json["email"] ?? "",
    firstName: json["first_name"],
    lastName: json["last_name"],
    dateJoined: DateTime.parse(json["date_joined"]),
    lastLogin: json["last_login"] != null
        ? DateTime.parse(json["last_login"])
        : null,
    isStaff: json["is_staff"] ?? false,
    isSuperuser: json["is_superuser"] ?? false,
    profile: ProfileData.fromJson(json["profile"] ?? {}),
  );

  /// Convert ke JSON untuk update request
  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "date_joined": dateJoined.toIso8601String(),
    "last_login": lastLogin?.toIso8601String(),
    "is_staff": isStaff,
    "is_superuser": isSuperuser,
    "profile": profile.toJson(),
  };

  /// Helper untuk mendapatkan full name
  String get fullName {
    if (firstName != null &&
        firstName!.isNotEmpty &&
        lastName != null &&
        lastName!.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName != null && firstName!.isNotEmpty) {
      return firstName!;
    } else if (lastName != null && lastName!.isNotEmpty) {
      return lastName!;
    }
    return username;
  }

  /// Helper untuk mendapatkan foto profil URL
  String? get profileImage => profile.fotoProfil;

  /// Helper untuk bio (menggunakan preferensi)
  String? get bio => profile.preferensi;

  /// Copy with method untuk update partial data
  UserProfile copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dateJoined,
    DateTime? lastLogin,
    bool? isStaff,
    bool? isSuperuser,
    ProfileData? profile,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      profile: profile ?? this.profile,
    );
  }
}

/// Sub-model untuk data profil dari UserProfile Django
class ProfileData {
  final String olahragaFavorit;
  final String preferensi;
  final String fotoProfil;

  ProfileData({
    this.olahragaFavorit = "",
    this.preferensi = "",
    this.fotoProfil = "",
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    olahragaFavorit: json["olahraga_favorit"] ?? "",
    preferensi: json["preferensi"] ?? "",
    fotoProfil: json["foto_profil"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "olahraga_favorit": olahragaFavorit,
    "preferensi": preferensi,
    "foto_profil": fotoProfil,
  };

  ProfileData copyWith({
    String? olahragaFavorit,
    String? preferensi,
    String? fotoProfil,
  }) {
    return ProfileData(
      olahragaFavorit: olahragaFavorit ?? this.olahragaFavorit,
      preferensi: preferensi ?? this.preferensi,
      fotoProfil: fotoProfil ?? this.fotoProfil,
    );
  }
}
