import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../core/theme.dart';

class TimerView extends ConsumerWidget {
  const TimerView({super.key});

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal Pomodoro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings can be added here
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeButton(
                  'Focus',
                  timerState.sessionType == SessionType.focus,
                  () => timerNotifier.setSessionType(SessionType.focus),
                ),
                const SizedBox(width: 8),
                _buildTypeButton(
                  'Short Break',
                  timerState.sessionType == SessionType.shortBreak,
                  () => timerNotifier.setSessionType(SessionType.shortBreak),
                ),
                const SizedBox(width: 8),
                _buildTypeButton(
                  'Long Break',
                  timerState.sessionType == SessionType.longBreak,
                  () => timerNotifier.setSessionType(SessionType.longBreak),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: timerState.totalDuration > 0
                        ? timerState.timeRemaining / timerState.totalDuration
                        : 0,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                  ),
                ),
                Text(
                  _formatTime(timerState.timeRemaining),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (timerState.state == TimerState.initial ||
                    timerState.state == TimerState.paused)
                  FloatingActionButton(
                    onPressed: timerNotifier.start,
                    child: const Icon(Icons.play_arrow),
                  )
                else if (timerState.state == TimerState.running)
                  FloatingActionButton(
                    onPressed: timerNotifier.pause,
                    child: const Icon(Icons.pause),
                  ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: timerNotifier.reset,
                  backgroundColor: AppTheme.surface,
                  child: const Icon(Icons.stop),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent.withAlpha(51) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.transparent,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
