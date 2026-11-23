import 'package:eduvoice/core/database/seed_data.dart';
import 'package:eduvoice/features/alerts/data/alert_repository.dart';
import 'package:eduvoice/features/alerts/domain/models/alert_level.dart';
import 'package:eduvoice/features/auth/data/auth_repository.dart';
import 'package:eduvoice/features/auth/domain/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_harness.dart';

Future<AppUser> seededUser(String schoolId) async {
  final user = await AuthRepository().signIn(
    identifier: schoolId,
    password: seedPassword,
  );
  expect(user, isNotNull, reason: 'Seeded account $schoolId must exist.');
  return user!;
}

void main() {
  setUp(() async {
    await setUpTestDatabase();
  });

  group('group-scoped alerts', () {
    test('a leader alert reaches only the leader group', () async {
      final leader = await seededUser('maria.santos');
      final ownMember = await seededUser('andrea.bautista');
      final otherGroupMember = await seededUser('miguel.castro');
      final repository = AlertRepository();

      final activity = await repository.broadcast(
        sender: leader,
        level: AlertLevel.red,
      );
      expect(activity.id, isNotNull);

      final ownHistory = await repository.historyFor(ownMember);
      expect(ownHistory.first.id, activity.id);
      expect((await repository.liveAlertFor(ownMember))?.id, activity.id);

      final otherHistory = await repository.historyFor(otherGroupMember);
      expect(
        otherHistory.where((entry) => entry.id == activity.id),
        isEmpty,
      );
      expect(await repository.liveAlertFor(otherGroupMember), isNull);
    });

    test('members cannot send alerts', () async {
      final member = await seededUser('andrea.bautista');

      await expectLater(
        AlertRepository().broadcast(
          sender: member,
          level: AlertLevel.green,
        ),
        throwsStateError,
      );
    });

    test('a member stop is private, a leader stop ends the alert', () async {
      final leader = await seededUser('maria.santos');
      final stoppedMember = await seededUser('andrea.bautista');
      final otherMember = await seededUser('carlo.mendoza');
      final repository = AlertRepository();

      final activity = await repository.broadcast(
        sender: leader,
        level: AlertLevel.yellow,
      );
      final alertId = activity.id!;

      expect((await repository.liveAlertFor(otherMember))?.id, alertId);

      await repository.stopAlert(user: stoppedMember, alertId: alertId);
      expect(await repository.liveAlertFor(stoppedMember), isNull);
      expect((await repository.liveAlertFor(otherMember))?.id, alertId);

      await repository.stopAlert(user: leader, alertId: alertId);
      expect(await repository.liveAlertFor(otherMember), isNull);
      expect(await repository.liveAlertFor(leader), isNull);
    });

    test('a member mute choice is remembered per account', () async {
      final member = await seededUser('andrea.bautista');
      final otherMember = await seededUser('carlo.mendoza');
      final repository = AlertRepository();

      expect(await repository.isSirenMuted(member), isFalse);
      await repository.setSirenMuted(member, true);

      expect(await repository.isSirenMuted(member), isTrue);
      expect(await repository.isSirenMuted(otherMember), isFalse);

      await repository.setSirenMuted(member, false);
      expect(await repository.isSirenMuted(member), isFalse);
    });

    testWidgets('a member receives the group alert and can stop it', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Widget tests run in a fake-async zone, so real database work has to
      // happen inside runAsync just like the shared test harness does.
      final leader = await tester.runAsync(
        () => seededUser('maria.santos'),
      );
      await tester.runAsync(
        () => AlertRepository().broadcast(
          sender: leader!,
          level: AlertLevel.red,
        ),
      );
      final member = await tester.runAsync(
        () => seededUser('andrea.bautista'),
      );
      final live = await tester.runAsync(
        () => AlertRepository().liveAlertFor(member!),
      );
      expect(live, isNotNull, reason: 'The broadcast must be live for Andrea.');

      await pumpShell(tester, member!);
      await settle(tester, 1200);

      expect(find.byKey(const Key('active-alert-title')), findsOneWidget);
      expect(find.byKey(const Key('mute-siren-button')), findsOneWidget);
      // Members never get a send button.
      expect(find.byKey(const Key('send-alert-button')), findsNothing);

      await tester.tap(find.byKey(const Key('stop-alert-button')));
      await settle(tester, 1200);

      expect(find.byKey(const Key('active-alert-title')), findsNothing);
      expect(find.byKey(const Key('send-alert-button')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
