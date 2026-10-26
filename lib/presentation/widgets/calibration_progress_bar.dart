import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile.dart';

// kalibravimo juosta
class CalibrationProgressBar extends StatelessWidget {
  final UserProfile user;
  const CalibrationProgressBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // eigos kintamieji
    final progress = (user.loggedDaysCount / 7).clamp(0.0, 1.0);
    final isCalibrating = user.isInCalibrationPhase;

    // pagrindine kortele
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // antraste ir busena
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCalibrating ? 'Kalibravimo fazė' : 'Algoritmas aktyvus',
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCalibrating
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCalibrating
                      ? '${user.daysRemainingInCalibration}d. liko'
                      : 'Baigta',
                  style: TextStyle(
                    color: isCalibrating
                        ? const Color(0xFFE65100)
                        : const Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // eigos indikatorius
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.bg,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCalibrating ? AppTheme.primary : AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // informacinis tekstas
          Text(
            isCalibrating
                ? 'Renkame duomenis jūsų treniruočių personalizavimui'
                : 'Treniruotės pritaikytos pagal jūsų mitybą',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}