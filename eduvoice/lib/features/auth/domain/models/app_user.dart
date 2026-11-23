enum UserRole {
  host('Host'),
  leader('Youth Volunteer Leader'),
  member('Member');

  const UserRole(this.label);

  final String label;
}

/// A signed-in account, read from the local `users` table.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.school,
    this.schoolId,
    this.email,
    this.phone,
    this.groupId,
    this.about,
  });

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      name: map['name'] as String,
      role: UserRole.values.byName(map['role'] as String),
      school: map['school'] as String,
      schoolId: map['school_id'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      groupId: map['group_id'] as int?,
      about: map['about'] as String?,
    );
  }

  final int id;
  final String name;
  final UserRole role;
  final String school;

  /// The ID this account signs in with, synced so alerts can be traced back
  /// to the same person on another device.
  final String? schoolId;

  /// Sign-in email and contact number, editable by the account holder.
  final String? email;
  final String? phone;

  /// The volunteer group this account belongs to; hosts oversee every group.
  final int? groupId;

  final String? about;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.first;
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
