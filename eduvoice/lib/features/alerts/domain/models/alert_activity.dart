import 'alert_level.dart';

class AlertActivity {
  const AlertActivity({
    required this.level,
    required this.title,
    required this.detail,
    required this.occurredAt,
    this.isUnread = false,
  });

  final AlertLevel level;
  final String title;
  final String detail;
  final DateTime occurredAt;

  /// New activity that has not been opened yet, shown with a dot in the feed.
  final bool isUnread;

  AlertActivity copyWith({bool? isUnread}) {
    return AlertActivity(
      level: level,
      title: title,
      detail: detail,
      occurredAt: occurredAt,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
