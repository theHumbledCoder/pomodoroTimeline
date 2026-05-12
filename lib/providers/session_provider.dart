import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../models/focus_session.dart';

final sessionProvider = StateNotifierProvider<SessionNotifier, List<FocusSession>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return SessionNotifier(storageService);
});

class SessionNotifier extends StateNotifier<List<FocusSession>> {
  final StorageService _storageService;

  SessionNotifier(this._storageService) : super([]) {
    _loadSessions();
  }

  void _loadSessions() {
    state = _storageService.getSessions();
  }

  Future<void> addSession(FocusSession session) async {
    await _storageService.saveSession(session);
    _loadSessions();
  }
}
