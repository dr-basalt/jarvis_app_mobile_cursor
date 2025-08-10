import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? provider; // google, facebook, github
  final bool isAdmin;
  final bool isSuperAdmin;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? profile;
  
  // Bio-hacking data
  final String? birthDate;
  final String? birthPlace;
  final String? zodiacSign;
  final String? mbtiType;
  final String? hollandCode;
  final List<String>? cliftonStrengths;
  final Map<String, dynamic>? humanDesign;
  
  // Calendar integration
  final bool calendarEnabled;
  final String? googleCalendarId;
  final List<String>? calendarIds;
  
  // Music preferences
  final String? spotifyUserId;
  final List<String>? favoriteGenres;
  final Map<String, dynamic>? musicPreferences;
  
  // Emotional tracking
  final List<EmotionalCheckin>? emotionalHistory;
  final Map<String, dynamic>? emotionalPatterns;
  
  // Routines
  final List<Routine>? routines;
  final Map<String, dynamic>? routinePreferences;
  
  // Notes and RAG
  final List<String>? noteIds;
  final Map<String, dynamic>? ragPreferences;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.provider,
    this.isAdmin = false,
    this.isSuperAdmin = false,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
    this.profile,
    this.birthDate,
    this.birthPlace,
    this.zodiacSign,
    this.mbtiType,
    this.hollandCode,
    this.cliftonStrengths,
    this.humanDesign,
    this.calendarEnabled = false,
    this.googleCalendarId,
    this.calendarIds,
    this.spotifyUserId,
    this.favoriteGenres,
    this.musicPreferences,
    this.emotionalHistory,
    this.emotionalPatterns,
    this.routines,
    this.routinePreferences,
    this.noteIds,
    this.ragPreferences,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? provider,
    bool? isAdmin,
    bool? isSuperAdmin,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? profile,
    String? birthDate,
    String? birthPlace,
    String? zodiacSign,
    String? mbtiType,
    String? hollandCode,
    List<String>? cliftonStrengths,
    Map<String, dynamic>? humanDesign,
    bool? calendarEnabled,
    String? googleCalendarId,
    List<String>? calendarIds,
    String? spotifyUserId,
    List<String>? favoriteGenres,
    Map<String, dynamic>? musicPreferences,
    List<EmotionalCheckin>? emotionalHistory,
    Map<String, dynamic>? emotionalPatterns,
    List<Routine>? routines,
    Map<String, dynamic>? routinePreferences,
    List<String>? noteIds,
    Map<String, dynamic>? ragPreferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      isAdmin: isAdmin ?? this.isAdmin,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      profile: profile ?? this.profile,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      mbtiType: mbtiType ?? this.mbtiType,
      hollandCode: hollandCode ?? this.hollandCode,
      cliftonStrengths: cliftonStrengths ?? this.cliftonStrengths,
      humanDesign: humanDesign ?? this.humanDesign,
      calendarEnabled: calendarEnabled ?? this.calendarEnabled,
      googleCalendarId: googleCalendarId ?? this.googleCalendarId,
      calendarIds: calendarIds ?? this.calendarIds,
      spotifyUserId: spotifyUserId ?? this.spotifyUserId,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      musicPreferences: musicPreferences ?? this.musicPreferences,
      emotionalHistory: emotionalHistory ?? this.emotionalHistory,
      emotionalPatterns: emotionalPatterns ?? this.emotionalPatterns,
      routines: routines ?? this.routines,
      routinePreferences: routinePreferences ?? this.routinePreferences,
      noteIds: noteIds ?? this.noteIds,
      ragPreferences: ragPreferences ?? this.ragPreferences,
    );
  }

  bool get hasAdminAccess => isAdmin || isSuperAdmin;
  bool get hasCalendarAccess => calendarEnabled && googleCalendarId != null;
  bool get hasMusicAccess => spotifyUserId != null;
  bool get hasBioHackingData => birthDate != null && birthPlace != null;
}

@JsonSerializable()
class EmotionalCheckin {
  final String id;
  final DateTime timestamp;
  final String emotion;
  final int intensity; // 1-10
  final String? notes;
  final Map<String, dynamic>? context;
  final String? recommendedAction;
  final String? musicRecommendation;

  const EmotionalCheckin({
    required this.id,
    required this.timestamp,
    required this.emotion,
    required this.intensity,
    this.notes,
    this.context,
    this.recommendedAction,
    this.musicRecommendation,
  });

  factory EmotionalCheckin.fromJson(Map<String, dynamic> json) => _$EmotionalCheckinFromJson(json);
  Map<String, dynamic> toJson() => _$EmotionalCheckinToJson(this);
}

@JsonSerializable()
class Routine {
  final String id;
  final String name;
  final String description;
  final String type; // work, personal, startup
  final List<String> activities;
  final Duration estimatedDuration;
  final Map<String, dynamic>? conditions;
  final bool isActive;
  final DateTime? lastExecuted;
  final int executionCount;

  const Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.activities,
    required this.estimatedDuration,
    this.conditions,
    this.isActive = true,
    this.lastExecuted,
    this.executionCount = 0,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineToJson(this);
}
