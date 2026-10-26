// maisto irasas
class NutritionLog {
  // bazine info
  final String id;
  final DateTime date;

  // makro
  final double calories;
  final double protein;
  final double carbs;
  final double fiber;
  final double sugars;
  final double fat;
  final double saturatedFat;
  final double cholesterol;

  // omegos
  final double omega3;
  final double omega6;

  // mineralai
  final double sodium;
  final double potassium;
  final double calcium;
  final double magnesiumMg;
  final double ironMg;
  final double zinc;

  // vitaminai
  final double vitaminA;
  final double vitaminC;
  final double vitaminDMcg;
  final double vitaminE;
  final double vitaminK;
  final double vitaminB12;
  final double folate;

  const NutritionLog({
    required this.id,
    required this.date,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fiber = 0,
    this.sugars = 0,
    this.fat = 0,
    this.saturatedFat = 0,
    this.cholesterol = 0,
    this.omega3 = 0,
    this.omega6 = 0,
    this.sodium = 0,
    this.potassium = 0,
    this.calcium = 0,
    this.magnesiumMg = 0,
    this.ironMg = 0,
    this.zinc = 0,
    this.vitaminA = 0,
    this.vitaminC = 0,
    this.vitaminDMcg = 0,
    this.vitaminE = 0,
    this.vitaminK = 0,
    this.vitaminB12 = 0,
    this.folate = 0,
  });
}