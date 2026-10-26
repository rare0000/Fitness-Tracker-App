import '../entities/nutrition_log.dart';
import '../entities/user_profile.dart';

abstract class NutritionRepository {
  // vartotojo profilis
  Future<UserProfile> getUserProfile();

  // profilio saugojimas
  Future<void> saveUserProfile(UserProfile profile);

  // 7 dienu mityba
  Future<List<NutritionLog>> getLogsForLastWeek();

  // naujas mitybos irasas
  Future<void> saveNutritionLog(NutritionLog log);
}