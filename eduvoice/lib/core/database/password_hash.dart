import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Hashes a password with its per-account salt before it is stored.
String hashPassword(String password, String salt) {
  return sha256.convert(utf8.encode('$salt::$password')).toString();
}
