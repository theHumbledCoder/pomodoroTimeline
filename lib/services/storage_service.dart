import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/focus_session.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError();
});

class StorageService {
  static const String _sessionBoxName = 'sessions';
  late Box<FocusSession> _sessionBox;

  Future<void> init() async {
    _sessionBox = await Hive.openBox<FocusSession>(_sessionBoxName);
  }

  Future<void> saveSession(FocusSession session) async {
    await _sessionBox.add(session);
  }

  List<FocusSession> getSessions() {
    return _sessionBox.values.toList();
  }

  Future<void> clearSessions() async {
    await _sessionBox.clear();
  }
}
