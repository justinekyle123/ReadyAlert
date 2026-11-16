import 'package:flutter/material.dart';

import '../../auth/domain/models/app_user.dart';
import '../data/roster_repository.dart';
import '../domain/models/roster_models.dart';
import '../domain/models/volunteer_group.dart';

/// Applies roster changes and tells every screen when the rosters moved.
///
/// Screens read their data from SQLite, so after a write they compare
/// [revision] with the one they last loaded and reload when it changed.
class RosterController extends ChangeNotifier {
  RosterController({RosterRepository? repository})
    : _repository = repository ?? RosterRepository();

  final RosterRepository _repository;

  int _revision = 0;

  /// Incremented after every successful write.
  int get revision => _revision;

  Future<NewAccount> addUser({
    required AppUser actor,
    required String name,
    required UserRole role,
    int? groupId,
  }) async {
    final account = await _repository.createUser(
      actor: actor,
      name: name,
      role: role,
      groupId: groupId,
    );
    _changed();
    return account;
  }

  Future<VolunteerGroup> addGroup({
    required AppUser actor,
    required String name,
    int? leaderId,
  }) async {
    final group = await _repository.createGroup(
      actor: actor,
      name: name,
      leaderId: leaderId,
    );
    _changed();
    return group;
  }

  Future<void> assignLeader({
    required AppUser actor,
    required int groupId,
    required int userId,
  }) async {
    await _repository.assignLeader(
      actor: actor,
      groupId: groupId,
      userId: userId,
    );
    _changed();
  }

  Future<List<RosterContact>> leaderCandidates({
    required AppUser actor,
    int? preferGroupId,
  }) {
    return _repository.leaderCandidates(
      actor: actor,
      preferGroupId: preferGroupId,
    );
  }

  void _changed() {
    _revision++;
    notifyListeners();
  }
}

/// Exposes the active [RosterController] to the widget tree.
class RosterScope extends InheritedNotifier<RosterController> {
  const RosterScope({
    super.key,
    required RosterController controller,
    required super.child,
  }) : super(notifier: controller);

  static RosterController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RosterScope>();
    assert(scope?.notifier != null, 'No RosterScope above this widget.');
    return scope!.notifier!;
  }
}
