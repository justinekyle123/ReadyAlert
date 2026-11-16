import '../../../auth/domain/models/app_user.dart';

/// An account offered in a roster picker, with the group it belongs to.
class RosterContact {
  const RosterContact({required this.user, this.groupName});

  final AppUser user;

  /// The group named in the `users` row, if any.
  final String? groupName;

  int get id => user.id;

  String get name => user.name;

  UserRole get role => user.role;
}

/// The account a roster write just created.
class NewAccount {
  const NewAccount({required this.user, required this.schoolId});

  final AppUser user;

  /// Generated school ID the new account signs in with.
  final String schoolId;
}
