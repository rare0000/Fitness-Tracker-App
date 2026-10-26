import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

// profilio ekranas
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // kintamieji
  final _importCtrl = TextEditingController();
  bool _showImport = false;
  String _importError = '';
  bool _importSuccess = false;

  @override
  void dispose() {
    _importCtrl.dispose();
    super.dispose();
  }

  // duomenu eksportas
  Future<String> _exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user_profile') ?? '';
    final logs = prefs.getStringList('nutrition_logs') ?? [];
    final exportMap = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'user_profile': user,
      'nutrition_logs': logs,
    };
    return base64Encode(utf8.encode(jsonEncode(exportMap)));
  }

  // duomenu importas
  Future<void> _importData(String code) async {
    setState(() {
      _importError = '';
      _importSuccess = false;
    });
    try {
      final decoded = utf8.decode(base64Decode(code.trim()));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      if (map['version'] != 1) throw Exception('Netinkama versija');
      final prefs = await SharedPreferences.getInstance();
      if (map['user_profile'] != null &&
          (map['user_profile'] as String).isNotEmpty) {
        await prefs.setString('user_profile', map['user_profile'] as String);
      }
      final logs = (map['nutrition_logs'] as List?)?.cast<String>() ?? [];
      await prefs.setStringList('nutrition_logs', logs);
      ref.invalidate(userProfileProvider);
      ref.invalidate(weekLogsProvider);
      ref.invalidate(workoutRecommendationProvider);
      setState(() {
        _importSuccess = true;
        _showImport = false;
        _importCtrl.clear();
      });
    } catch (e) {
      setState(
              () => _importError = 'Neteisingas kodas. Patikrink ir bandyk dar kartą.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Profilis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // vartotojo kortele
            userAsync.when(
              data: (user) => user.isInCalibrationPhase
                  ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded,
                        color: AppTheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Algoritmas kalibruojasi',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          Text(
                              'Liko ${user.daysRemainingInCalibration} d. iki personalizacijos',
                              style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Column(
                        children: [
                          Text(
                            '${((1 - user.daysRemainingInCalibration / 7) * 100).round()}%',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 1 -
                                  (user.daysRemainingInCalibration / 7),
                              minHeight: 4,
                              backgroundColor:
                              AppTheme.primary.withOpacity(0.15),
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // duomenu perkelimas
            const Text('Duomenų perkėlimas',
                style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3)),
            const SizedBox(height: 6),
            const Text(
              'Sugeneruok kodą ir išsaugok saugioje vietoje. Naujame telefone įklijuok kodą ir duomenys bus atkurti.',
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),

            _ActionCard(
              icon: Icons.upload_rounded,
              title: 'Eksportuoti duomenis',
              subtitle: 'Gauk atkūrimo kodą',
              color: AppTheme.primary,
              onTap: () async {
                final code = await _exportData();
                if (!context.mounted) return;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _ExportSheet(code: code),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.download_rounded,
              title: 'Importuoti duomenis',
              subtitle: 'Atkurk profilį iš kodo',
              color: const Color(0xFF00D4AA),
              onTap: () => setState(() {
                _showImport = !_showImport;
                _importError = '';
              }),
            ),

            // importo laukelis
            if (_showImport) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: TextField(
                  controller: _importCtrl,
                  maxLines: 4,
                  style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 13,
                      fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    hintText: 'Įklijuok atkūrimo kodą čia...',
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              if (_importError.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_importError,
                    style: TextStyle(color: AppTheme.danger, fontSize: 13)),
              ],
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _importData(_importCtrl.text),
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4AA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Atkurti duomenis',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],

            // patvirtinimo pranesimas
            if (_importSuccess) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1DB954)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954)),
                    SizedBox(width: 10),
                    Text('Duomenys sėkmingai atkurti!',
                        style: TextStyle(
                            color: Color(0xFF1A6B35),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// eksporto langas
class _ExportSheet extends StatelessWidget {
  final String code;
  const _ExportSheet({required this.code});

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
          const Icon(Icons.lock_rounded, color: AppTheme.primary, size: 36),
          const SizedBox(height: 12),
          const Text('Tavo atkūrimo kodas',
              style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Išsaugok šį kodą saugioje vietoje.\nJis leidžia atkurti visus tavo duomenis.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textMuted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Text(
              code.length > 60
                  ? '${code.substring(0, 30)}...${code.substring(code.length - 30)}'
                  : code,
              style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Kodas nukopijuotas!'),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Kopijuoti kodą',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Uždaryti',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// veiksmo kortele
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

// informacinis elementas
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}