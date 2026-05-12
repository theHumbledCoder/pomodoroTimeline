import 'package:hive/hive.dart';

part 'focus_session.g.dart';

@HiveType(typeId: 0)
class FocusSession extends HiveObject {
  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final DateTime endTime;

  @HiveField(2)
  final String sessionType; // e.g., 'focus', 'short_break', 'long_break'

  FocusSession({
    required this.startTime,
    required this.endTime,
    required this.sessionType,
  });
}
