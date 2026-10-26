import 'package:fitness_nutrition_app/core/constants/app_constants.dart';
import '../entities/nutrition_log.dart';
import '../entities/workout.dart';

// sprendimu medzio algoritmas
class AnalyzeNutritionWeek {
  WorkoutRecommendation execute(List<NutritionLog> weekLogs) {
    // jei nera duomenu
    if (weekLogs.isEmpty) return _defaultRecommendation();

    // vidurkio skaiciavimas
    double avg(double Function(NutritionLog) fn) =>
        weekLogs.fold(0.0, (s, l) => s + fn(l)) / weekLogs.length;

    // trukumu skaiciavimas
    final ironDef = weekLogs.where((l) => l.ironMg < AppConstants.ironDailyGoalMg).length;
    final magDef = weekLogs.where((l) => l.magnesiumMg < AppConstants.magnesiumDailyGoalMg).length;
    final vitDDef = weekLogs.where((l) => l.vitaminDMcg < AppConstants.vitaminDDailyGoalMcg).length;
    final vitB12Def = weekLogs.where((l) => l.vitaminB12 < AppConstants.vitaminB12DailyGoalMcg).length;
    final vitCDef = weekLogs.where((l) => l.vitaminC < AppConstants.vitaminCDailyGoalMg).length;
    final calciumDef = weekLogs.where((l) => l.calcium < AppConstants.calciumDailyGoalMg).length;
    final zincDef = weekLogs.where((l) => l.zinc < AppConstants.zincDailyGoalMg).length;
    final potassiumDef = weekLogs.where((l) => l.potassium < AppConstants.potassiumDailyGoalMg).length;

    final avgCalories = avg((l) => l.calories);
    final avgProtein = avg((l) => l.protein);

    final lowCalories = avgCalories < 1500;
    final lowProtein = avgProtein < 40;

    // mazai kaloriju
    if (lowCalories) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Lengvas atsistatymas',
          type: WorkoutType.rest,
          lottieAsset: 'assets/lottie/yoga.json',
          description: 'Labai lengvas judėjimas',
          reason: 'Mažai kalorijų šią savaitę — kūnas turi pailsėti.',
        ),
        hasDeficiency: true,
        deficiencyType: 'kalorijos',
        recommendation: 'Vartokite daugiau kalorijų: avižos, riešutai, avokadas.',
      );
    }

    // gelezies trukumas
    if (ironDef >= AppConstants.deficiencyThresholdDays) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Atstatomoji joga',
          type: WorkoutType.yoga,
          lottieAsset: 'assets/lottie/yoga.json',
          description: 'Lengvas tempimas ir kvėpavimo pratimai',
          reason: 'Geležies trūkumas $ironDef dieną(-as) iš 7 — intensyvi kardio keičiama į jogą.',
        ),
        hasDeficiency: true,
        deficiencyType: 'geležis',
        recommendation: 'Vartokite: jautieną, špinatų, lęšių, avižų.',
      );
    }

    // vitamino b12 trukumas
    if (vitB12Def >= 4) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Jėgos treniruotė (sumažinta)',
          type: WorkoutType.strength,
          lottieAsset: 'assets/lottie/Staggered_push_ups.json',
          description: 'Vidutinio intensyvumo raumenų stiprinimas',
          reason: 'Vitamino B12 trūkumas ($vitB12Def d.) mažina energiją — sumažintas krūvis.',
        ),
        hasDeficiency: true,
        deficiencyType: 'vitaminas B12',
        recommendation: 'Vartokite: jautieną, lašišą, kiaušinius, pieną.',
      );
    }

    // vitamino d trukumas
    if (vitDDef >= 4) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Lauko kardio',
          type: WorkoutType.cardio,
          lottieAsset: 'assets/lottie/cardio.json',
          description: 'Bėgimas ar greitas ėjimas lauke',
          reason: 'Vitamino D trūkumas ($vitDDef d.) — rekomenduojama treniruotis lauke saulėje.',
        ),
        hasDeficiency: true,
        deficiencyType: 'vitaminas D',
        recommendation: 'Leiskite 15-30 min. saulėje. Vartokite: lašišą, tuną.',
      );
    }

    // magnio trukumas
    if (magDef >= 4) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Jėgos treniruotė (sumažinta)',
          type: WorkoutType.strength,
          lottieAsset: 'assets/lottie/Staggered_push_ups.json',
          description: 'Vidutinio intensyvumo raumenų stiprinimas',
          reason: 'Magnio trūkumas ($magDef d.) — sumažintas krūvis raumenų apsaugai.',
        ),
        hasDeficiency: true,
        deficiencyType: 'magnis',
        recommendation: 'Vartokite: migdolus, šokoladą, avižas, špinatų.',
      );
    }

    // vitamino c trukumas
    if (vitCDef >= 4) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Bėgimas vietoje',
          type: WorkoutType.cardio,
          lottieAsset: 'assets/lottie/cardio.json',
          description: 'Vidutinio intensyvumo kardio',
          reason: 'Vitamino C trūkumas ($vitCDef d.) — kardio skatina imuninę sistemą.',
        ),
        hasDeficiency: true,
        deficiencyType: 'vitaminas C',
        recommendation: 'Vartokite: paprikas, apelsinus, brokoli.',
      );
    }

    // kalcio trukumas
    if (calciumDef >= 4) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Jėgos treniruotė',
          type: WorkoutType.strength,
          lottieAsset: 'assets/lottie/Squat_Reach.json',
          description: 'Kaulų ir raumenų stiprinimas',
          reason: 'Kalcio trūkumas ($calciumDef d.) — jėgos treniruotė stiprina kaulus.',
        ),
        hasDeficiency: true,
        deficiencyType: 'kalcis',
        recommendation: 'Vartokite: pieną, varškę, jogurtą.',
      );
    }

    // cinko trukumas
    if (zincDef >= 4) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Jėgos treniruotė (sumažinta)',
          type: WorkoutType.strength,
          lottieAsset: 'assets/lottie/Staggered_push_ups.json',
          description: 'Vidutinio intensyvumo treniruotė',
          reason: 'Cinko trūkumas ($zincDef d.) mažina imuninę sistemą — sumažintas krūvis.',
        ),
        hasDeficiency: true,
        deficiencyType: 'cinkas',
        recommendation: 'Vartokite: jautieną, migdolus, avižas.',
      );
    }

    // mazai baltymu
    if (lowProtein) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Jėgos treniruotė',
          type: WorkoutType.strength,
          lottieAsset: 'assets/lottie/Staggered_push_ups.json',
          description: 'Raumenų stiprinimas',
          reason: 'Mažai baltymų — jėgos treniruotė skatina baltymų poreikį ir raumenų augimą.',
        ),
        hasDeficiency: true,
        deficiencyType: 'baltymai',
        recommendation: 'Vartokite: vištienos krūtinėlę, kiaušinius, varškę.',
      );
    }

    // kalio trukumas
    if (potassiumDef >= 4) {
      return WorkoutRecommendation(
        workout: Workout(
          name: 'Bėgimo treniruotė',
          type: WorkoutType.cardio,
          lottieAsset: 'assets/lottie/cardio.json',
          description: 'Širdies ir kraujagyslių stiprinimas',
          reason: 'Kalio trūkumas ($potassiumDef d.) — kardio stiprina širdį.',
        ),
        hasDeficiency: true,
        deficiencyType: 'kalis',
        recommendation: 'Vartokite: bananą, bulvę, špinatų, lęšių.',
      );
    }

    // nera trukumu
    return WorkoutRecommendation(
      workout: Workout(
        name: 'Bėgimas vietoje',
        type: WorkoutType.cardio,
        lottieAsset: 'assets/lottie/cardio.json',
        description: 'Bėgimas vietoje',
        reason: 'Puikus mitybos balansas! Treniruokitės intensyviai.',
      ),
      hasDeficiency: false,
      deficiencyType: '',
      recommendation: 'Tęskite gerą mitybą!',
    );
  }

  // standartine treniruote (pradziai)
  WorkoutRecommendation _defaultRecommendation() => WorkoutRecommendation(
    workout: Workout(
      name: 'Standartinė treniruotė',
      type: WorkoutType.cardio,
      lottieAsset: 'assets/lottie/cardio.json',
      description: 'Bendrojo kūno kondicionavimas',
      reason: 'Pirmoji savaitė — renkame duomenis.',
    ),
    hasDeficiency: false,
    deficiencyType: '',
    recommendation: 'Pradėkite vesti mitybos dienoraštį!',
  );
}

// rekomendacijos
class WorkoutRecommendation {
  final Workout workout;
  final bool hasDeficiency;
  final String deficiencyType;
  final String recommendation;

  const WorkoutRecommendation({
    required this.workout,
    required this.hasDeficiency,
    required this.deficiencyType,
    required this.recommendation,
  });
}