/// Turns a display name into the school ID used to sign in.
///
/// "Maria Clara Santos" becomes "maria.clara.santos". A name with no Latin
/// letters falls back to [fallback] so every account always has an identifier.
String schoolIdFor(String name, {String fallback = 'volunteer'}) {
  final slug = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z ]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '.');
  return slug.isEmpty ? fallback : slug;
}
