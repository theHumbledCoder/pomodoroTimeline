import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/focus_session.dart';
import 'session_provider.dart';

enum TimerState { initial, running, paused, finished }
enum SessionType { focus, shortBreak, longBreak }

final timerProvider = StateNotifierProvider<TimerNotifier, TimerModel>((ref) {
  return TimerNotifier(ref);
});

class TimerModel {
  final int timeRemaining;
  final TimerState state;
  final SessionType sessionType;
  final int totalDuration;

  TimerModel({
    required this.timeRemaining,
    required this.state,
    required this.sessionType,
    required this.totalDuration,
  });

  TimerModel copyWith({
    int? timeRemaining,
    TimerState? state,
    SessionType? sessionType,
    int? totalDuration,
  }) {
    return TimerModel(
      timeRemaining: timeRemaining ?? this.timeRemaining,
      state: state ?? this.state,
      sessionType: sessionType ?? this.sessionType,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerModel> with WidgetsBindingObserver {
  final Ref ref;
  Timer? _timer;
  DateTime? _sessionStartTime;
  DateTime? _pausedTime;
  
  static const int focusDuration = 25 * 60;
  static const int shortBreakDuration = 5 * 60;
  static const int longBreakDuration = 15 * 60;

  TimerNotifier(this.ref)
      : super(TimerModel(
          timeRemaining: focusDuration,
          state: TimerState.initial,
          sessionType: SessionType.focus,
          totalDuration: focusDuration,
        )) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (this.state.state == TimerState.running) {
        _pausedTime = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (this.state.state == TimerState.running && _pausedTime != null) {
        final elapsed = DateTime.now().difference(_pausedTime!).inSeconds;
        _pausedTime = null;
        int newRemaining = this.state.timeRemaining - elapsed;
        if (newRemaining <= 0) {
          this.state = this.state.copyWith(timeRemaining: 0);
          _onTimerComplete();
        } else {
          this.state = this.state.copyWith(timeRemaining: newRemaining);
        }
      }
    }
  }

  void start() {
    if (state.state == TimerState.running) return;

    if (state.state == TimerState.initial || _sessionStartTime == null) {
      _sessionStartTime = DateTime.now();
    }
    
    state = state.copyWith(state: TimerState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        _onTimerComplete();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(state: TimerState.paused);
  }

  void reset() {
    _timer?.cancel();
    _sessionStartTime = null;
    state = state.copyWith(
      state: TimerState.initial,
      timeRemaining: _getDurationForType(state.sessionType),
      totalDuration: _getDurationForType(state.sessionType),
    );
  }

  void setSessionType(SessionType type) {
    _timer?.cancel();
    _sessionStartTime = null;
    state = state.copyWith(
      sessionType: type,
      state: TimerState.initial,
      timeRemaining: _getDurationForType(type),
      totalDuration: _getDurationForType(type),
    );
  }

  int _getDurationForType(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return focusDuration;
      case SessionType.shortBreak:
        return shortBreakDuration;
      case SessionType.longBreak:
        return longBreakDuration;
    }
  }

  void _onTimerComplete() {
    _timer?.cancel();
    state = state.copyWith(state: TimerState.finished);
    
    // Play alert sound
    SystemSound.play(SystemSoundType.alert);
    
    if (_sessionStartTime != null) {
      final session = FocusSession(
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        sessionType: state.sessionType.name,
      );
      ref.read(sessionProvider.notifier).addSession(session);
    }
    
    // Optional: Auto transition to next phase
    if (state.sessionType == SessionType.focus) {
      setSessionType(SessionType.shortBreak);
    } else {
      setSessionType(SessionType.focus);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
