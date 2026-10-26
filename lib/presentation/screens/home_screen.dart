import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/usecases/analyze_nutrition_week.dart';
import '../../domain/entities/nutrition_log.dart';
import '../providers/app_providers.dart';
import '../widgets/calibration_progress_bar.dart';
import 'workout_screen.dart';

// pagrindinis ekranas
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final recommendationAsync = ref.watch(workoutRecommendationProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _Header(),
              const SizedBox(height: 16),

              // kalibravimo juosta
              userAsync.when(
                data: (user) => user.isInCalibrationPhase
                    ? Column(children: [
                  CalibrationProgressBar(user: user),
                  const SizedBox(height: 16),
                ])
                    : const SizedBox(),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              // mitybos trukumai
              const _NutrientAlertSection(),
              const SizedBox(height: 16),

              // treniruotes kortele
              recommendationAsync.when(
                data: (rec) {
                  final logs = ref.watch(weekLogsProvider).value ?? [];
                  if (logs.isEmpty) {
                    return const _NoDataWorkoutCard();
                  }
                  return _WorkoutCard(recommendation: rec);
                },
                loading: () => const _LoadingCard(),
                error: (e, _) => const SizedBox(),
              ),
              const SizedBox(height: 24),

              // greiti veiksmai
              const Text('Greiti veiksmai',
                  style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Įvesti mitybą',
                      color: const Color(0xFFFF6B35),
                      onTap: () => context.push('/log'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Treniruotė',
                      color: AppTheme.primary,
                      onTap: () => context.push('/workout'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.bar_chart_rounded,
                      label: 'Progresas',
                      color: AppTheme.accent,
                      onTap: () => context.push('/progress'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.person_rounded,
                      label: 'Profilis',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => context.push('/profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
             ],
          ),
        ),
      ),
    );
  }
}

// antraste
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Labas rytas'
        : hour < 18
        ? 'Laba diena'
        : 'Labas vakaras';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting,
            style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('FitBalance',
            style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1)),
      ],
    );
  }
}

// trukumu sekcija
class _NutrientAlertSection extends ConsumerWidget {
  const _NutrientAlertSection();

  // visi elementai
  static const _allDefs = [
    _NutrientDef('Geležis', Icons.opacity_rounded, Color(0xFFE63946),
        'iron', 8, 'Jautiena, špinatai, lęšiai, avižos'),
    _NutrientDef('Magnis', Icons.bolt_rounded, Color(0xFF4361EE),
        'magnesium', 350, 'Migdolai, juodasis šokoladas, avižos, špinatai'),
    _NutrientDef('Vitaminas D', Icons.wb_sunny_outlined, Color(0xFFF4A261),
        'vitaminD', 15, 'Lašiša, tunas, kiaušiniai. 15 min. saulėje kasdien'),
    _NutrientDef('Vitaminas B12', Icons.science_outlined, Color(0xFF8B5CF6),
        'vitaminB12', 2.4, 'Jautiena, lašiša, kiaušiniai, pienas'),
    _NutrientDef('Vitaminas C', Icons.eco_outlined, Color(0xFF1DB954),
        'vitaminC', 82, 'Paprikos, apelsinai, braškės, brokoliai'),
    _NutrientDef('Kalcis', Icons.dashboard_outlined, Color(0xFF00D4AA),
        'calcium', 1000, 'Pienas, varškė, jogurtas, sezamo sėklos'),
    _NutrientDef('Baltymai', Icons.egg_outlined, Color(0xFF4361EE),
        'protein', 50, 'Vištiena, kiaušiniai, varškė, lęšiai, tunas'),
    _NutrientDef('Riebalai', Icons.water_drop_outlined, Color(0xFFF4A261),
        'fat', 65, 'Lašiša, migdolai, avokadas, alyvuogių aliejus'),
    _NutrientDef('Cukrus', Icons.grain_rounded, Color(0xFF85C227),
        'sugars', 50, 'Riboti: saldainiai, gaivieji gėrimai, konditerija'),
    _NutrientDef('Cholesterolis', Icons.favorite_outline_rounded, Color(0xFFE63946),
        'cholesterol', 300, 'Avokadas, riešutai, alyvuogių aliejus'),
  ];

  // randam trukumus
  List<_NutrientDef> _getDeficient(List<NutritionLog> logs) {
    double avg(double Function(NutritionLog) fn) =>
        logs.fold(0.0, (s, l) => s + fn(l)) / logs.length;

    final result = <_NutrientDef>[];
    for (final d in _allDefs) {
      double val = 0;
      switch (d.key) {
        case 'iron': val = avg((l) => l.ironMg); break;
        case 'magnesium': val = avg((l) => l.magnesiumMg); break;
        case 'vitaminD': val = avg((l) => l.vitaminDMcg); break;
        case 'vitaminB12': val = avg((l) => l.vitaminB12); break;
        case 'vitaminC': val = avg((l) => l.vitaminC); break;
        case 'calcium': val = avg((l) => l.calcium); break;
        case 'protein': val = avg((l) => l.protein); break;
        case 'fat': val = avg((l) => l.fat); break;
        case 'sugars': val = avg((l) => l.sugars); break;
        case 'cholesterol': val = avg((l) => l.cholesterol); break;
      }
      if (val < d.goal * 0.7 && !result.any((r) => r.key == d.key)) {
        result.add(d);
      }
    }
    return result;
  }

  // detalus trukumu sarasas
  void _showAll(BuildContext context, List<_NutrientDef> deficient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllDeficienciesSheet(deficient: deficient),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(weekLogsProvider);
    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) return const SizedBox();
        final deficient = _getDeficient(logs);

        // jei viskas ok
        if (deficient.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('Geras mitybos balansas šią savaitę',
                    style: TextStyle(
                        color: Color(0xFF1A6B35),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          );
        }

        // 4 pirmi trukumai
        final shown = deficient.take(4).toList();

        return GestureDetector(
          onTap: () => _showAll(context, deficient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trūkumai šią savaitę',
                      style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  Row(children: [
                    Text('${deficient.length} trūkumas(-ų)',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.primary, size: 18),
                  ]),
                ],
              ),
              const SizedBox(height: 10),

              // 2x2 tinklelis
              Row(
                children: [
                  if (shown.length > 0)
                    Expanded(child: _NutrientTile(def: shown[0])),
                  if (shown.length > 1) ...[
                    const SizedBox(width: 10),
                    Expanded(child: _NutrientTile(def: shown[1])),
                  ] else
                    const Expanded(child: SizedBox()),
                ],
              ),
              if (shown.length > 2) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _NutrientTile(def: shown[2])),
                    if (shown.length > 3) ...[
                      const SizedBox(width: 10),
                      Expanded(child: _NutrientTile(def: shown[3])),
                    ] else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ],
              const SizedBox(height: 6),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

// trukumo modelis
class _NutrientDef {
  final String name;
  final IconData icon;
  final Color color;
  final String key;
  final double goal;
  final String suggestion;
  const _NutrientDef(
      this.name, this.icon, this.color, this.key, this.goal, this.suggestion);
}

// trukumo elementas
class _NutrientTile extends StatelessWidget {
  final _NutrientDef def;
  const _NutrientTile({required this.def});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: def.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: def.color.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: def.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(def.icon, color: def.color, size: 17),
          ),
          const SizedBox(height: 8),
          Text('Trūksta',
              style: TextStyle(
                  color: def.color.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          Text(def.name,
              style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// vieno trukumo langas
class _DeficiencySheet extends StatelessWidget {
  final _NutrientDef def;
  const _DeficiencySheet({required this.def});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
                color: def.color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(def.icon, color: def.color, size: 30),
          ),
          const SizedBox(height: 14),
          Text('Trūksta: ${def.name}',
              style: const TextStyle(
                  color: AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Dienos norma: ${def.goal} ${_unit(def.key)}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: def.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: def.color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.restaurant_rounded, color: def.color, size: 16),
                  const SizedBox(width: 8),
                  Text('Kaip papildyti?',
                      style: TextStyle(
                          color: def.color, fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Text(def.suggestion,
                    style: const TextStyle(
                        color: AppTheme.textDark, fontSize: 14, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // matavimo vienetai
  String _unit(String key) {
    switch (key) {
      case 'vitaminD': case 'vitaminB12': return 'µg';
      case 'protein': case 'fat': case 'sugars': return 'g';
      default: return 'mg';
    }
  }
}

// visu trukumu langas
class _AllDeficienciesSheet extends StatelessWidget {
  final List<_NutrientDef> deficient;
  const _AllDeficienciesSheet({required this.deficient});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
      decoration: BoxDecoration(
        color: AppTheme.card,
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Visi trūkumai',
                      style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: AppTheme.bg,
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              shrinkWrap: true,
              children: deficient.isEmpty
                  ? [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('Visi rodikliai normos ribose!',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 15)),
                  ),
                )
              ]
                  : deficient
                  .map((d) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: d.color.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: d.color.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: d.color.withOpacity(0.15),
                          borderRadius:
                          BorderRadius.circular(10)),
                      child: Icon(d.icon,
                          color: d.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(d.name,
                              style: const TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                  Icons.restaurant_rounded,
                                  size: 12,
                                  color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(d.suggestion,
                                    style: const TextStyle(
                                        color:
                                        AppTheme.textMuted,
                                        fontSize: 12,
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends ConsumerWidget {
  final WorkoutRecommendation recommendation;
  const _WorkoutCard({required this.recommendation});

  // pavadinimas pagal trukuma
  String _workoutTitle(WorkoutRecommendation rec) {
    if (!rec.hasDeficiency) return 'Kardio treniruotė';
    switch (rec.deficiencyType) {
      case 'geležis': return 'Atstatomoji joga';
      case 'magnis': return 'Jėgos treniruotė (sumažinta)';
      case 'vitaminas D': return 'Kardio treniruotė lauke';
      case 'vitaminas B12': return 'Jėgos treniruotė (sumažinta)';
      case 'vitaminas C': return 'Kardio treniruotė';
      case 'kalcis': return 'Jėgos treniruotė';
      case 'cinkas': return 'Jėgos treniruotė (sumažinta)';
      case 'kalis': return 'Kardio treniruotė';
      case 'baltymai': return 'Jėgos treniruotė';
      case 'kalorijos': return 'Lengvas atsistatymas';
      default: return 'Kardio treniruotė';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rec = recommendation;
    final color = rec.hasDeficiency ? const Color(0xFFFF6B35) : AppTheme.primary;
    final completedAsync = ref.watch(workoutCompletedTodayProvider);
    final doneToday = completedAsync.value ?? false;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: doneToday
              ? [const Color(0xFF1DB954), const Color(0xFF17A349)]
              : [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                doneToday
                    ? 'Atlikta'
                    : rec.hasDeficiency
                    ? 'Pritaikyta'
                    : 'Rekomenduojama',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              doneToday
                  ? 'Šiandienos treniruotė atlikta!'
                  : _workoutTitle(rec),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 6),
            Text(
              doneToday
                  ? 'Puikus darbas! Mes parinksime jums naują planą rytoj.'
                  : rec.workout.reason,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.5),
            ),
            if (rec.hasDeficiency && !doneToday) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(rec.recommendation,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4))),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// pagalbiniai widgetai
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _NoDataWorkoutCard extends StatelessWidget {
  const _NoDataWorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PLANAS RUOŠIAMAS',
              style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Reikalingi duomenys',
              style: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Suveskite mitybą, kad galėtume parinkti tinkamą krūvį.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

// krovimo langas
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(20)),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}