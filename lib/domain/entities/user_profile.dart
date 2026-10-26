// vartotojo profilis
class UserProfile {
  final String userId;
  final DateTime appStartDate;
  final bool calibrationComplete;
  final int loggedDaysCount;

  const UserProfile({
    required this.userId,
    required this.appStartDate,
    required this.calibrationComplete,
    this.loggedDaysCount = 0,
  });

  // kalibravimo logika
  bool get isInCalibrationPhase {
    if (calibrationComplete) return false;
    return loggedDaysCount < 7;
  }

  // kalibravimo dienu skaiciavimas
  int get daysRemainingInCalibration {
    if (calibrationComplete) return 0;
    return (7 - loggedDaysCount).clamp(0, 7);
  }


  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? 'user_123',
      appStartDate: json['appStartDate'] != null
          ? DateTime.parse(json['appStartDate'])
          : DateTime.now(),
      calibrationComplete: json['calibrationComplete'] ?? false,
      loggedDaysCount: json['loggedDaysCount'] ?? 0,
    );
  }

  // convert i json
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'appStartDate': appStartDate.toIso8601String(),
      'calibrationComplete': calibrationComplete,
      'loggedDaysCount': loggedDaysCount,
    };
  }

  // atnaujinimas
  UserProfile copyWith({
    int? loggedDaysCount,
    bool? calibrationComplete,
    DateTime? appStartDate,
  }) {
    return UserProfile(
      userId: userId,
      appStartDate: appStartDate ?? this.appStartDate,
      calibrationComplete: calibrationComplete ?? this.calibrationComplete,
      loggedDaysCount: loggedDaysCount ?? this.loggedDaysCount,
    );
  }
}