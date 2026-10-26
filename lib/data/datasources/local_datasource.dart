import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/nutrition_log.dart';
import '../../domain/entities/user_profile.dart';
import 'package:uuid/uuid.dart';

class LocalDataSource {
  static const _userKey = 'user_profile';
  static const _logsKey = 'nutrition_logs';

  Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);

    // unikaliu dienu skaiciavimas
    final loggedDaysCount = await _countLoggedDays(prefs);

    if (json == null) {
      final newUser = UserProfile(
        userId: const Uuid().v4(),
        appStartDate: DateTime.now(),
        calibrationComplete: false,
        loggedDaysCount: loggedDaysCount,
      );
      await saveUserProfile(newUser);
      return newUser;
    }

    final map = jsonDecode(json) as Map<String, dynamic>;
    return UserProfile.fromJson(map).copyWith(
      loggedDaysCount: loggedDaysCount,
    );
  }

  Future<int> _countLoggedDays(SharedPreferences prefs) async {
    final jsonList = prefs.getStringList(_logsKey) ?? [];
    final uniqueDays = <String>{};
    for (final entry in jsonList) {
      try {
        final m = jsonDecode(entry) as Map<String, dynamic>;
        final dateStr = m['date'] as String?;
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          // unikalios dienos raktas
          uniqueDays.add(
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
        }
      } catch (_) {}
    }
    return uniqueDays.length;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(profile.toJson()));
  }

  Future<List<NutritionLog>> getLogsForLastWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_logsKey) ?? [];
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    return jsonList
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .where((m) {
      try {
        return DateTime.parse(m['date'] as String).isAfter(weekAgo);
      } catch (_) {
        return false;
      }
    })
        .map((m) => NutritionLog(
      id: m['id'] as String? ?? const Uuid().v4(),
      date: DateTime.parse(m['date'] as String),
      calories: (m['calories'] as num? ?? 0).toDouble(),
      protein: (m['protein'] as num? ?? 0).toDouble(),
      carbs: (m['carbs'] as num? ?? 0).toDouble(),
      fiber: (m['fiber'] as num? ?? 0).toDouble(),
      sugars: (m['sugars'] as num? ?? 0).toDouble(),
      fat: (m['fat'] as num? ?? 0).toDouble(),
      saturatedFat: (m['saturatedFat'] as num? ?? 0).toDouble(),
      cholesterol: (m['cholesterol'] as num? ?? 0).toDouble(),
      omega3: (m['omega3'] as num? ?? 0).toDouble(),
      omega6: (m['omega6'] as num? ?? 0).toDouble(),
      sodium: (m['sodium'] as num? ?? 0).toDouble(),
      potassium: (m['potassium'] as num? ?? 0).toDouble(),
      calcium: (m['calcium'] as num? ?? 0).toDouble(),
      magnesiumMg: (m['magnesiumMg'] as num? ?? 0).toDouble(),
      ironMg: (m['ironMg'] as num? ?? 0).toDouble(),
      zinc: (m['zinc'] as num? ?? 0).toDouble(),
      vitaminA: (m['vitaminA'] as num? ?? 0).toDouble(),
      vitaminC: (m['vitaminC'] as num? ?? 0).toDouble(),
      vitaminDMcg: (m['vitaminDMcg'] as num? ?? 0).toDouble(),
      vitaminE: (m['vitaminE'] as num? ?? 0).toDouble(),
      vitaminK: (m['vitaminK'] as num? ?? 0).toDouble(),
      vitaminB12: (m['vitaminB12'] as num? ?? 0).toDouble(),
      folate: (m['folate'] as num? ?? 0).toDouble(),
    ))
        .toList();
  }

  Future<void> saveNutritionLog(NutritionLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_logsKey) ?? [];
    existing.add(jsonEncode({
      'id': log.id,
      'date': log.date.toIso8601String(),
      'calories': log.calories,
      'protein': log.protein,
      'carbs': log.carbs,
      'fiber': log.fiber,
      'sugars': log.sugars,
      'fat': log.fat,
      'saturatedFat': log.saturatedFat,
      'cholesterol': log.cholesterol,
      'omega3': log.omega3,
      'omega6': log.omega6,
      'sodium': log.sodium,
      'potassium': log.potassium,
      'calcium': log.calcium,
      'magnesiumMg': log.magnesiumMg,
      'ironMg': log.ironMg,
      'zinc': log.zinc,
      'vitaminA': log.vitaminA,
      'vitaminC': log.vitaminC,
      'vitaminDMcg': log.vitaminDMcg,
      'vitaminE': log.vitaminE,
      'vitaminK': log.vitaminK,
      'vitaminB12': log.vitaminB12,
      'folate': log.folate,
    }));
    await prefs.setStringList(_logsKey, existing);
  }
}