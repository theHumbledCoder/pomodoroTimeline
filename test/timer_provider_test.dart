import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro/providers/timer_provider.dart';

void main() {
  test('Initial state is correct', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerState = container.read(timerProvider);
    expect(timerState.state, TimerState.initial);
    expect(timerState.sessionType, SessionType.focus);
    expect(timerState.timeRemaining, 25 * 60);
    expect(timerState.totalDuration, 25 * 60);
  });

  test('Timer state changes on setSessionType', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    
    timerNotifier.setSessionType(SessionType.shortBreak);
    
    final timerState = container.read(timerProvider);
    expect(timerState.sessionType, SessionType.shortBreak);
    expect(timerState.timeRemaining, 5 * 60);
    expect(timerState.totalDuration, 5 * 60);
    expect(timerState.state, TimerState.initial);
  });

  test('Timer starts correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    
    timerNotifier.start();
    
    final timerState = container.read(timerProvider);
    expect(timerState.state, TimerState.running);
  });

  test('Timer pauses correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    
    timerNotifier.start();
    timerNotifier.pause();
    
    final timerState = container.read(timerProvider);
    expect(timerState.state, TimerState.paused);
  });

  test('Timer resets correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    
    timerNotifier.start();
    timerNotifier.reset();
    
    final timerState = container.read(timerProvider);
    expect(timerState.state, TimerState.initial);
    expect(timerState.timeRemaining, 25 * 60);
  });
}
