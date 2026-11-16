import 'package:flutter/material.dart';

import '../domain/models/app_user.dart';
import '../domain/role_permissions.dart';

/// Holds the account that is signed in for the current app session.
class SessionController extends ChangeNotifier {
  SessionController({AppUser? initialUser}) : _user = initialUser;

  AppUser? _user;

  AppUser? get user => _user;

  bool get isSignedIn => _user != null;

  RolePermissions get permissions => RolePermissions.of(_user);

  void signIn(AppUser user) {
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}

/// Exposes the active [SessionController] to the widget tree.
class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController controller,
    required super.child,
  }) : super(notifier: controller);

  static SessionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope?.notifier != null, 'No SessionScope above this widget.');
    return scope!.notifier!;
  }

  static SessionController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SessionScope>()?.notifier;
  }
}
