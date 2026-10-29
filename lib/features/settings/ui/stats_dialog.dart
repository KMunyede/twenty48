import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/daily_challenge_service.dart';
import '../../../core/services/stats_service.dart';
import '../../game/milestones/milestone_ladder.dart';
import '../../game/providers/game_provider.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';

class StatsDialog extends StatefulWidget {
  final StatsService? statsService;
  final DailyChallengeService? dailyService;

  const StatsDialog({
    super.key,
    this.statsService,
    this.dailyService,
  });

  @override
  State<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
  late final StatsService _statsService;
  late final DailyChallengeService _dailyService;
  bool _loading = true;
  int _currentStreak = 0;
  int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _statsService = widget.statsService ?? StatsService();
    _dailyService = widget.dailyService ?? DailyChallengeService();
    _loadData();
  }

  Future<void> _loadData() async {
    await _statsService.load();
    final streak = await _dailyService.currentStreak();
    final best = await _dailyService.bestStreak();
    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _bestStreak = best;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final gameProvider = context.watch<GameProvider>();

    final String titleText = titleForBestTile(_statsService.bestTile) ??
        'None yet - reach 256';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: theme.backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your stats',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    _buildStatRow(
                      'Title',
                      titleText,
                      theme,
                    ),
                    _buildStatRow(
                      'Games played',
                      '${_statsService.gamesPlayed}',
                      theme,
                    ),
                    _buildStatRow(
                      'Milestones reached',
                      '${_statsService.milestonesReached}',
                      theme,
                    ),
                    _buildStatRow(
                      'Highest tile',
                      '${_statsService.bestTile}',
                      theme,
                    ),
                    _buildStatRow(
                      'High score',
                      '${gameProvider.highScore}',
                      theme,
                    ),
                    _buildStatRow(
                      'Daily streak',
                      '$_currentStreak',
                      theme,
                    ),
                    _buildStatRow(
                      'Best daily streak',
                      '$_bestStreak',
                      theme,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(color: theme.textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textColor.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
