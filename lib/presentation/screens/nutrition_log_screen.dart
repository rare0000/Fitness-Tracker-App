import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/nutrition_log.dart';
import '../providers/app_providers.dart';

// produkto modelis
class FoodProduct {
  final String name;
  final String nameLt;
  final String category;
  final String servingHint;

  // makroelementai
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fiberPer100g;
  final double sugarsPer100g;
  final double fatPer100g;
  final double saturatedFatPer100g;
  final double cholesterolPer100g;
  final double omega3Per100g;
  final double omega6Per100g;

  // mineralai
  final double sodiumPer100g;
  final double potassiumPer100g;
  final double calciumPer100g;
  final double magnesiumPer100g;
  final double ironPer100g;
  final double zincPer100g;

  // vitaminai
  final double vitaminAPer100g;
  final double vitaminCPer100g;
  final double vitaminDPer100g;
  final double vitaminEPer100g;
  final double vitaminKPer100g;
  final double vitaminB12Per100g;
  final double folatePer100g;

  const FoodProduct({
    required this.name,
    required this.nameLt,
    required this.category,
    this.servingHint = '',
    required this.caloriesPer100g,
    this.proteinPer100g = 0,
    this.carbsPer100g = 0,
    this.fiberPer100g = 0,
    this.sugarsPer100g = 0,
    this.fatPer100g = 0,
    this.saturatedFatPer100g = 0,
    this.cholesterolPer100g = 0,
    this.omega3Per100g = 0,
    this.omega6Per100g = 0,
    this.sodiumPer100g = 0,
    this.potassiumPer100g = 0,
    this.calciumPer100g = 0,
    this.magnesiumPer100g = 0,
    this.ironPer100g = 0,
    this.zincPer100g = 0,
    this.vitaminAPer100g = 0,
    this.vitaminCPer100g = 0,
    this.vitaminDPer100g = 0,
    this.vitaminEPer100g = 0,
    this.vitaminKPer100g = 0,
    this.vitaminB12Per100g = 0,
    this.folatePer100g = 0,
  });
}

// produktu baze
const List<FoodProduct> kFoodDatabase = [
  FoodProduct(
    name: 'egg', nameLt: 'Kiaušinis', category: 'Baltymai',
    servingHint: '1 kiaušinis ≈ 50g',
    caloriesPer100g: 155, proteinPer100g: 13.0, carbsPer100g: 1.1,
    fiberPer100g: 0, sugarsPer100g: 1.1, fatPer100g: 11.0,
    saturatedFatPer100g: 3.3, cholesterolPer100g: 373,
    omega3Per100g: 0.1, omega6Per100g: 1.4,
    sodiumPer100g: 124, potassiumPer100g: 126, calciumPer100g: 50,
    magnesiumPer100g: 12, ironPer100g: 1.8, zincPer100g: 1.3,
    vitaminAPer100g: 160, vitaminCPer100g: 0, vitaminDPer100g: 2.0,
    vitaminEPer100g: 1.1, vitaminKPer100g: 0.3, vitaminB12Per100g: 1.1,
    folatePer100g: 47,
  ),
  FoodProduct(
    name: 'milk', nameLt: 'Pienas (3.2%)', category: 'Pieno produktai',
    servingHint: '1 stiklinė ≈ 250g',
    caloriesPer100g: 61, proteinPer100g: 3.2, carbsPer100g: 4.8,
    fiberPer100g: 0, sugarsPer100g: 4.8, fatPer100g: 3.3,
    saturatedFatPer100g: 2.1, cholesterolPer100g: 13,
    omega3Per100g: 0.1, omega6Per100g: 0.1,
    sodiumPer100g: 44, potassiumPer100g: 150, calciumPer100g: 113,
    magnesiumPer100g: 11, ironPer100g: 0.03, zincPer100g: 0.4,
    vitaminAPer100g: 46, vitaminCPer100g: 0.9, vitaminDPer100g: 0.2,
    vitaminEPer100g: 0.1, vitaminKPer100g: 0.3, vitaminB12Per100g: 0.45,
    folatePer100g: 5,
  ),
  FoodProduct(
    name: 'ground chicken', nameLt: 'Malta vištiena (10% riebalų)', category: 'Mėsa',
    servingHint: '1 porcija ≈ 100g',
    caloriesPer100g: 160, proteinPer100g: 18.0, carbsPer100g: 0,
    fatPer100g: 10.0, saturatedFatPer100g: 2.5, cholesterolPer100g: 80,
    omega3Per100g: 0.1, omega6Per100g: 1.8,
    sodiumPer100g: 75, potassiumPer100g: 220, calciumPer100g: 12,
    magnesiumPer100g: 20, ironPer100g: 1.0, zincPer100g: 1.8,
    vitaminAPer100g: 12, vitaminDPer100g: 0.1, vitaminEPer100g: 0.3,
    vitaminB12Per100g: 0.3, folatePer100g: 6,
  ),
  FoodProduct(
    name: 'pork sausage', nameLt: 'Kiaulienos dešrelės', category: 'Mėsa',
    servingHint: '1 dešrelė ≈ 60g',
    caloriesPer100g: 290, proteinPer100g: 12.0, carbsPer100g: 2.0,
    sugarsPer100g: 1.0, fatPer100g: 25.0, saturatedFatPer100g: 9.0,
    cholesterolPer100g: 70, omega3Per100g: 0.1, omega6Per100g: 2.5,
    sodiumPer100g: 800, potassiumPer100g: 180, calciumPer100g: 10,
    magnesiumPer100g: 14, ironPer100g: 1.2, zincPer100g: 1.5,
    vitaminDPer100g: 0.1, vitaminEPer100g: 0.2, vitaminB12Per100g: 0.5,
    folatePer100g: 3,
  ),
  FoodProduct(
    name: 'yogurt', nameLt: 'Jogurtas (natūralus)', category: 'Pieno produktai',
    servingHint: '1 puodelis ≈ 150g',
    caloriesPer100g: 61, proteinPer100g: 3.5, carbsPer100g: 4.7,
    sugarsPer100g: 4.7, fatPer100g: 3.3, saturatedFatPer100g: 2.1,
    cholesterolPer100g: 13, omega3Per100g: 0.1, omega6Per100g: 0.1,
    sodiumPer100g: 36, potassiumPer100g: 140, calciumPer100g: 110,
    magnesiumPer100g: 17, ironPer100g: 0.08, zincPer100g: 0.5,
    vitaminAPer100g: 27, vitaminCPer100g: 0.5, vitaminDPer100g: 0.1,
    vitaminEPer100g: 0.1, vitaminKPer100g: 0.2, vitaminB12Per100g: 0.4,
    folatePer100g: 7,
  ),
  FoodProduct(
    name: 'chicken breast', nameLt: 'Vištienos krūtinėlė', category: 'Mėsa',
    servingHint: '1 porcija ≈ 120g',
    caloriesPer100g: 165, proteinPer100g: 31.0, carbsPer100g: 0,
    fatPer100g: 3.6, saturatedFatPer100g: 1.0, cholesterolPer100g: 85,
    omega3Per100g: 0.1, omega6Per100g: 0.7,
    sodiumPer100g: 74, potassiumPer100g: 256, calciumPer100g: 15,
    magnesiumPer100g: 29, ironPer100g: 0.7, zincPer100g: 0.9,
    vitaminAPer100g: 9, vitaminDPer100g: 0.1, vitaminEPer100g: 0.3,
    vitaminB12Per100g: 0.3, folatePer100g: 4,
  ),
  FoodProduct(
    name: 'salmon atlantic', nameLt: 'Lašiša', category: 'Žuvis',
    servingHint: '1 porcija ≈ 150g',
    caloriesPer100g: 208, proteinPer100g: 20.0, carbsPer100g: 0,
    fatPer100g: 13.0, saturatedFatPer100g: 3.1, cholesterolPer100g: 63,
    omega3Per100g: 2.3, omega6Per100g: 0.9,
    sodiumPer100g: 59, potassiumPer100g: 360, calciumPer100g: 12,
    magnesiumPer100g: 29, ironPer100g: 0.8, zincPer100g: 0.6,
    vitaminAPer100g: 50, vitaminCPer100g: 3.9, vitaminDPer100g: 8.0,
    vitaminEPer100g: 3.6, vitaminKPer100g: 0.1, vitaminB12Per100g: 3.2,
    folatePer100g: 25,
  ),
  FoodProduct(
    name: 'spinach', nameLt: 'Špinatai', category: 'Daržovės',
    servingHint: '1 sauja ≈ 30g',
    caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6,
    fiberPer100g: 2.2, sugarsPer100g: 0.4, fatPer100g: 0.4,
    saturatedFatPer100g: 0.1, cholesterolPer100g: 0,
    omega3Per100g: 0.1, omega6Per100g: 0.03,
    sodiumPer100g: 79, potassiumPer100g: 558, calciumPer100g: 99,
    magnesiumPer100g: 79, ironPer100g: 2.7, zincPer100g: 0.5,
    vitaminAPer100g: 469, vitaminCPer100g: 28.0, vitaminDPer100g: 0,
    vitaminEPer100g: 2.0, vitaminKPer100g: 483, vitaminB12Per100g: 0,
    folatePer100g: 194,
  ),
  FoodProduct(
    name: 'banana', nameLt: 'Bananas', category: 'Vaisiai',
    servingHint: '1 bananas ≈ 120g',
    caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23.0,
    fiberPer100g: 2.6, sugarsPer100g: 12.2, fatPer100g: 0.3,
    saturatedFatPer100g: 0.1, cholesterolPer100g: 0,
    omega3Per100g: 0.03, omega6Per100g: 0.05,
    sodiumPer100g: 1, potassiumPer100g: 358, calciumPer100g: 5,
    magnesiumPer100g: 27, ironPer100g: 0.3, zincPer100g: 0.2,
    vitaminAPer100g: 3, vitaminCPer100g: 8.7, vitaminKPer100g: 0.5,
    vitaminB12Per100g: 0, folatePer100g: 20,
  ),
  FoodProduct(
    name: 'oats', nameLt: 'Avižiniai dribsniai', category: 'Grūdai',
    servingHint: '1 porcija ≈ 40g',
    caloriesPer100g: 389, proteinPer100g: 16.9, carbsPer100g: 66.3,
    fiberPer100g: 10.6, sugarsPer100g: 0.8, fatPer100g: 6.9,
    saturatedFatPer100g: 1.2, cholesterolPer100g: 0,
    omega3Per100g: 0.1, omega6Per100g: 2.4,
    sodiumPer100g: 2, potassiumPer100g: 429, calciumPer100g: 54,
    magnesiumPer100g: 138, ironPer100g: 4.7, zincPer100g: 4.0,
    vitaminEPer100g: 0.4, vitaminKPer100g: 2, folatePer100g: 56,
  ),
  FoodProduct(
    name: 'beef cooked', nameLt: 'Jautiena', category: 'Mėsa',
    servingHint: '1 porcija ≈ 100g',
    caloriesPer100g: 250, proteinPer100g: 26.0, carbsPer100g: 0,
    fatPer100g: 15.0, saturatedFatPer100g: 6.0, cholesterolPer100g: 90,
    omega3Per100g: 0.1, omega6Per100g: 0.5,
    sodiumPer100g: 72, potassiumPer100g: 318, calciumPer100g: 18,
    magnesiumPer100g: 21, ironPer100g: 2.6, zincPer100g: 4.5,
    vitaminDPer100g: 0.1, vitaminEPer100g: 0.2, vitaminKPer100g: 1.6,
    vitaminB12Per100g: 2.5, folatePer100g: 6,
  ),
  FoodProduct(
    name: 'rice white cooked', nameLt: 'Ryžiai', category: 'Grūdai',
    servingHint: '1 porcija ≈ 150g',
    caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28.2,
    fiberPer100g: 0.4, fatPer100g: 0.3, saturatedFatPer100g: 0.1,
    cholesterolPer100g: 0, omega3Per100g: 0.01, omega6Per100g: 0.08,
    sodiumPer100g: 1, potassiumPer100g: 35, calciumPer100g: 10,
    magnesiumPer100g: 12, ironPer100g: 0.2, zincPer100g: 0.5,
    folatePer100g: 3,
  ),
  FoodProduct(
    name: 'rye bread', nameLt: 'Ruginė duona', category: 'Grūdai',
    servingHint: '1 riekė ≈ 30g',
    caloriesPer100g: 259, proteinPer100g: 8.5, carbsPer100g: 48.0,
    fiberPer100g: 6.0, sugarsPer100g: 3.2, fatPer100g: 3.3,
    saturatedFatPer100g: 0.5, cholesterolPer100g: 0,
    omega3Per100g: 0.1, omega6Per100g: 0.7,
    sodiumPer100g: 600, potassiumPer100g: 246, calciumPer100g: 73,
    magnesiumPer100g: 40, ironPer100g: 2.5, zincPer100g: 1.6,
    vitaminEPer100g: 0.3, vitaminKPer100g: 1.9, folatePer100g: 64,
  ),
  FoodProduct(
    name: 'cottage cheese', nameLt: 'Varškė', category: 'Pieno produktai',
    servingHint: '1 porcija ≈ 100g',
    caloriesPer100g: 98, proteinPer100g: 11.0, carbsPer100g: 3.4,
    sugarsPer100g: 2.7, fatPer100g: 4.3, saturatedFatPer100g: 1.7,
    cholesterolPer100g: 17, omega3Per100g: 0.04, omega6Per100g: 0.1,
    sodiumPer100g: 364, potassiumPer100g: 104, calciumPer100g: 83,
    magnesiumPer100g: 8, ironPer100g: 0.2, zincPer100g: 0.4,
    vitaminAPer100g: 37, vitaminDPer100g: 0.1, vitaminEPer100g: 0.1,
    vitaminB12Per100g: 0.4, folatePer100g: 12,
  ),
  FoodProduct(
    name: 'apple', nameLt: 'Obuolys', category: 'Vaisiai',
    servingHint: '1 obuolys ≈ 180g',
    caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 13.8,
    fiberPer100g: 2.4, sugarsPer100g: 10.4, fatPer100g: 0.2,
    cholesterolPer100g: 0, omega3Per100g: 0.01, omega6Per100g: 0.05,
    sodiumPer100g: 1, potassiumPer100g: 107, calciumPer100g: 6,
    magnesiumPer100g: 5, ironPer100g: 0.1, zincPer100g: 0.04,
    vitaminAPer100g: 3, vitaminCPer100g: 4.6, vitaminEPer100g: 0.2,
    vitaminKPer100g: 2.2, folatePer100g: 3,
  ),
  FoodProduct(
    name: 'potato boiled', nameLt: 'Bulvė', category: 'Daržovės',
    servingHint: '1 vidutinė bulvė ≈ 150g',
    caloriesPer100g: 87, proteinPer100g: 1.9, carbsPer100g: 20.0,
    fiberPer100g: 1.8, sugarsPer100g: 0.9, fatPer100g: 0.1,
    cholesterolPer100g: 0, omega3Per100g: 0.01, omega6Per100g: 0.03,
    sodiumPer100g: 5, potassiumPer100g: 420, calciumPer100g: 5,
    magnesiumPer100g: 22, ironPer100g: 0.3, zincPer100g: 0.3,
    vitaminCPer100g: 13.0, vitaminEPer100g: 0.1, vitaminKPer100g: 1.9,
    folatePer100g: 10,
  ),
  FoodProduct(
    name: 'tuna canned', nameLt: 'Tunas', category: 'Žuvis',
    servingHint: '½ skardinės ≈ 85g',
    caloriesPer100g: 116, proteinPer100g: 25.0, carbsPer100g: 0,
    fatPer100g: 1.0, saturatedFatPer100g: 0.3, cholesterolPer100g: 49,
    omega3Per100g: 0.3, omega6Per100g: 0.04,
    sodiumPer100g: 300, potassiumPer100g: 237, calciumPer100g: 10,
    magnesiumPer100g: 31, ironPer100g: 1.3, zincPer100g: 0.9,
    vitaminAPer100g: 15, vitaminDPer100g: 4.0, vitaminEPer100g: 0.5,
    vitaminB12Per100g: 2.5, folatePer100g: 3,
  ),
  FoodProduct(
    name: 'lentils cooked', nameLt: 'Lęšiai', category: 'Ankštiniai',
    servingHint: '1 porcija ≈ 200g',
    caloriesPer100g: 116, proteinPer100g: 9.0, carbsPer100g: 20.0,
    fiberPer100g: 7.9, sugarsPer100g: 1.8, fatPer100g: 0.4,
    saturatedFatPer100g: 0.1, cholesterolPer100g: 0,
    omega3Per100g: 0.04, omega6Per100g: 0.2,
    sodiumPer100g: 2, potassiumPer100g: 369, calciumPer100g: 19,
    magnesiumPer100g: 36, ironPer100g: 3.3, zincPer100g: 1.3,
    vitaminAPer100g: 1, vitaminCPer100g: 1.5, vitaminEPer100g: 0.1,
    vitaminKPer100g: 1.7, folatePer100g: 180,
  ),
  FoodProduct(
    name: 'almonds', nameLt: 'Migdolai', category: 'Riešutai',
    servingHint: 'Sauja ≈ 30g',
    caloriesPer100g: 579, proteinPer100g: 21.0, carbsPer100g: 21.6,
    fiberPer100g: 12.5, sugarsPer100g: 4.4, fatPer100g: 50.0,
    saturatedFatPer100g: 3.8, cholesterolPer100g: 0,
    omega3Per100g: 0.003, omega6Per100g: 12.3,
    sodiumPer100g: 1, potassiumPer100g: 733, calciumPer100g: 264,
    magnesiumPer100g: 270, ironPer100g: 3.7, zincPer100g: 3.1,
    vitaminEPer100g: 25.0, folatePer100g: 44,
  ),
  FoodProduct(
    name: 'dark chocolate', nameLt: 'Juodasis šokoladas (70–85%)', category: 'Kita',
    servingHint: '2 plytelės ≈ 20g',
    caloriesPer100g: 546, proteinPer100g: 4.9, carbsPer100g: 59.0,
    fiberPer100g: 7.0, sugarsPer100g: 45.0, fatPer100g: 31.0,
    saturatedFatPer100g: 18.5, cholesterolPer100g: 3,
    omega3Per100g: 0.03, omega6Per100g: 1.1,
    sodiumPer100g: 20, potassiumPer100g: 559, calciumPer100g: 56,
    magnesiumPer100g: 228, ironPer100g: 11.0, zincPer100g: 3.3,
    vitaminAPer100g: 2, vitaminEPer100g: 0.6, vitaminKPer100g: 7.3,
    folatePer100g: 3,
  ),
];

// mitybos langas
class NutritionLogScreen extends ConsumerStatefulWidget {
  const NutritionLogScreen({super.key});

  @override
  ConsumerState<NutritionLogScreen> createState() => _NutritionLogScreenState();
}

class _NutritionLogScreenState extends ConsumerState<NutritionLogScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _gramsCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  List<FoodProduct> _searchResults = [];
  FoodProduct? _selectedFood;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _gramsCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // skaiciavimo formule
  double _calc(double per100g, double grams) => per100g * grams / 100;

  // paieskos funkcija
  void _searchFood(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) { setState(() => _searchResults = []); return; }
    setState(() {
      _selectedFood = null;
      _saved = false;
      _searchResults = kFoodDatabase.where((f) =>
      f.nameLt.toLowerCase().contains(q) || f.name.toLowerCase().contains(q)).toList();
    });
  }

  // produkto pasirinkimas
  void _selectFood(FoodProduct food) {
    setState(() { _selectedFood = food; _searchResults = []; _searchCtrl.text = food.nameLt; });
    _animCtrl.forward(from: 0);
  }

  // iraso isaugojimas
  Future<void> _save() async {
    final grams = double.tryParse(_gramsCtrl.text) ?? 0;
    if (grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Įvesk gramų kiekį!'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    final log = NutritionLog(
      id: const Uuid().v4(),
      date: DateTime.now(),
      calories: _calc(_selectedFood!.caloriesPer100g, grams),
      protein: _calc(_selectedFood!.proteinPer100g, grams),
      carbs: _calc(_selectedFood!.carbsPer100g, grams),
      fiber: _calc(_selectedFood!.fiberPer100g, grams),
      sugars: _calc(_selectedFood!.sugarsPer100g, grams),
      fat: _calc(_selectedFood!.fatPer100g, grams),
      saturatedFat: _calc(_selectedFood!.saturatedFatPer100g, grams),
      cholesterol: _calc(_selectedFood!.cholesterolPer100g, grams),
      omega3: _calc(_selectedFood!.omega3Per100g, grams),
      omega6: _calc(_selectedFood!.omega6Per100g, grams),
      sodium: _calc(_selectedFood!.sodiumPer100g, grams),
      potassium: _calc(_selectedFood!.potassiumPer100g, grams),
      calcium: _calc(_selectedFood!.calciumPer100g, grams),
      magnesiumMg: _calc(_selectedFood!.magnesiumPer100g, grams),
      ironMg: _calc(_selectedFood!.ironPer100g, grams),
      zinc: _calc(_selectedFood!.zincPer100g, grams),
      vitaminA: _calc(_selectedFood!.vitaminAPer100g, grams),
      vitaminC: _calc(_selectedFood!.vitaminCPer100g, grams),
      vitaminDMcg: _calc(_selectedFood!.vitaminDPer100g, grams),
      vitaminE: _calc(_selectedFood!.vitaminEPer100g, grams),
      vitaminK: _calc(_selectedFood!.vitaminKPer100g, grams),
      vitaminB12: _calc(_selectedFood!.vitaminB12Per100g, grams),
      folate: _calc(_selectedFood!.folatePer100g, grams),
    );
    await ref.read(nutritionRepositoryProvider).saveNutritionLog(log);
    ref.invalidate(weekLogsProvider);
    ref.invalidate(workoutRecommendationProvider);
    setState(() { _saved = true; _selectedFood = null; _searchCtrl.clear(); _gramsCtrl.clear(); _searchResults = []; });
  }

  @override
  Widget build(BuildContext context) {
    final grams = double.tryParse(_gramsCtrl.text) ?? 0;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Mitybos dienoraštis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_saved) ...[
              _SuccessBanner(onDismiss: () => setState(() => _saved = false)),
              const SizedBox(height: 16),
            ],
            _SearchField(ctrl: _searchCtrl, onChanged: _searchFood, onClear: () {
              _searchCtrl.clear();
              setState(() { _searchResults = []; _selectedFood = null; });
            }),
            const SizedBox(height: 12),
            if (_searchResults.isNotEmpty && _selectedFood == null)
              _SearchResultsList(results: _searchResults, onSelect: _selectFood),
            if (_selectedFood != null)
              FadeTransition(
                opacity: _fadeAnim,
                child: _SelectedFoodPanel(
                  food: _selectedFood!,
                  grams: grams,
                  gramsCtrl: _gramsCtrl,
                  calc: _calc,
                  onClear: () => setState(() { _selectedFood = null; _searchCtrl.clear(); _gramsCtrl.clear(); }),
                  onSave: _save,
                  onGramsChanged: () => setState(() {}),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// paieskos laukelis
class _SearchField extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchField({required this.ctrl, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Ieškoti produkto...',
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
          suffixIcon: ctrl.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted), onPressed: onClear)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// rezultatu sarasas
class _SearchResultsList extends StatelessWidget {
  final List<FoodProduct> results;
  final ValueChanged<FoodProduct> onSelect;
  const _SearchResultsList({required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: results.asMap().entries.map((entry) {
            final i = entry.key;
            final food = entry.value;
            return Column(
              children: [
                InkWell(
                  onTap: () => onSelect(food),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.restaurant_rounded, color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(food.nameLt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.bg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(food.category,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: AppTheme.textMuted, fontSize: 11)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${food.caloriesPer100g.toStringAsFixed(0)} kcal',
                                    style: const TextStyle(
                                        color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.add_circle_rounded, color: AppTheme.primary, size: 24),
                      ],
                    ),
                  ),
                ),
                if (i < results.length - 1)
                  Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 72),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// pasirinkto produkto langas
class _SelectedFoodPanel extends StatelessWidget {
  final FoodProduct food;
  final double grams;
  final TextEditingController gramsCtrl;
  final double Function(double, double) calc;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final VoidCallback onGramsChanged;

  const _SelectedFoodPanel({
    required this.food,
    required this.grams,
    required this.gramsCtrl,
    required this.calc,
    required this.onClear,
    required this.onSave,
    required this.onGramsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.restaurant_rounded,
                          color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.nameLt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(food.category,
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 13)),
                          if (food.servingHint.isNotEmpty)
                            Text(food.servingHint,
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onClear,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Maistinė vertė · 100g',
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Row(children: [
                  _MacroChip(
                      label: 'Kalorijos',
                      value: food.caloriesPer100g.toStringAsFixed(0),
                      unit: 'kcal',
                      color: const Color(0xFFFF6B35)),
                  const SizedBox(width: 8),
                  _MacroChip(
                      label: 'Baltymai',
                      value: food.proteinPer100g.toStringAsFixed(1),
                      unit: 'g',
                      color: const Color(0xFF4361EE)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  _MacroChip(
                      label: 'Angliavandeniai',
                      value: food.carbsPer100g.toStringAsFixed(1),
                      unit: 'g',
                      color: const Color(0xFFF4A261)),
                  const SizedBox(width: 8),
                  _MacroChip(
                      label: 'Riebalai',
                      value: food.fatPer100g.toStringAsFixed(1),
                      unit: 'g',
                      color: const Color(0xFFE63946)),
                ]),
                const SizedBox(height: 12),
                _ExpandableNutrients(food: food),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // gramu laukelis
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))],
          ),
          child: TextField(
            controller: gramsCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Kiekis (g arba ml)',
              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 16),
              prefixIcon: Icon(Icons.scale_outlined, color: AppTheme.textMuted),
              suffixText: 'g / ml',
              suffixStyle: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (_) => onGramsChanged(),
          ),
        ),

        // apskaiciuota verte
        if (grams > 0) ...[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4B44CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Iš viso — ${grams.toStringAsFixed(0)}g / ml',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    _ResultItem(
                        label: 'Kalorijos',
                        value: calc(food.caloriesPer100g, grams)
                            .toStringAsFixed(0),
                        unit: 'kcal'),
                    const _VerticalDivider(),
                    _ResultItem(
                        label: 'Baltymai',
                        value: calc(food.proteinPer100g, grams)
                            .toStringAsFixed(1),
                        unit: 'g'),
                    const _VerticalDivider(),
                    _ResultItem(
                        label: 'Angliavandeniai',
                        value: calc(food.carbsPer100g, grams)
                            .toStringAsFixed(1),
                        unit: 'g'),
                    const _VerticalDivider(),
                    _ResultItem(
                        label: 'Riebalai',
                        value: calc(food.fatPer100g, grams).toStringAsFixed(1),
                        unit: 'g'),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onSave,
            child: Container(
              width: double.infinity, height: 56,
              decoration: BoxDecoration(
                  color: AppTheme.textDark,
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text('Išsaugoti į dienoraštį',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ],
    );
  }
}

// detali informacija
class _ExpandableNutrients extends StatefulWidget {
  final FoodProduct food;
  const _ExpandableNutrients({required this.food});

  @override
  State<_ExpandableNutrients> createState() => _ExpandableNutrientsState();
}

class _ExpandableNutrientsState extends State<_ExpandableNutrients> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.food;
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.bg, borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_expanded ? 'Slėpti detalius duomenis' : 'Rodyti visus mikroelementus',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primary, size: 18),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 12),
          _NutrientSection(title: 'Makroelementai', rows: [
            _NutrientRowData('Skaidulos', f.fiberPer100g, 'g'),
            _NutrientRowData('Cukrus', f.sugarsPer100g, 'g'),
            _NutrientRowData('Sočiosios riebalų r.', f.saturatedFatPer100g, 'g'),
            _NutrientRowData('Cholesterolis', f.cholesterolPer100g, 'mg'),
            _NutrientRowData('Omega-3', f.omega3Per100g, 'g'),
            _NutrientRowData('Omega-6', f.omega6Per100g, 'g'),
          ]),
          const SizedBox(height: 12),
          _NutrientSection(title: 'Mineralai', rows: [
            _NutrientRowData('Natris', f.sodiumPer100g, 'mg'),
            _NutrientRowData('Kalis', f.potassiumPer100g, 'mg'),
            _NutrientRowData('Kalcis', f.calciumPer100g, 'mg'),
            _NutrientRowData('Magnis', f.magnesiumPer100g, 'mg'),
            _NutrientRowData('Geležis', f.ironPer100g, 'mg'),
            _NutrientRowData('Cinkas', f.zincPer100g, 'mg'),
          ]),
          const SizedBox(height: 12),
          _NutrientSection(title: 'Vitaminai', rows: [
            _NutrientRowData('Vitaminas A', f.vitaminAPer100g, 'mcg'),
            _NutrientRowData('Vitaminas C', f.vitaminCPer100g, 'mg'),
            _NutrientRowData('Vitaminas D', f.vitaminDPer100g, 'mcg'),
            _NutrientRowData('Vitaminas E', f.vitaminEPer100g, 'mg'),
            _NutrientRowData('Vitaminas K', f.vitaminKPer100g, 'mcg'),
            _NutrientRowData('Vitaminas B12', f.vitaminB12Per100g, 'mcg'),
            _NutrientRowData('Foliatas (B9)', f.folatePer100g, 'mcg'),
          ]),
        ],
      ],
    );
  }
}

// lenteles eilute
class _NutrientRowData {
  final String label;
  final double value;
  final String unit;
  const _NutrientRowData(this.label, this.value, this.unit);
}

// elementu sekcija
class _NutrientSection extends StatelessWidget {
  final String title;
  final List<_NutrientRowData> rows;
  const _NutrientSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg, borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            final row = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(row.label, style: const TextStyle(color: AppTheme.textDark, fontSize: 13)),
                      Text('${row.value.toStringAsFixed(row.value < 1 ? 2 : 1)} ${row.unit}',
                          style: const TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 14),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// patvirtinimo pranesimas
class _SuccessBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _SuccessBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1DB954), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 20),
          const SizedBox(width: 10),
          const Expanded(child: Text('Išsaugota sėkmingai!',
              style: TextStyle(color: Color(0xFF1A6B35), fontWeight: FontWeight.w600))),
          GestureDetector(onTap: onDismiss,
              child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF1A6B35))),
        ],
      ),
    );
  }
}

// makroelementu kortele
class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _MacroChip({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            RichText(text: TextSpan(children: [
              TextSpan(text: value, style: const TextStyle(color: AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Roboto')),
              TextSpan(text: ' $unit', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontFamily: 'Roboto')),
            ])),
          ],
        ),
      ),
    );
  }
}

// rezultato elementas
class _ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _ResultItem({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// vizualus atskyrimas
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2));
  }
}