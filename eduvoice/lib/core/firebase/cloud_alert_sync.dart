import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../features/alerts/domain/models/alert_activity.dart';
import '../../features/alerts/domain/models/alert_level.dart';

/// An alert read back from Firestore.
class RemoteAlert {
  const RemoteAlert({
    required this.id,
    required this.level,
    required this.title,
    required this.detail,
    required this.occurredAt,
    this.endedAt,
    this.groupName,
  });

  final String id;
  final AlertLevel level;
  final String title;
  final String detail;
  final DateTime occurredAt;
  final DateTime? endedAt;

  /// The group this alert was sent to, or null for a school-wide broadcast.
  final String? groupName;
}

/// Mirrors tri-alarm broadcasts to Cloud Firestore.
///
/// The app is local-first: this class stays completely inert until
/// [FirebaseBootstrap] has configured Firebase, and every network failure is
/// logged instead of interrupting the alert flow. When Firebase is available,
/// a broadcast is published to the `alerts` collection and every signed-in
/// device listening to that collection imports the alert into its local
/// database.
class CloudAlertSync {
  CloudAlertSync._();

  static final CloudAlertSync instance = CloudAlertSync._();

  bool _enabled = false;

  /// Whether [FirebaseBootstrap] initialized a Firebase project.
  bool get enabled => _enabled;

  void enable() {
    _enabled = true;
  }

  /// Turns sync back off, so a device that lost Firebase stops claiming it is
  /// online. Tests also use it to reset the singleton between cases.
  void disable() {
    _enabled = false;
  }

  CollectionReference<Map<String, dynamic>> get _alerts =>
      FirebaseFirestore.instance.collection('alerts');

  /// Publishes [activity] under [remoteId].
  ///
  /// The caller generates a stable id so the sending device can recognise the
  /// document when its own snapshot stream returns it.
  Future<void> publish({
    required String remoteId,
    required AlertActivity activity,
    required String? groupName,
    required String senderName,
    String? senderSchoolId,
  }) async {
    if (!_enabled) {
      return;
    }
    await _alerts.doc(remoteId).set({
      'level': activity.level.name,
      'title': activity.title,
      'detail': activity.detail,
      'occurredAt': activity.occurredAt.toUtc().toIso8601String(),
      'endedAt': null,
      'groupName': groupName,
      'senderName': senderName,
      'senderSchoolId': senderSchoolId,
    });
  }

  /// Ends the broadcast for every device.
  Future<void> end(String remoteId) async {
    if (!_enabled) {
      return;
    }
    await _alerts.doc(remoteId).set({
      'endedAt': DateTime.now().toUtc().toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// The most recent alerts, live or finished, so a remote stop reaches every
  /// device. Finished alerts are only used to close the local copy.
  Stream<List<RemoteAlert>> watchRecent() {
    if (!_enabled) {
      return const Stream<List<RemoteAlert>>.empty();
    }
    return _alerts
        .orderBy('occurredAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(_fromDoc)
              .whereType<RemoteAlert>()
              .toList(growable: false);
        });
  }

  RemoteAlert? _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data();
      final level = AlertLevel.values.byName(data['level'] as String);
      final occurredAt = DateTime.parse(data['occurredAt'] as String);
      final endedAt = data['endedAt'] as String?;
      return RemoteAlert(
        id: doc.id,
        level: level,
        title: data['title'] as String? ?? 'Tri-alarm broadcast',
        detail: data['detail'] as String? ?? '',
        occurredAt: occurredAt,
        endedAt: endedAt == null ? null : DateTime.tryParse(endedAt),
        groupName: data['groupName'] as String?,
      );
    } on Object catch (error) {
      debugPrint('Skipping malformed remote alert ${doc.id}: $error');
      return null;
    }
  }
}
