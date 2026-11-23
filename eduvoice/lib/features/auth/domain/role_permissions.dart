import 'models/app_user.dart';

/// What a signed-in role may do inside Ready Alert.
///
/// Hosts run the whole school program: they create, assign and edit groups and
/// accounts, and broadcast to every group. Youth volunteer leaders only send
/// tri-alarm alerts to the group they lead. Members receive their group's
/// alerts and can mute or stop them on their own account.
class RolePermissions {
  const RolePermissions(this.role);

  factory RolePermissions.of(AppUser? user) {
    return RolePermissions(user?.role ?? UserRole.member);
  }

  final UserRole role;

  /// Hosts reach every group, leaders reach their own group, members receive
  /// alerts only.
  bool get canBroadcastAlerts => role != UserRole.member;

  /// Only a host reaches every volunteer group with one broadcast; a leader
  /// is always scoped to their own group.
  bool get canBroadcastToAllGroups => role == UserRole.host;

  /// Creating accounts is a host responsibility.
  bool get canAddUsers => role == UserRole.host;

  /// Only a host creates new volunteer groups.
  bool get canAddGroups => role == UserRole.host;

  /// Only a host decides which volunteer leads a group.
  bool get canAssignLeaders => role == UserRole.host;

  /// Only a host can rename a group or change its check-in status.
  bool get canEditGroups => role == UserRole.host;

  /// Only a host can rename an account or move it between roles and groups.
  bool get canEditUsers => role == UserRole.host;

  bool get canSeeAllGroups => role == UserRole.host;

  /// True for roles that manage any part of the roster.
  bool get canManageRoster => canAddUsers || canAddGroups;
}
