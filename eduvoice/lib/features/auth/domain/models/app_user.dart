enum UserRole {
  host('Host'),
  leader('Youth Volunteer Leader'),
  member('Member');

  const UserRole(this.label);

  final String label;
}

class AppUser {
  const AppUser({required this.name, required this.role, required this.school});

  final String name;
  final UserRole role;
  final String school;

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
