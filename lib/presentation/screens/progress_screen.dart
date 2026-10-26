import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../../domain/entities/nutrition_log.dart';
import 'workout_screen.dart';

// mitybos tikslai
class _Goals {
  static const double calories = 2250;
  static const double protein = 75;
  static const double carbs = 275;
  static const double fat = 65;
  static const double fiber = 30;
  static const double sugars = 50;
  static const double saturatedFat = 20;
  static const double cholesterol = 300;
  static const double omega3 = 1.6;
  static const double omega6 = 17;
  static const double sodium = 2300;
  static const double potassium = 3500;
  static const double calcium = 1000;
  static const double magnesium = 350;
  static const double iron = 8;
  static const double zinc = 9;
  static const double vitaminA = 800;
  static const double vitaminC = 82;
  static const double vitaminD = 17;
  static const double vitaminE = 15;
  static const double vitaminK = 105;
  static const double vitaminB12 = 2.4;
  static const double folate = 400;
}

// dienos duomenu modelis
class DayData {
  final DateTime date;
  final double calories, protein, carbs, fat, fiber, sugars, saturatedFat;
  final double cholesterol, omega3, omega6;
  final double sodium, potassium, calcium, magnesium, iron, zinc;
  final double vitaminA, vitaminC, vitaminD, vitaminE, vitaminK, vitaminB12, folate;

  DayData({
    required this.date,
    required this.calories, required this.protein, required this.carbs,
    required this.fat, required this.fiber, required this.sugars,
    required this.saturatedFat, required this.cholesterol,
    required this.omega3, required this.omega6,
    required this.sodium, required this.potassium, required this.calcium,
    required this.magnesium, required this.iron, required this.zinc,
    required this.vitaminA, required this.vitaminC, required this.vitaminD,
    required this.vitaminE, required this.vitaminK, required this.vitaminB12,
    required this.folate,
  });

  factory DayData.fromLogs(DateTime date, List<NutritionLog> logs) => DayData(
    date: date,
    calories: logs.fold(0, (s, l) => s + l.calories),
    protein: logs.fold(0, (s, l) => s + l.protein),
    carbs: logs.fold(0, (s, l) => s + l.carbs),
    fat: logs.fold(0, (s, l) => s + l.fat),
    fiber: logs.fold(0, (s, l) => s + l.fiber),
    sugars: logs.fold(0, (s, l) => s + l.sugars),
    saturatedFat: logs.fold(0, (s, l) => s + l.saturatedFat),
    cholesterol: logs.fold(0, (s, l) => s + l.cholesterol),
    omega3: logs.fold(0, (s, l) => s + l.omega3),
    omega6: logs.fold(0, (s, l) => s + l.omega6),
    sodium: logs.fold(0, (s, l) => s + l.sodium),
    potassium: logs.fold(0, (s, l) => s + l.potassium),
    calcium: logs.fold(0, (s, l) => s + l.calcium),
    magnesium: logs.fold(0, (s, l) => s + l.magnesiumMg),
    iron: logs.fold(0, (s, l) => s + l.ironMg),
    zinc: logs.fold(0, (s, l) => s + l.zinc),
    vitaminA: logs.fold(0, (s, l) => s + l.vitaminA),
    vitaminC: logs.fold(0, (s, l) => s + l.vitaminC),
    vitaminD: logs.fold(0, (s, l) => s + l.vitaminDMcg),
    vitaminE: logs.fold(0, (s, l) => s + l.vitaminE),
    vitaminK: logs.fold(0, (s, l) => s + l.vitaminK),
    vitaminB12: logs.fold(0, (s, l) => s + l.vitaminB12),
    folate: logs.fold(0, (s, l) => s + l.folate),
  );
}

// progreso ekranas
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final logsAsync = ref.watch(weekLogsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Progresas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // kalibravimo kortele
            userAsync.when(
              data: (user) => user.isInCalibrationPhase
                  ? Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kalibravimo fazė',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Liko ${user.daysRemainingInCalibration} d.',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: 1 - (user.daysRemainingInCalibration / 7),
                                minHeight: 6,
                                backgroundColor: Colors.white.withOpacity(0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${((1 - user.daysRemainingInCalibration / 7) * 100).round()}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ])
                  : const SizedBox(),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            // duomenu atvaizdavimas
            logsAsync.when(
              data: (logs) {
                // irasu grupavimas
                final Map<String, List<NutritionLog>> byDay = {};
                for (final log in logs) {
                  final key =
                      '${log.date.year}-${log.date.month.toString().padLeft(2, '0')}-${log.date.day.toString().padLeft(2, '0')}';
                  byDay.putIfAbsent(key, () => []).add(log);
                }

                // tusciu dienu pridejimas
                final now = DateTime.now();
                for (int i = 0; i < 7; i++) {
                  final d = now.subtract(Duration(days: i));
                  final key =
                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                  byDay.putIfAbsent(key, () => []);
                }

                // dienu rikiavimas
                final days = byDay.entries
                    .map((e) => DayData.fromLogs(DateTime.parse(e.key), e.value))
                    .toList()
                  ..sort((a, b) => b.date.compareTo(a.date));

                // savaites rezultatai
                final weekData = DayData.fromLogs(DateTime.now(), logs);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Savaitės apžvalga',
                      subtitle: '',
                      icon: Icons.calendar_view_week_rounded,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _WeeklySummaryCard(
                      data: weekData,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => WeekDetailScreen(data: weekData)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionHeader(
                      title: 'Dienos istorija',
                      subtitle: '',
                      icon: Icons.today_rounded,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 12),

                    // dienu sarasas
                    if (days.isEmpty)
                      _EmptyState()
                    else
                      ...days.map((day) => _DaySummaryCard(
                        day: day,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DayDetailScreen(day: day)),
                        ),
                      )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Klaida: $e'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// sekcijos antraste
class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title, required this.subtitle,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            Text(subtitle,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

// savaites apzvalgos kortele
class _WeeklySummaryCard extends StatelessWidget {
  final DayData data;
  final VoidCallback onTap;
  const _WeeklySummaryCard({required this.data, required this.onTap});

  // datos formatavimas
  String _weekRange() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    return '${weekAgo.day}.${weekAgo.month.toString().padLeft(2, '0')} – ${now.day}.${now.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const w = 7.0;
    final calRatio = (data.calories / (_Goals.calories * w)).clamp(0.0, 1.0);
    final protRatio = (data.protein / (_Goals.protein * w)).clamp(0.0, 1.0);
    final carbRatio = (data.carbs / (_Goals.carbs * w)).clamp(0.0, 1.0);
    final fatRatio = (data.fat / (_Goals.fat * w)).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.primary.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_weekRange(),
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                const Text('Žiūrėti viską',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.primary, size: 18),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _WeekMacroChip(label: 'Kalorijos', value: data.calories,
                    unit: 'kcal', color: const Color(0xFFFF6B35), ratio: calRatio),
                const SizedBox(width: 8),
                _WeekMacroChip(label: 'Baltymai', value: data.protein,
                    unit: 'g', color: const Color(0xFF4361EE), ratio: protRatio),
                const SizedBox(width: 8),
                _WeekMacroChip(label: 'Angliavandeniai', value: data.carbs,
                    unit: 'g', color: const Color(0xFFF4A261), ratio: carbRatio),
                const SizedBox(width: 8),
                _WeekMacroChip(label: 'Riebalai', value: data.fat,
                    unit: 'g', color: const Color(0xFFE63946), ratio: fatRatio),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// makroelemento blokelis
class _WeekMacroChip extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final double ratio;
  const _WeekMacroChip({
    required this.label, required this.value,
    required this.unit, required this.color, required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = ratio >= 1.0 ? const Color(0xFF1DB954)
        : ratio >= 0.7 ? const Color(0xFF85C227)
        : ratio >= 0.4 ? const Color(0xFFF4A261)
        : AppTheme.danger;
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            value < 1000
                ? value.toStringAsFixed(0)
                : '${(value / 1000).toStringAsFixed(1)}k',
            style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w800),
          ),
          Text(unit,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio, minHeight: 5,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

// detali savaites apzvalga
class WeekDetailScreen extends StatelessWidget {
  final DayData data;
  const WeekDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const w = 7.0;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final range =
        '${weekAgo.day}.${weekAgo.month.toString().padLeft(2, '0')} – ${now.day}.${now.month.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          title: Text('Savaitė · $range'), backgroundColor: AppTheme.bg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _CalorieHeroCard(
                calories: data.calories, goal: _Goals.calories * w),
            const SizedBox(height: 16),
            Row(children: [
              _MacroTile(label: 'Baltymai', value: data.protein,
                  goal: _Goals.protein * w, unit: 'g', color: const Color(0xFF4361EE)),
              const SizedBox(width: 10),
              _MacroTile(label: 'Angliavandeniai', value: data.carbs,
                  goal: _Goals.carbs * w, unit: 'g', color: const Color(0xFFF4A261)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _MacroTile(label: 'Riebalai', value: data.fat,
                  goal: _Goals.fat * w, unit: 'g', color: const Color(0xFFE63946)),
              const SizedBox(width: 10),
              _MacroTile(label: 'Skaidulos', value: data.fiber,
                  goal: _Goals.fiber * w, unit: 'g', color: const Color(0xFF1DB954)),
            ]),
            const SizedBox(height: 20),
            _DetailGroup(
              title: 'Papildomi makroelementai',
              icon: Icons.grain_rounded,
              color: const Color(0xFFFF6B35),
              items: [
                _DetailItem('Skaidulos', data.fiber, _Goals.fiber * w, 'g'),
                _DetailItem('Cukrus', data.sugars, _Goals.sugars * w, 'g', hasCeiling: true),
                _DetailItem('Sočiosios riebalų r.', data.saturatedFat, _Goals.saturatedFat * w, 'g', hasCeiling: true),
                _DetailItem('Cholesterolis', data.cholesterol, _Goals.cholesterol * w, 'mg', hasCeiling: true),
                _DetailItem('Omega-3', data.omega3, _Goals.omega3 * w, 'g'),
                _DetailItem('Omega-6', data.omega6, _Goals.omega6 * w, 'g'),
              ],
            ),
            const SizedBox(height: 14),
            _DetailGroup(
              title: 'Mineralai',
              icon: Icons.water_drop_rounded,
              color: const Color(0xFF4361EE),
              items: [
                _DetailItem('Natris', data.sodium, _Goals.sodium * w, 'mg', hasCeiling: true),
                _DetailItem('Kalis', data.potassium, _Goals.potassium * w, 'mg'),
                _DetailItem('Kalcis', data.calcium, _Goals.calcium * w, 'mg'),
                _DetailItem('Magnis', data.magnesium, _Goals.magnesium * w, 'mg'),
                _DetailItem('Geležis', data.iron, _Goals.iron * w, 'mg'),
                _DetailItem('Cinkas', data.zinc, _Goals.zinc * w, 'mg'),
              ],
            ),
            const SizedBox(height: 14),
            _DetailGroup(
              title: 'Vitaminai',
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFF1DB954),
              items: [
                _DetailItem('Vitaminas A', data.vitaminA, _Goals.vitaminA * w, 'µg'),
                _DetailItem('Vitaminas C', data.vitaminC, _Goals.vitaminC * w, 'mg'),
                _DetailItem('Vitaminas D', data.vitaminD, _Goals.vitaminD * w, 'µg'),
                _DetailItem('Vitaminas E', data.vitaminE, _Goals.vitaminE * w, 'mg'),
                _DetailItem('Vitaminas K', data.vitaminK, _Goals.vitaminK * w, 'µg'),
                _DetailItem('Vitaminas B12', data.vitaminB12, _Goals.vitaminB12 * w, 'µg'),
                _DetailItem('Foliatas (B9)', data.folate, _Goals.folate * w, 'µg'),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// dienos kortele sarase
class _DaySummaryCard extends StatelessWidget {
  final DayData day;
  final VoidCallback onTap;
  const _DaySummaryCard({required this.day, required this.onTap});

  // dienos patikra
  bool get _isToday {
    final now = DateTime.now();
    return day.date.year == now.year &&
        day.date.month == now.month &&
        day.date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final calRatio = (day.calories / _Goals.calories).clamp(0.0, 1.0);
    final protRatio = (day.protein / _Goals.protein).clamp(0.0, 1.0);
    final carbRatio = (day.carbs / _Goals.carbs).clamp(0.0, 1.0);
    final fatRatio = (day.fat / _Goals.fat).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.date.day}',
                          style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text(_monthShort(day.date.month),
                          style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 9,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(day.date),
                          style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text(
                        day.calories > 0
                            ? '${day.calories.toStringAsFixed(0)} kcal  ·  ${day.protein.toStringAsFixed(0)}g B  ·  ${day.carbs.toStringAsFixed(0)}g A  ·  ${day.fat.toStringAsFixed(0)}g R'
                            : 'Nieko neužregistruota',
                        style: TextStyle(
                            color: day.calories > 0
                                ? AppTheme.textMuted
                                : AppTheme.textMuted.withOpacity(0.5),
                            fontSize: 12,
                            fontStyle: day.calories > 0
                                ? FontStyle.normal
                                : FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textMuted, size: 22),
              ],
            ),

            // treniruotes indikatorius
            if (_isToday) ...[
              const SizedBox(height: 8),
              FutureBuilder<bool>(
                future: WorkoutPlanGenerator.completedToday(),
                builder: (_, snap) {
                  final done = snap.data ?? false;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xFF1DB954).withOpacity(0.1)
                          : Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: done
                            ? const Color(0xFF1DB954).withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          done
                              ? Icons.fitness_center_rounded
                              : Icons.fitness_center_outlined,
                          color: done
                              ? const Color(0xFF1DB954)
                              : AppTheme.textMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          done
                              ? 'Treniruotė atlikta'
                              : 'Treniruotė neatlikta',
                          style: TextStyle(
                            color: done
                                ? const Color(0xFF1A6B35)
                                : AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                _MiniBar(ratio: calRatio, color: const Color(0xFFFF6B35), label: 'Kal.'),
                const SizedBox(width: 6),
                _MiniBar(ratio: protRatio, color: const Color(0xFF4361EE), label: 'Balt.'),
                const SizedBox(width: 6),
                _MiniBar(ratio: carbRatio, color: const Color(0xFFF4A261), label: 'Angl.'),
                const SizedBox(width: 6),
                _MiniBar(ratio: fatRatio, color: const Color(0xFFE63946), label: 'Rieb.'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // trumpas menuo
  String _monthShort(int m) {
    const months = ['', 'SAU', 'VAS', 'KOV', 'BAL', 'GEG', 'BIR',
      'LIE', 'RGP', 'RGS', 'SPA', 'LAP', 'GRD'];
    return months[m];
  }

  // datos formatavimas
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Šiandien';
    if (d == yesterday) return 'Vakar';
    const months = ['', 'Sausio', 'Vasario', 'Kovo', 'Balandžio',
      'Gegužės', 'Birželio', 'Liepos', 'Rugpjūčio', 'Rugsėjo',
      'Spalio', 'Lapkričio', 'Gruodžio'];
    return '${date.day} ${months[date.month]}';
  }
}

// mini progresas
class _MiniBar extends StatelessWidget {
  final double ratio;
  final Color color;
  final String label;
  const _MiniBar({required this.ratio, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final barColor = ratio >= 1.0 ? const Color(0xFF1DB954)
        : ratio >= 0.7 ? const Color(0xFF85C227)
        : ratio >= 0.4 ? const Color(0xFFF4A261)
        : AppTheme.danger;
    return Expanded(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio, minHeight: 6,
              backgroundColor: AppTheme.bg,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// detali dienos apzvalga
class DayDetailScreen extends StatelessWidget {
  final DayData day;
  const DayDetailScreen({super.key, required this.day});

  // pilna data
  String _fullDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Šiandien';
    const months = ['', 'Sausio', 'Vasario', 'Kovo', 'Balandžio',
      'Gegužės', 'Birželio', 'Liepos', 'Rugpjūčio', 'Rugsėjo',
      'Spalio', 'Lapkričio', 'Gruodžio'];
    return '${date.day} ${months[date.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          title: Text(_fullDate(day.date)), backgroundColor: AppTheme.bg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _CalorieHeroCard(calories: day.calories, goal: _Goals.calories),
            const SizedBox(height: 16),
            Row(children: [
              _MacroTile(label: 'Baltymai', value: day.protein,
                  goal: _Goals.protein, unit: 'g', color: const Color(0xFF4361EE)),
              const SizedBox(width: 10),
              _MacroTile(label: 'Angliavandeniai', value: day.carbs,
                  goal: _Goals.carbs, unit: 'g', color: const Color(0xFFF4A261)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _MacroTile(label: 'Riebalai', value: day.fat,
                  goal: _Goals.fat, unit: 'g', color: const Color(0xFFE63946)),
              const SizedBox(width: 10),
              _MacroTile(label: 'Skaidulos', value: day.fiber,
                  goal: _Goals.fiber, unit: 'g', color: const Color(0xFF1DB954)),
            ]),
            const SizedBox(height: 20),
            _DetailGroup(
              title: 'Papildomi makroelementai',
              icon: Icons.grain_rounded,
              color: const Color(0xFFFF6B35),
              items: [
                _DetailItem('Cukrus', day.sugars, _Goals.sugars, 'g', hasCeiling: true),
                _DetailItem('Sočiosios riebalų r.', day.saturatedFat, _Goals.saturatedFat, 'g', hasCeiling: true),
                _DetailItem('Cholesterolis', day.cholesterol, _Goals.cholesterol, 'mg', hasCeiling: true),
                _DetailItem('Omega-3', day.omega3, _Goals.omega3, 'g'),
                _DetailItem('Omega-6', day.omega6, _Goals.omega6, 'g'),
              ],
            ),
            const SizedBox(height: 14),
            _DetailGroup(
              title: 'Mineralai',
              icon: Icons.water_drop_rounded,
              color: const Color(0xFF4361EE),
              items: [
                _DetailItem('Natris', day.sodium, _Goals.sodium, 'mg', hasCeiling: true),
                _DetailItem('Kalis', day.potassium, _Goals.potassium, 'mg'),
                _DetailItem('Kalcis', day.calcium, _Goals.calcium, 'mg'),
                _DetailItem('Magnis', day.magnesium, _Goals.magnesium, 'mg'),
                _DetailItem('Geležis', day.iron, _Goals.iron, 'mg'),
                _DetailItem('Cinkas', day.zinc, _Goals.zinc, 'mg'),
              ],
            ),
            const SizedBox(height: 14),
            _DetailGroup(
              title: 'Vitaminai',
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFF1DB954),
              items: [
                _DetailItem('Vitaminas A', day.vitaminA, _Goals.vitaminA, 'µg'),
                _DetailItem('Vitaminas C', day.vitaminC, _Goals.vitaminC, 'mg'),
                _DetailItem('Vitaminas D', day.vitaminD, _Goals.vitaminD, 'µg'),
                _DetailItem('Vitaminas E', day.vitaminE, _Goals.vitaminE, 'mg'),
                _DetailItem('Vitaminas K', day.vitaminK, _Goals.vitaminK, 'µg'),
                _DetailItem('Vitaminas B12', day.vitaminB12, _Goals.vitaminB12, 'µg'),
                _DetailItem('Foliatas (B9)', day.folate, _Goals.folate, 'µg'),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// kaloriju kortele
class _CalorieHeroCard extends StatelessWidget {
  final double calories, goal;
  const _CalorieHeroCard({required this.calories, required this.goal});

  @override
  Widget build(BuildContext context) {
    final ratio = (calories / goal).clamp(0.0, 1.0);
    final color = ratio >= 1.0 ? const Color(0xFF1DB954)
        : ratio >= 0.7 ? const Color(0xFF85C227)
        : ratio >= 0.4 ? const Color(0xFFF4A261)
        : AppTheme.danger;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kalorijos',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: calories.toStringAsFixed(0),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto'),
                    ),
                    const TextSpan(
                      text: ' kcal',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Roboto'),
                    ),
                  ]),
                ),
                const SizedBox(height: 4),
                Text('Norma: ${goal.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 64, height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Text('${(ratio * 100).round()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// makroelementu plytele
class _MacroTile extends StatelessWidget {
  final String label;
  final double value, goal;
  final String unit;
  final Color color;
  const _MacroTile({
    required this.label, required this.value,
    required this.goal, required this.unit, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (value / goal).clamp(0.0, 1.0);
    final barColor = ratio >= 1.0 ? const Color(0xFF1DB954)
        : ratio >= 0.7 ? const Color(0xFF85C227)
        : ratio >= 0.4 ? const Color(0xFFF4A261)
        : AppTheme.danger;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3)),
            const SizedBox(height: 6),
            Text('${value.toStringAsFixed(value < 10 ? 1 : 0)} $unit',
                style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('/ ${goal.toStringAsFixed(goal < 10 ? 1 : 0)} $unit',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio, minHeight: 5,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// detaliu grupe
class _DetailGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_DetailItem> items;
  const _DetailGroup({
    required this.title, required this.icon,
    required this.color, required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 15),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            final item = e.value;

            // virsutines ribos patikra
            final hasCeiling = item.hasCeiling;
            final ratio = hasCeiling
                ? (item.value / item.goal).clamp(0.0, 1.0)
                : (item.value / item.goal).clamp(0.0, 2.0);
            final displayPercent = (item.value / item.goal * 100).round();

            Color barColor;
            if (hasCeiling) {
              // per daug (blogai)
              if (ratio >= 1.0) barColor = AppTheme.danger;
              else if (ratio >= 0.8) barColor = const Color(0xFFF4A261);
              else barColor = const Color(0xFF1DB954);
            } else {
              // per mazai (blogai)
              if (ratio >= 1.0) barColor = const Color(0xFF1DB954);
              else if (ratio >= 0.7) barColor = const Color(0xFF85C227);
              else if (ratio >= 0.4) barColor = const Color(0xFFF4A261);
              else barColor = AppTheme.danger;
            }

            final clampedRatio = ratio.clamp(0.0, 1.0);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.label,
                                style: const TextStyle(
                                    color: AppTheme.textDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Text(
                            '${item.value.toStringAsFixed(item.value < 1 ? 2 : item.value < 10 ? 1 : 0)} ${item.unit}',
                            style: TextStyle(
                                color: barColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: barColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('$displayPercent%',
                                style: TextStyle(
                                    color: barColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: clampedRatio,
                                minHeight: 5,
                                backgroundColor: AppTheme.bg,
                                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ ${item.goal.toStringAsFixed(item.goal < 10 ? 1 : 0)} ${item.unit}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, color: Colors.grey.withOpacity(0.07), indent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// detales elementas
class _DetailItem {
  final String label;
  final double value, goal;
  final String unit;
  final bool hasCeiling;

  const _DetailItem(this.label, this.value, this.goal, this.unit,
      {this.hasCeiling = false});
}

// tuscias ekranas
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(20)),
      child: const Center(
        child: Column(children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text('Dar nėra duomenų',
              style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('Pradėkite vesti mitybos dienoraštį',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ]),
      ),
    );
  }
}