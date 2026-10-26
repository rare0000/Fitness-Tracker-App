// treniruociu tipai
enum WorkoutType { cardio, yoga, strength, rest }

// treniruote
class Workout {
  // duomenys
  final String name;
  final WorkoutType type;
  final String lottieAsset;
  final String description;
  final String reason;

  const Workout({
    required this.name,
    required this.type,
    required this.lottieAsset,
    required this.description,
    required this.reason,
  });
}