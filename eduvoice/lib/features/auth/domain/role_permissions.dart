import 'models/app_user.dart';

/// What a signed-in role may do inside Ready Alert.
///
/// Hosts run the whole school program, youth volunteer leaders run their own
/// group, and members can only read alerts and their group's roster.
class RolePermissions {
  const RolePermissions(this.role);

  factory RolePermissions.of(AppUser? user) {
    return RolePermissions(user?.role ?? UserRole.member);
  }

  final UserRole role;

  /// Leaders send tri-alarm alerts to the group they lead; members only
  /// receive alerts and can stop or mute them.
  bool get canBroadcastAlerts => role != UserRole.member;

  /// Only a host reaches every volunteer group with one broadcast; a leader
  /// is always scoped to their own group.
  bool get canBroadcastToAllGroups => role == UserRole.host;

  bool get canAddUsers => role != UserRole.member;

  /// Only a host creates new volunteer groups.
  bool get canAddGroups => role == UserRole.host;

  /// Only a host decides which volunteer leads a group.
  bool get canAssignLeaders => role == UserRole.host;

  bool get canSeeAllGroups => role == UserRole.host;
}
