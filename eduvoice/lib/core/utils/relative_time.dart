const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Formats [time] as a short, human-readable relative timestamp.
String formatRelativeTime(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(time);

  if (difference.isNegative || difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} hr ago';
  }
  if (difference.inDays < 7) {
    return difference.inDays == 1
        ? 'Yesterday'
        : '${difference.inDays} days ago';
  }
  return '${time.month}/${time.day}/${time.year}';
}

/// Formats [time] as a list heading: `Today`, `Yesterday` or `27 October 2026`.
String formatDayHeading(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final day = DateTime(time.year, time.month, time.day);
  final difference = today.difference(day).inDays;

  if (difference == 0) {
    return 'Today';
  }
  if (difference == 1) {
    return 'Yesterday';
  }
  return '${day.day} ${_monthNames[day.month - 1]} ${day.year}';
}
