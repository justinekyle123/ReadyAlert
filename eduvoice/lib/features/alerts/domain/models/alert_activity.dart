import 'alert_level.dart';

class AlertActivity {
  const AlertActivity({
    this.id,
    required this.level,
    required this.title,
    required this.detail,
    required this.occurredAt,
    this.isUnread = false,
  });

  factory AlertActivity.fromMap(Map<String, Object?> map) {
    return AlertActivity(
      id: map['id'] as int?,
      level: AlertLevel.values.byName(map['level'] as String),
      title: map['title'] as String,
      detail: map['detail'] as String,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      isUnread: (map['is_unread'] as int? ?? 0) == 1,
    );
  }

  /// Row id in the `alerts` table; null until the alert has been stored.
  final int? id;

  final AlertLevel level;
  final String title;
  final String detail;
  final DateTime occurredAt;

  /// New activity that has not been opened yet, shown with a dot in the feed.
  final bool isUnread;

  AlertActivity copyWith({int? id, bool? isUnread}) {
    return AlertActivity(
      id: id ?? this.id,
      level: level,
      title: title,
      detail: detail,
      occurredAt: occurredAt,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
