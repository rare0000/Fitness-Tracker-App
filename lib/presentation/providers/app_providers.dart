import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/entities/nutrition_log.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../domain/usecases/analyze_nutrition_week.dart';

// vietine duomenu baze
final localDataSourceProvider = Provider<LocalDataSource>((_) => LocalDataSource());

// repozitorija
final nutritionRepositoryProvider = Provider<NutritionRepository>(
      (ref) => NutritionRepositoryImpl(ref.read(localDataSourceProvider)),
);

// vartotojo profilis
final userProfileProvider = FutureProvider<UserProfile>((ref) {
  return ref.read(nutritionRepositoryProvider).getUserProfile();
});

// 7 dienu mityba
final weekLogsProvider = FutureProvider<List<NutritionLog>>((ref) {
  return ref.read(nutritionRepositoryProvider).getLogsForLastWeek();
});

// treniruotes rekomendacija
final workoutRecommendationProvider = FutureProvider<WorkoutRecommendation>((ref) async {
  final logs = await ref.watch(weekLogsProvider.future);
  return AnalyzeNutritionWeek().execute(logs);
});