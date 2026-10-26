import '../../domain/entities/nutrition_log.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/local_datasource.dart';

// duomenys
class NutritionRepositoryImpl implements NutritionRepository {
  final LocalDataSource _local;
  NutritionRepositoryImpl(this._local);

  // vartotojo profilis
  @override
  Future<UserProfile> getUserProfile() => _local.getUserProfile();

  // profilio saugojimas
  @override
  Future<void> saveUserProfile(UserProfile profile) =>
      _local.saveUserProfile(profile);

  // 7 dienu mityba
  @override
  Future<List<NutritionLog>> getLogsForLastWeek() =>
      _local.getLogsForLastWeek();

  // naujas mitybos irasas
  @override
  Future<void> saveNutritionLog(NutritionLog log) =>
      _local.saveNutritionLog(log);
}