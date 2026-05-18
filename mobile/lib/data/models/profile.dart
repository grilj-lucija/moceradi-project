import 'package:equatable/equatable.dart';

enum Gender { male, female, other }

extension GenderX on Gender {
  String get wireValue => name;

  static Gender? fromWire(String? value) {
    if (value == null) return null;
    for (final g in Gender.values) {
      if (g.name == value) return g;
    }
    return null;
  }
}

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.username,
    this.displayName,
    this.gender,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.onboardedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        email: json['email'] as String?,
        username: json['username'] as String?,
        displayName: json['display_name'] as String?,
        gender: GenderX.fromWire(json['gender'] as String?),
        dateOfBirth: json['date_of_birth'] == null
            ? null
            : DateTime.parse(json['date_of_birth'] as String),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        onboardedAt: json['onboarded_at'] == null
            ? null
            : DateTime.parse(json['onboarded_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  final String id;
  final String? email;
  final String? username;
  final String? displayName;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final double? heightCm;
  final double? weightKg;
  final DateTime? onboardedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOnboarded => onboardedAt != null;

  String get presentationName {
    final name = (displayName ?? '').trim();
    if (name.isNotEmpty) return name;
    return username ?? 'Athlete';
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    var years = now.year - dateOfBirth!.year;
    final hadBirthday = (now.month > dateOfBirth!.month) ||
        (now.month == dateOfBirth!.month && now.day >= dateOfBirth!.day);
    if (!hadBirthday) years -= 1;
    return years;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'display_name': displayName,
        'gender': gender?.wireValue,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'onboarded_at': onboardedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Profile copyWith({
    String? email,
    String? username,
    String? displayName,
    Gender? gender,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    DateTime? onboardedAt,
    DateTime? updatedAt,
  }) =>
      Profile(
        id: id,
        email: email ?? this.email,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        onboardedAt: onboardedAt ?? this.onboardedAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        displayName,
        gender,
        dateOfBirth,
        heightCm,
        weightKg,
        onboardedAt,
        createdAt,
        updatedAt,
      ];
}
