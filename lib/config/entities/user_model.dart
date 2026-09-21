import 'package:floww/config/theme/app_mode.dart';

enum AuthProvider { apple, google, email }

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.provider,
    required this.mode,
    required this.onboardingCompleted,
    required this.answersSubmitted,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
    this.phoneNumber,
    this.fcmToken,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final AuthProvider provider;
  final AppThemeMode mode;
  final bool onboardingCompleted;
  final bool answersSubmitted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;
  final String? phoneNumber;
  final List<String>? fcmToken;

  UserModel withAvatarUrl(String? avatarUrl) => UserModel(
    uid: uid,
    email: email,
    displayName: displayName,
    avatarUrl: avatarUrl,
    provider: provider,
    mode: mode,
    onboardingCompleted: onboardingCompleted,
    answersSubmitted: answersSubmitted,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastLoginAt: lastLoginAt,
    phoneNumber: phoneNumber,
    fcmToken: fcmToken,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    provider: AuthProvider.values.byName(json['provider'] as String),
    mode: AppThemeMode.values.byName(json['mode'] as String),
    onboardingCompleted: json['onboardingCompleted'] as bool,
    answersSubmitted: json['answersSubmitted'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    phoneNumber: json['phoneNumber'] as String?,
    fcmToken: (json['fcmToken'] as List<dynamic>?)?.cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'provider': provider.name,
    'mode': mode.name,
    'onboardingCompleted': onboardingCompleted,
    'answersSubmitted': answersSubmitted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastLoginAt': lastLoginAt.toIso8601String(),
    'phoneNumber': phoneNumber,
    'fcmToken': fcmToken,
  };
}
