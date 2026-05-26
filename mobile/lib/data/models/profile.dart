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

enum ActivityLevel { sedentary, light, moderate, active, athlete }

extension ActivityLevelX on ActivityLevel {
  String get wireValue => name;

  String get label => switch (this) {
        ActivityLevel.sedentary => 'Sedentary',
        ActivityLevel.light => 'Light',
        ActivityLevel.moderate => 'Moderate',
        ActivityLevel.active => 'Active',
        ActivityLevel.athlete => 'Athlete',
      };

  String get description => switch (this) {
        ActivityLevel.sedentary => 'Desk job, no exercise',
        ActivityLevel.light => '1–3 light workouts / week',
        ActivityLevel.moderate => '3–5 workouts / week',
        ActivityLevel.active => '6–7 workouts / week',
        ActivityLevel.athlete => 'Daily training or athlete',
      };

  double get tdeeMultiplier => switch (this) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.light => 1.375,
        ActivityLevel.moderate => 1.55,
        ActivityLevel.active => 1.725,
        ActivityLevel.athlete => 1.9,
      };

  static ActivityLevel? fromWire(String? value) {
    if (value == null) return null;
    for (final l in ActivityLevel.values) {
      if (l.name == value) return l;
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
    this.activityLevel,
    this.targetWeightKg,
    this.avatarUrl,
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
        activityLevel:
            ActivityLevelX.fromWire(json['activity_level'] as String?),
        targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble(),
        avatarUrl: json['avatar_url'] as String?,
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
  final ActivityLevel? activityLevel;
  final double? targetWeightKg;
  final String? avatarUrl;

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
        'activity_level': activityLevel?.wireValue,
        'target_weight_kg': targetWeightKg,
        'avatar_url': avatarUrl,
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
    ActivityLevel? activityLevel,
    double? targetWeightKg,
    String? avatarUrl,
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
        activityLevel: activityLevel ?? this.activityLevel,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        avatarUrl: avatarUrl ?? this.avatarUrl,
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
        activityLevel,
        targetWeightKg,
        avatarUrl,
      ];
}
