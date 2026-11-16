import 'package:eduvoice/core/database/seed_data.dart';
import 'package:eduvoice/features/auth/data/auth_repository.dart';
import 'package:eduvoice/features/auth/domain/models/app_user.dart';
import 'package:eduvoice/features/volunteers/data/group_repository.dart';
import 'package:eduvoice/features/volunteers/data/roster_repository.dart';
import 'package:eduvoice/features/volunteers/domain/models/roster_exception.dart';
import 'package:eduvoice/features/volunteers/domain/models/volunteer_group.dart';
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

Future<VolunteerGroup> groupNamed(AppUser viewer, String name) async {
  final groups = await GroupRepository().groupsFor(viewer);
  return groups.firstWhere((group) => group.name == name);
}

void main() {
  setUp(() async {
    await setUpTestDatabase();
  });

  group('roster repository', () {
    test('a new volunteer signs in with the default password', () async {
      final host = await seededUser('juan.delacruz');
      final roster = RosterRepository();
      final group = await groupNamed(host, 'Red Cross Youth A');

      final account = await roster.createUser(
        actor: host,
        name: 'Maria Clara Santos',
        groupId: group.id,
      );

      expect(account.schoolId, 'maria.clara.santos');
      expect(account.user.role, UserRole.member);
      expect(account.user.groupId, group.id);

      final signedIn = await AuthRepository().signIn(
        identifier: 'maria.clara.santos',
        password: 'ready123',
      );
      expect(signedIn, isNotNull);
      expect(signedIn!.name, 'Maria Clara Santos');
      expect(signedIn.role, UserRole.member);
      expect(signedIn.school, seedSchool);
      // A member belongs to exactly one group.
      expect(signedIn.groupId, group.id);
    });

    test('a new volunteer must be placed in a group', () async {
      final host = await seededUser('juan.delacruz');
      final roster = RosterRepository();

      await expectLater(
        roster.createUser(actor: host, name: 'Unplaced Volunteer'),
        throwsA(isA<RosterException>()),
      );
    });

    test('a taken school ID gets a suffix', () async {
      final host = await seededUser('juan.delacruz');
      final roster = RosterRepository();
      final group = await groupNamed(host, 'Red Cross Youth A');

      // Ana Cruz is a seeded leader, so her ID is already in the database.
      final account = await roster.createUser(
        actor: host,
        name: 'Ana Cruz',
        groupId: group.id,
      );

      expect(account.schoolId, 'ana.cruz2');
      expect(
        await AuthRepository().signIn(
          identifier: 'ana.cruz2',
          password: 'ready123',
        ),
        isNotNull,
      );
    });

    test('the host creates a group with a leader', () async {
      final host = await seededUser('juan.delacruz');
      final roster = RosterRepository();
      final candidates = await roster.leaderCandidates(actor: host);
      final hannah = candidates.firstWhere(
        (contact) => contact.name == 'Hannah Salazar',
      );

      final group = await roster.createGroup(
        actor: host,
        name: 'Robotics Club',
        leaderId: hannah.id,
      );

      expect(group.name, 'Robotics Club');
      expect(group.leader, 'Hannah Salazar');
      expect(group.leaderId, hannah.id);
      expect(group.status, GroupReportStatus.awaiting);
      expect(group.memberCount, 1);

      final saved = await groupNamed(host, 'Robotics Club');
      expect(saved.leader, 'Hannah Salazar');

      final promoted = await seededUser('hannah.salazar');
      expect(promoted.role, UserRole.leader);
      expect(promoted.groupId, group.id);
    });

    test('assigning a leader moves them and demotes the old one', () async {
      final host = await seededUser('juan.delacruz');
      final roster = RosterRepository();
      final troop = await groupNamed(host, 'Boy Scouts Troop 2');
      final hannah = (await roster.leaderCandidates(
        actor: host,
      )).firstWhere((contact) => contact.name == 'Hannah Salazar');

      expect(troop.leader, 'Mark Lim');

      await roster.assignLeader(
        actor: host,
        groupId: troop.id,
        userId: hannah.id,
      );

      final updated = await groupNamed(host, 'Boy Scouts Troop 2');
      expect(updated.leaderId, hannah.id);
      expect(updated.leader, 'Hannah Salazar');
      // Hannah joined the group, so it now has one more member.
      expect(updated.memberCount, troop.memberCount + 1);

      final promoted = await seededUser('hannah.salazar');
      expect(promoted.role, UserRole.leader);
      expect(promoted.groupId, troop.id);

      final demoted = await seededUser('mark.lim');
      expect(demoted.role, UserRole.member);
    });

    test('leaders add members to their own group only', () async {
      final leader = await seededUser('maria.santos');
      final roster = RosterRepository();

      final account = await roster.createUser(
        actor: leader,
        name: 'Test Volunteer',
        groupId: leader.groupId,
      );

      expect(account.user.role, UserRole.member);
      expect(account.user.groupId, leader.groupId);
      expect(account.user.groupId, isNotNull);
    });

    test('leaders cannot create groups or appoint leaders', () async {
      final leader = await seededUser('maria.santos');
      final roster = RosterRepository();

      await expectLater(
        roster.createGroup(actor: leader, name: 'Robotics Club'),
        throwsA(isA<RosterException>()),
      );
      await expectLater(
        roster.createUser(
          actor: leader,
          name: 'Too Senior',
          role: UserRole.leader,
          groupId: leader.groupId,
        ),
        throwsA(isA<RosterException>()),
      );
      await expectLater(
        roster.leaderCandidates(actor: leader),
        throwsA(isA<RosterException>()),
      );
    });

    test('members cannot add anyone', () async {
      final member = await seededUser('andrea.bautista');
      final roster = RosterRepository();

      await expectLater(
        roster.createUser(actor: member, name: 'Test Volunteer'),
        throwsA(isA<RosterException>()),
      );
    });

    test('a group that already has a leader is not taken over', () async {
      final host = await seededUser('juan.delacruz');
      final roster = RosterRepository();
      final group = await groupNamed(host, 'Red Cross Youth A');

      await expectLater(
        roster.createUser(
          actor: host,
          name: 'New Leader',
          role: UserRole.leader,
          groupId: group.id,
        ),
        throwsA(isA<RosterException>()),
      );
    });

    test('duplicate group names are rejected', () async {
      final host = await seededUser('juan.delacruz');
      final roster = RosterRepository();

      await expectLater(
        roster.createGroup(actor: host, name: 'red cross youth a'),
        throwsA(isA<RosterException>()),
      );
    });
  });

  group('roster screens', () {
    testWidgets('the host adds a volunteer from the add menu', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpHostShell(tester);

      await tester.tap(find.byKey(const Key('add-menu-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 420));

      await tester.tap(find.byKey(const Key('add-user-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 420));

      await tester.enterText(
        find.byKey(const Key('add-user-name')),
        'Maria Clara Santos',
      );
      await tester.pump();
      expect(find.textContaining('maria.clara.santos'), findsOneWidget);

      // Every member belongs to one group, so one must be picked.
      await tester.tap(find.byKey(const Key('add-user-group-1')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('add-user-submit')));
      await settle(tester, 1200);

      expect(find.textContaining('Maria Clara Santos added'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the host assigns a leader from the Groups tab', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpHostShell(tester);
      await tester.tap(find.byKey(const Key('nav-groups')));
      await settle(tester);

      final tile = find.byKey(const Key('group-leader-Boy Scouts Troop 2'));
      await tester.ensureVisible(tile);
      await tester.pump();
      await tester.tap(tile);
      await settle(tester, 800);

      expect(find.byKey(const Key('leader-search')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('leader-search')), 'Hannah');
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('leader-candidate-Hannah Salazar')),
      );
      await settle(tester, 1200);

      expect(
        find.textContaining('Hannah Salazar now leads Boy Scouts Troop 2.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
