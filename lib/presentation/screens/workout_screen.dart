import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../../domain/entities/nutrition_log.dart';

final workoutCompletedTodayProvider = FutureProvider.autoDispose<bool>((ref) async {
  return await WorkoutPlanGenerator.completedToday();
});

// pratimo modelis
class Exercise {
  final String nameLt;
  final String? lottieAsset;
  final int sets;
  final String reps;
  final int durationSeconds;
  final int restSeconds;
  final String description;
  final bool wasModified;
  final String? modificationReason;

  const Exercise({
    required this.nameLt,
    this.lottieAsset,
    required this.sets,
    required this.reps,
    this.durationSeconds = 0,
    required this.restSeconds,
    required this.description,
    this.wasModified = false,
    this.modificationReason,
  });
}

// plano modelis
class WorkoutPlan {
  final String name;
  final String type;
  final String reason;
  final String intensity;
  final Color intensityColor;
  final List<Exercise> exercises;
  final int estimatedMinutes;

  const WorkoutPlan({
    required this.name,
    required this.type,
    required this.reason,
    required this.intensity,
    required this.intensityColor,
    required this.exercises,
    required this.estimatedMinutes,
  });
}

// plano generatorius
class WorkoutPlanGenerator {
  static const _lastTypeKey = 'last_workout_type';
  static const _lastDateKey = 'last_workout_date';

  // patikra del siandienos
  static Future<bool> completedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastDateKey) ?? '';
    if (lastDateStr.isEmpty) return false;
    final lastDate = DateTime.parse(lastDateStr);
    final now = DateTime.now();
    return lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day;
  }

  // pagrindine generavimo logika
  static Future<WorkoutPlan> generate(List<NutritionLog> weekLogs) async {
    final prefs = await SharedPreferences.getInstance();
    final lastType = prefs.getString(_lastTypeKey) ?? '';
    final lastDateStr = prefs.getString(_lastDateKey) ?? '';

    bool sportedYesterday = false;
    if (lastDateStr.isNotEmpty) {
      final lastDate = DateTime.parse(lastDateStr);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      sportedYesterday = lastDate.year == yesterday.year &&
          lastDate.month == yesterday.month &&
          lastDate.day == yesterday.day;
    }

    final ironDefDays = weekLogs.where((l) => l.ironMg < 8).length;
    final magDefDays = weekLogs.where((l) => l.magnesiumMg < 300).length;
    final avgCal = weekLogs.isEmpty
        ? 2000.0
        : weekLogs.fold(0.0, (s, l) => s + l.calories) / weekLogs.length;
    final lowEnergy = avgCal < 1500;
    final reduced = magDefDays >= 3 || ironDefDays >= 3;

    if (lowEnergy) return lightPlan('Mažai kalorijų šią savaitę kūnas turi pailsėti.');
    if (sportedYesterday && lastType == 'cardio') {
      return ironDefDays >= 3
          ? yogaPlan('Vakar kardio ir geležies trūkumas todėl šiandien atsistatymo diena.')
          : strengthPlan('Vakar buvo kardio šiandien stipriname raumenis.', reduced);
    }
    if (sportedYesterday && lastType == 'strength') {
      return ironDefDays >= 4
          ? yogaPlan('Vakar jėga ir geležies trūkumas reikalingas atsistatymas.')
          : cardioPlan('Vakar jėga šiandien kardio.', reduced);
    }
    if (ironDefDays >= 5) return yogaPlan('$ironDefDays d. iš 7 trūko geležies perjungiama į jogą.');
    if (magDefDays >= 4) return strengthPlan('Magnio trūkumas vidutinio intensyvumo treniruotė.', true);
    return cardioPlan('Puikus mitybos balansas treniruokis intensyviai!', false);
  }

  // uzbaigimo fiksavimas
  static Future<void> markCompleted(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTypeKey, type);
    await prefs.setString(_lastDateKey, DateTime.now().toIso8601String());
  }

  // kardio sablonas
  static WorkoutPlan cardioPlan(String reason, bool reduced) => WorkoutPlan(
    name: reduced ? 'Kardio treniruotė (lengva)' : 'Kardio treniruotė',
    type: 'cardio',
    reason: reason,
    intensity: reduced ? 'Lengvas' : 'Intensyvus',
    intensityColor: reduced ? const Color(0xFF85C227) : const Color(0xFFE63946),
    estimatedMinutes: reduced ? 15 : 20,
    exercises: [
      Exercise(
        nameLt: 'Burpee šuoliai',
        lottieAsset: 'assets/lottie/Burpee_and_Jump_Exercise.json',
        sets: reduced ? 2 : 3,
        reps: reduced ? '6 kartų' : '10 kartų',
        restSeconds: reduced ? 60 : 45,
        description: 'Nusileisk į grindis atsispausk ir šok aukštyn.',
        wasModified: reduced,
        modificationReason: reduced ? 'Kartojimų skaičius sumažintas dėl mineralų trūkumo' : null,
      ),
      Exercise(
        nameLt: 'Šuoliai pritūpus',
        lottieAsset: 'assets/lottie/Jumping_squats.json',
        sets: reduced ? 2 : 3,
        reps: reduced ? '8 kartų' : '12 kartų',
        restSeconds: reduced ? 50 : 35,
        description: 'Tūpk žemyn ir šok aukštyn stiprina kojas ir širdį.',
        wasModified: reduced,
        modificationReason: reduced ? 'Serijos sumažintos dėl energijos trūkumo' : null,
      ),
      Exercise(
        nameLt: 'Žengimo šuoliai',
        lottieAsset: 'assets/lottie/Split_Jump_Exercise.json',
        sets: reduced ? 2 : 3,
        reps: reduced ? '8 kartų' : '12 kartų',
        restSeconds: reduced ? 50 : 35,
        description: 'Ženk į priekį ir šok aukštyn, keisdamas kojas.',
        wasModified: reduced,
        modificationReason: reduced ? 'Kartojimų skaičius sumažintas' : null,
      ),
      Exercise(
        nameLt: 'Bėgimas vietoje',
        lottieAsset: 'assets/lottie/cardio.json',
        sets: reduced ? 1 : 2,
        reps: '',
        durationSeconds: reduced ? 30 : 45,
        restSeconds: reduced ? 40 : 30,
        description: 'Bėk vietoje keldamas kelius iki juosmens.',
      ),
    ],
  );

  // jegos sablonas
  static WorkoutPlan strengthPlan(String reason, bool reduced) => WorkoutPlan(
    name: reduced ? 'Jėgos treniruotė (sumažinta)' : 'Jėgos treniruotė',
    type: 'strength',
    reason: reason,
    intensity: reduced ? 'Vidutinis (sumažintas)' : 'Vidutinis',
    intensityColor: reduced ? const Color(0xFF85C227) : const Color(0xFF4361EE),
    estimatedMinutes: reduced ? 15 : 25,
    exercises: [
      Exercise(
        nameLt: 'Pakaitiniai atsispaudimai',
        lottieAsset: 'assets/lottie/Staggered_push_ups.json',
        sets: reduced ? 2 : 4,
        reps: reduced ? '6 kartų' : '10 kartų',
        restSeconds: reduced ? 75 : 60,
        description: 'Rankos skirtinguose lygiuose stiprina krūtinę ir tricepsus.',
        wasModified: reduced,
        modificationReason: reduced ? 'Serijos sumažintos dėl magnio trūkumo' : null,
      ),
      Exercise(
        nameLt: 'Pritūpimas su išsitiesimais',
        lottieAsset: 'assets/lottie/Squat_Reach.json',
        sets: reduced ? 2 : 4,
        reps: reduced ? '8 kartų' : '12 kartų',
        restSeconds: reduced ? 60 : 50,
        description: 'Tūpkite žemyn tada ištieskite rankas į viršų.',
        wasModified: reduced,
        modificationReason: reduced ? 'Krūvis sumažintas dėl mineralų balanso' : null,
      ),
      Exercise(
        nameLt: 'Atvirkštiniai pilvo pratimai',
        lottieAsset: 'assets/lottie/Reverse_Crunches.json',
        sets: reduced ? 2 : 3,
        reps: reduced ? '8 kartų' : '12 kartų',
        restSeconds: reduced ? 45 : 35,
        description: 'Gulėdamas ant nugaros kelk kojas aukštyn.',
        wasModified: reduced,
        modificationReason: reduced ? 'Serijos sumažintos' : null,
      ),
      Exercise(
        nameLt: 'Sėdimi pilvo ratai',
        lottieAsset: 'assets/lottie/Seated_abs_circles.json',
        sets: reduced ? 2 : 3,
        reps: reduced ? '8 k. kiekvienai pusei' : '12 k. kiekvienai pusei',
        restSeconds: reduced ? 40 : 30,
        description: 'Stiprina šoninius pilvo raumenis judėk lėtai.',
      ),
    ],
  );

  // jogos sablonas
  static WorkoutPlan yogaPlan(String reason) => WorkoutPlan(
    name: 'Atstatomoji joga',
    type: 'yoga',
    reason: reason,
    intensity: 'Lengvas',
    intensityColor: const Color(0xFF1DB954),
    estimatedMinutes: 15,
    exercises: [
      Exercise(
        nameLt: 'Joga',
        lottieAsset: 'assets/lottie/yoga.json',
        sets: 1,
        reps: '',
        durationSeconds: 120,
        restSeconds: 15,
        description: 'Atsipalaiduok ir sek animaciją kvėpuok giliai.',
      ),
      Exercise(
        nameLt: 'Sėdimi pilvo ratai',
        lottieAsset: 'assets/lottie/Seated_abs_circles.json',
        sets: 2,
        reps: '10 k. kiekvienai pusei',
        restSeconds: 15,
        description: 'Švelnus šoninių raumenų aktyvinimas. Judėk lėtai ir sąmoningai.',
      ),
      Exercise(
        nameLt: 'Atvirkštiniai pilvo pratimai',
        lottieAsset: 'assets/lottie/Reverse_Crunches.json',
        sets: 2,
        reps: '8 kartų',
        restSeconds: 20,
        description: 'Lėtai ir kontroliuotai nekelt kojų per aukštai.',
      ),
      Exercise(
        nameLt: 'Pritūpimas su ištiesimais',
        lottieAsset: 'assets/lottie/Squat_Reach.json',
        sets: 2,
        reps: '8 kartų',
        restSeconds: 20,
        description: 'Lėtas tempimas tūpk lėtai laikyk apačioje.',
      ),
    ],
  );

  // lengvas sablonas
  static WorkoutPlan lightPlan(String reason) => WorkoutPlan(
    name: 'Lengvas atsistatymas',
    type: 'light',
    reason: reason,
    intensity: 'Labai lengvas',
    intensityColor: const Color(0xFF00D4AA),
    estimatedMinutes: 10,
    exercises: [
      Exercise(
        nameLt: 'Joga',
        lottieAsset: 'assets/lottie/yoga.json',
        sets: 1,
        reps: '',
        durationSeconds: 90,
        restSeconds: 10,
        description: 'Labai švelnus tempimas. Klausykis kūno ir nepersistenk.',
      ),
      Exercise(
        nameLt: 'Sėdimi pilvo ratai',
        lottieAsset: 'assets/lottie/Seated_abs_circles.json',
        sets: 2,
        reps: '8 k. kiekvienai pusei',
        restSeconds: 20,
        description: 'Labai švelnus judesys klausykis kūno.',
      ),
      Exercise(
        nameLt: 'Pritūpimas su ištiesimais',
        lottieAsset: 'assets/lottie/Squat_Reach.json',
        sets: 2,
        reps: '6 kartų',
        restSeconds: 20,
        description: 'Lėtas ir kontroliuotas judėjimas.',
      ),
    ],
  );
}

// trniruotes ekranas
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(weekLogsProvider);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Treniruotė')),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const _NoDataWithLibraryView();
          }

          return FutureBuilder<bool>(
            future: WorkoutPlanGenerator.completedToday(),
            builder: (ctx, todaySnap) {
              if (!todaySnap.hasData) return const Center(child: CircularProgressIndicator());
              final isDone = todaySnap.data!;

              if (isDone) return const _CompletedStateView();

              return FutureBuilder<WorkoutPlan>(
                future: WorkoutPlanGenerator.generate(logs),
                builder: (ctx2, snap) => snap.hasData
                    ? _PlanOverview(plan: snap.data!)
                    : const Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Klaida: $e')),
      ),
    );
  }
}

// atliktos dienos langas
class _CompletedStateView extends StatelessWidget {
  const _CompletedStateView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.4)),
            ),
            child: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('Šiandienos treniruotė atlikta! Gali treniruotis dar.',
                    style: TextStyle(
                        color: Color(0xFF1A6B35),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          const _TomorrowTimerCard(),
          const SizedBox(height: 36),
          const Text('Paprastų pratimų biblioteka',
              style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          const SizedBox(height: 16),
          _WorkoutLibrary(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// rytojaus laikmatis
class _TomorrowTimerCard extends StatefulWidget {
  const _TomorrowTimerCard();

  @override
  State<_TomorrowTimerCard> createState() => _TomorrowTimerCardState();
}

class _TomorrowTimerCardState extends State<_TomorrowTimerCard> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateTimeLeft());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (mounted) {
      setState(() {
        _timeLeft = tomorrow.difference(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes.remainder(60);
    final seconds = _timeLeft.inSeconds.remainder(60);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_outlined, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(height: 20),
          const Text('Rytdienos treniruotė',
              style: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Prieinama po: $hours val. $minutes min. $seconds sek.',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

// plano apzvalga
class _PlanOverview extends StatelessWidget {
  final WorkoutPlan plan;
  const _PlanOverview({required this.plan});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Šiandienos planas',
              style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [plan.intensityColor, plan.intensityColor.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _HeroPill(plan.intensity),
                    const SizedBox(width: 8),
                    _HeroPill('~${plan.estimatedMinutes} min.'),
                    const SizedBox(width: 8),
                    _HeroPill('${plan.exercises.length} pratimų'),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 15),
                        const SizedBox(width: 8),
                        Expanded(child: Text(plan.reason,
                            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.5))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...plan.exercises.asMap().entries.map((e) =>
              _ExercisePreviewCard(exercise: e.value, index: e.key)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _ActiveWorkoutScreen(plan: plan))),
            child: Container(
              width: double.infinity, height: 54,
              decoration: BoxDecoration(
                  color: AppTheme.textDark,
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text('Pradėti šiandienos planą',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 36),
          const Text('Paprastų pratimų biblioteka',
              style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          const SizedBox(height: 16),
          _WorkoutLibrary(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// treniruociu biblioteka
class _WorkoutLibrary extends StatelessWidget {
  static final List<WorkoutPlan> _allPlans = [
    WorkoutPlanGenerator.cardioPlan('Papildoma kardio treniruotė', false),
    WorkoutPlanGenerator.cardioPlan('Lengva kardio treniruotė', true),
    WorkoutPlanGenerator.strengthPlan('Jėgos treniruotė', false),
    WorkoutPlanGenerator.strengthPlan('Lengva jėgos treniruotė', true),
    WorkoutPlanGenerator.yogaPlan('Atsistatymo joga'),
    WorkoutPlanGenerator.lightPlan('Lengvas atsistatymas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _allPlans
          .map((plan) => _LibraryCard(plan: plan))
          .toList(),
    );
  }
}

// bibliotekos kortele
class _LibraryCard extends StatelessWidget {
  final WorkoutPlan plan;
  const _LibraryCard({required this.plan});

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LibraryDetailSheet(plan: plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: plan.intensityColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: plan.intensityColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconForType(plan.type),
                  color: plan.intensityColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name,
                      style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _SmallPill(plan.intensity, plan.intensityColor),
                      _SmallPill('~${plan.estimatedMinutes} min.', AppTheme.textMuted),
                      _SmallPill('${plan.exercises.length} prat.', AppTheme.textMuted),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showDetail(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppTheme.textMuted, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _ActiveWorkoutScreen(plan: plan))),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: plan.intensityColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'cardio': return Icons.directions_run_rounded;
      case 'strength': return Icons.fitness_center_rounded;
      case 'yoga': return Icons.self_improvement_rounded;
      default: return Icons.accessibility_new_rounded;
    }
  }
}

// bibliotekos detaliu langas
class _LibraryDetailSheet extends StatelessWidget {
  final WorkoutPlan plan;
  const _LibraryDetailSheet({required this.plan});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: plan.intensityColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    plan.type == 'cardio'
                        ? Icons.directions_run_rounded
                        : plan.type == 'strength'
                        ? Icons.fitness_center_rounded
                        : Icons.self_improvement_rounded,
                    color: plan.intensityColor, size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name,
                          style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      Row(children: [
                        _SmallPill(plan.intensity, plan.intensityColor),
                        const SizedBox(width: 6),
                        _SmallPill('~${plan.estimatedMinutes} min.', AppTheme.textMuted),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close_rounded,
                        color: AppTheme.textMuted, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              shrinkWrap: true,
              itemCount: plan.exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final ex = plan.exercises[i];
                final isTimed = ex.durationSeconds > 0;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: plan.intensityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: TextStyle(
                                  color: plan.intensityColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex.nameLt,
                                style: const TextStyle(
                                    color: AppTheme.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(children: [
                              _SmallPill('${ex.sets} ser.', AppTheme.primary),
                              const SizedBox(width: 5),
                              _SmallPill(
                                isTimed
                                    ? '${ex.durationSeconds} sek.'
                                    : ex.reps,
                                const Color(0xFFFF6B35),
                              ),
                              const SizedBox(width: 5),
                              _SmallPill(
                                'Poilsis: ${ex.restSeconds}s',
                                AppTheme.textMuted,
                              ),
                            ]),
                            const SizedBox(height: 6),
                            Text(ex.description,
                                style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                    height: 1.4)),
                            if (ex.lottieAsset != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 120,
                                  child: Lottie.asset(
                                    ex.lottieAsset!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => _ActiveWorkoutScreen(plan: plan)));
              },
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  color: plan.intensityColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Pradėti treniruotę',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// spalvota etikete
class _HeroPill extends StatelessWidget {
  final String text;
  const _HeroPill(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
    child: Text(text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// pratimo perziuros kortele
class _ExercisePreviewCard extends StatefulWidget {
  final Exercise exercise;
  final int index;
  const _ExercisePreviewCard({required this.exercise, required this.index});

  @override
  State<_ExercisePreviewCard> createState() => _ExercisePreviewCardState();
}

class _ExercisePreviewCardState extends State<_ExercisePreviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final isTimed = ex.durationSeconds > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ex.wasModified
              ? const Color(0xFFF4A261).withOpacity(0.5)
              : Colors.grey.withOpacity(0.1),
          width: ex.wasModified ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text('${widget.index + 1}',
                          style: const TextStyle(color: AppTheme.primary,
                              fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(ex.nameLt,
                                  style: const TextStyle(color: AppTheme.textDark,
                                      fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                            if (ex.wasModified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4A261).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFF4A261).withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.tune_rounded, size: 11, color: Color(0xFFE65100)),
                                    SizedBox(width: 3),
                                    Text('Koreguota',
                                        style: TextStyle(color: Color(0xFFE65100),
                                            fontSize: 10, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          _SmallPill('${ex.sets} ser.', AppTheme.primary),
                          const SizedBox(width: 5),
                          _SmallPill(
                              isTimed ? '${ex.durationSeconds} sek.' : ex.reps,
                              const Color(0xFFFF6B35)),
                          const SizedBox(width: 5),
                          _SmallPill('Poilsis: ${ex.restSeconds}s', AppTheme.textMuted),
                        ]),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textMuted, size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Column(children: [
              Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ex.wasModified && ex.modificationReason != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF4A261).withOpacity(0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFE65100), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pratimas koreguotas',
                                      style: TextStyle(color: Color(0xFFE65100),
                                          fontSize: 12, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(ex.modificationReason!,
                                      style: const TextStyle(
                                          color: Color(0xFFBF360C), fontSize: 12, height: 1.4)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (ex.lottieAsset != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity, height: 180,
                          color: AppTheme.bg,
                          child: Lottie.asset(ex.lottieAsset!, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(ex.description,
                        style: const TextStyle(color: AppTheme.textDark, fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
            ]),
        ],
      ),
    );
  }
}

// maza etikete
class _SmallPill extends StatelessWidget {
  final String text;
  final Color color;
  const _SmallPill(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
    child: Text(text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );
}

// aktyvios treniruotes ekranas
enum _Phase { countdown, exercise, reps, rest, done }

class _ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutPlan plan;
  const _ActiveWorkoutScreen({required this.plan});

  @override
  ConsumerState<_ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<_ActiveWorkoutScreen> {
  int _exerciseIndex = 0;
  int _setIndex = 0;
  _Phase _phase = _Phase.countdown;
  int _secondsLeft = 3;
  int _countdownStep = 3;
  Timer? _timer;
  Timer? _durationTimer;
  int _totalSeconds = 0;

  Exercise get _currentExercise => widget.plan.exercises[_exerciseIndex];
  bool get _isTimed => _currentExercise.durationSeconds > 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _totalSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  // atbulinis skaiciavimas
  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.countdown;
      _countdownStep = 3;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdownStep > 0) {
        setState(() => _countdownStep--);
      } else {
        t.cancel();
        _startExercise();
      }
    });
  }

  // pratimo pradzia
  void _startExercise() {
    if (!_isTimed) {
      setState(() { _phase = _Phase.reps; });
      return;
    }
    setState(() { _phase = _Phase.exercise; _secondsLeft = _currentExercise.durationSeconds; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) { t.cancel(); _finishSet(); }
      else { setState(() => _secondsLeft--); }
    });
  }

  // serijos pabaiga
  void _finishSet() async {
    _timer?.cancel();
    final ex = _currentExercise;
    final isLastSet = _setIndex >= ex.sets - 1;
    final isLastExercise = _exerciseIndex >= widget.plan.exercises.length - 1;

    if (isLastSet && isLastExercise) {
      _durationTimer?.cancel();
      await WorkoutPlanGenerator.markCompleted(widget.plan.type);

      ref.invalidate(workoutCompletedTodayProvider);

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => _DoneScreen(
            planName: widget.plan.name,
            durationSeconds: _totalSeconds,
            exerciseCount: widget.plan.exercises.length,
          ),
        ));
      }
      return;
    }

    final restSec = ex.restSeconds > 0 ? ex.restSeconds : 15;
    setState(() { _phase = _Phase.rest; _secondsLeft = restSec; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        _nextStep(isLastSet, isLastExercise);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // sekantis zingsnis
  void _nextStep(bool isLastSet, bool isLastExercise) {
    if (isLastSet) {
      setState(() { _exerciseIndex++; _setIndex = 0; });
    } else {
      setState(() => _setIndex++);
    }
    _startCountdown();
  }

  // laiko pridejimas
  void _addTime(int s) => setState(() => _secondsLeft += s);

  @override
  Widget build(BuildContext context) {
    final ex = _currentExercise;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          title: Text(widget.plan.name,
              style: const TextStyle(fontSize: 16)), backgroundColor: AppTheme.bg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _ProgressBar(
              total: widget.plan.exercises.length,
              current: _exerciseIndex,
              set: _setIndex,
              totalSets: ex.sets,
            ),
            const SizedBox(height: 20),
            Text(ex.nameLt,
                style: const TextStyle(color: AppTheme.textDark, fontSize: 22,
                    fontWeight: FontWeight.w800, letterSpacing: -0.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (_phase == _Phase.countdown)
              _CountdownWidget(step: _countdownStep)
            else if (_phase == _Phase.exercise || _phase == _Phase.reps)
              _ExerciseWidget(
                exercise: ex,
                phase: _phase,
                secondsLeft: _secondsLeft,
                onAddTime: () => _addTime(10),
                onDone: _finishSet,
              )
            else if (_phase == _Phase.rest)
                _RestWidget(
                  seconds: _secondsLeft,
                  totalRest: ex.restSeconds > 0 ? ex.restSeconds : 15,
                  onAddTime: () => _addTime(10),
                  onSkip: () {
                    _timer?.cancel();
                    final isLastSet = _setIndex >= ex.sets - 1;
                    final isLastExercise =
                        _exerciseIndex >= widget.plan.exercises.length - 1;
                    _nextStep(isLastSet, isLastExercise);
                  },
                ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// eigos juosta
class _ProgressBar extends StatelessWidget {
  final int total, current, set, totalSets;
  const _ProgressBar({required this.total, required this.current, required this.set, required this.totalSets});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 24 : 8, height: 8,
          decoration: BoxDecoration(
            color: i < current ? const Color(0xFF1DB954)
                : i == current ? AppTheme.primary
                : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
      const SizedBox(height: 6),
      Text('Pratimas ${current + 1} iš $total · Serija ${set + 1}/$totalSets',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
    ],
  );
}

// starto laikmatis
class _CountdownWidget extends StatelessWidget {
  final int step;
  const _CountdownWidget({required this.step});

  @override
  Widget build(BuildContext context) {
    final isGo = step == 0;
    final text = isGo ? 'GO!' : '$step';
    final color = isGo ? const Color(0xFF1DB954) : AppTheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Center(
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 100,
                fontWeight: FontWeight.w900,
                letterSpacing: -4)),
      ),
    );
  }
}

// pratimo eiga
class _ExerciseWidget extends StatelessWidget {
  final Exercise exercise;
  final _Phase phase;
  final int secondsLeft;
  final VoidCallback onAddTime, onDone;

  const _ExerciseWidget({
    required this.exercise, required this.phase, required this.secondsLeft,
    required this.onAddTime, required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isTimed = phase == _Phase.exercise;
    return Column(children: [
      Container(
        width: double.infinity, height: 220,
        decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: exercise.lottieAsset != null
              ? Lottie.asset(exercise.lottieAsset!, fit: BoxFit.contain)
              : const SizedBox(),
        ),
      ),
      const SizedBox(height: 20),
      if (isTimed) ...[
        Text('$secondsLeft',
            style: const TextStyle(color: AppTheme.textDark, fontSize: 72,
                fontWeight: FontWeight.w900, letterSpacing: -2)),
        const Text('sekundžių', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onAddTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 18),
              SizedBox(width: 6),
              Text('+10 sekundžių',
                  style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ] else ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(exercise.reps,
                style: const TextStyle(color: AppTheme.primary, fontSize: 28, fontWeight: FontWeight.w800)),
            const Text('Atlik šį skaičių kartojimų',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ]),
        ),
      ],
      const SizedBox(height: 16),
      Text(exercise.description,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
          textAlign: TextAlign.center),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: onDone,
        child: Container(
          width: double.infinity, height: 54,
          decoration: BoxDecoration(color: AppTheme.textDark, borderRadius: BorderRadius.circular(14)),
          child: const Center(
            child: Text('Baigiau', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ]);
  }
}

// poilsio ekranas
class _RestWidget extends StatelessWidget {
  final int seconds, totalRest;
  final VoidCallback onAddTime, onSkip;

  const _RestWidget({
    required this.seconds,
    required this.totalRest,
    required this.onAddTime,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = totalRest > 0
        ? (seconds / totalRest).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: const Color(0xFF1DB954).withOpacity(0.3), width: 1.5),
      ),
      child: Column(children: [
        const Text('Poilsis',
            style: TextStyle(
                color: Color(0xFF1A6B35),
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('$seconds',
            style: const TextStyle(
                color: Color(0xFF1DB954),
                fontSize: 64,
                fontWeight: FontWeight.w900,
                letterSpacing: -2)),
        const Text('sekundžių',
            style: TextStyle(
                color: Color(0xFF2E7D32), fontSize: 14)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: Colors.white,
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1DB954)),
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: onAddTime,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF1DB954).withOpacity(0.3)),
                ),
                child: const Center(
                    child: Text('+10 sek.',
                        style: TextStyle(
                            color: Color(0xFF1A6B35),
                            fontSize: 14,
                            fontWeight: FontWeight.w600))),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onSkip,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Text('Tęsti',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700))),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// treniruotes suvestine
class _DoneScreen extends StatefulWidget {
  final String planName;
  final int durationSeconds;
  final int exerciseCount;
  const _DoneScreen({required this.planName, required this.durationSeconds, required this.exerciseCount});

  @override
  State<_DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<_DoneScreen> with TickerProviderStateMixin {
  late AnimationController _confettiCtrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..forward();
    final rng = Random();
    _particles = List.generate(40, (i) => _Particle(
      x: rng.nextDouble(),
      speed: 0.3 + rng.nextDouble() * 0.7,
      size: 5 + rng.nextDouble() * 6,
      color: [
        AppTheme.primary, const Color(0xFF1DB954), const Color(0xFFFF6B35),
        const Color(0xFFF4A261), const Color(0xFF4361EE), const Color(0xFFE63946),
      ][i % 6],
      wobble: rng.nextDouble() * 2 * 3.14,
    ));
  }

  @override
  void dispose() { _confettiCtrl.dispose(); super.dispose(); }

  // sudegintos kalorijos
  int get _calories => (widget.durationSeconds / 60 * 5).round();

  // trukmes formatas
  String get _duration {
    final m = widget.durationSeconds ~/ 60;
    final s = widget.durationSeconds % 60;
    return m > 0 ? '${m}min ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        AnimatedBuilder(
          animation: _confettiCtrl,
          builder: (_, __) => CustomPaint(
            painter: _ConfettiPainter(_particles, _confettiCtrl.value),
            child: const SizedBox.expand(),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF1DB954), size: 50),
                ),
                const SizedBox(height: 20),
                const Text('Treniruotė baigta!',
                    style: TextStyle(color: AppTheme.textDark, fontSize: 28, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(widget.planName,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
                    textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Row(children: [
                  _StatCard(label: 'Trukmė', value: _duration,
                      icon: Icons.timer_rounded, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Sudeginta', value: '~$_calories kcal',
                      icon: Icons.local_fire_department_rounded, color: const Color(0xFFFF6B35)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _StatCard(label: 'Pratimai', value: '${widget.exerciseCount} atlikta',
                      icon: Icons.fitness_center_rounded, color: const Color(0xFF4361EE)),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Serijos', value: 'Visos baigtos',
                      icon: Icons.check_circle_rounded, color: const Color(0xFF1DB954)),
                ]),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Container(
                    width: double.infinity, height: 54,
                    decoration: BoxDecoration(
                        color: AppTheme.textDark, borderRadius: BorderRadius.circular(14)),
                    child: const Center(
                      child: Text('Grįžti į pradžią',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// statistikos kortele
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ]),
    ),
  );
}

class _NoDataWithLibraryView extends StatelessWidget {
  const _NoDataWithLibraryView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Icon(Icons.auto_awesome_outlined,
                    color: AppTheme.primary.withOpacity(0.5), size: 40),
                const SizedBox(height: 16),
                const Text(
                  'Laukiama mitybos duomenų',
                  style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Suveskite šiandienos mitybą, kad algoritmas galėtų sugeneruoti personalizuotą planą.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Paprastų pratimų biblioteka',
              style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          const SizedBox(height: 16),
          _WorkoutLibrary(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// konfeti dalele
class _Particle {
  final double x, speed, size, wobble;
  final Color color;
  const _Particle({required this.x, required this.speed, required this.size, required this.color, required this.wobble});
}

// konfeti animacija
class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  const _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final x = p.x * size.width + sin(t * 6.28 * 2 + p.wobble) * 40;
      final y = -20 + t * (size.height + 40);
      final opacity = t > 0.85 ? (1.0 - t) / 0.15 : 1.0;
      final paint = Paint()
        ..color = p.color.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 10);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.5),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}