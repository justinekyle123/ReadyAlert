/// The three levels of the Ready Alert tri-alarm system.
enum AlertLevel {
  green(
    label: 'GREEN',
    title: 'All Clear',
    headline: 'No earthquake reported',
    guidance:
        'No earthquake has been reported. Continue normal activities and keep monitoring your group.',
  ),
  yellow(
    label: 'YELLOW',
    title: 'Caution',
    headline: 'Mild shaking reported',
    guidance:
        'Mild shaking was felt. Stay alert, prepare to evacuate, and wait for instructions from the Host.',
  ),
  red(
    label: 'RED',
    title: 'Emergency',
    headline: 'Strong shaking reported',
    guidance:
        'Duck, cover, and hold. Evacuate to the assembly area once the shaking stops and report your status.',
  );

  const AlertLevel({
    required this.label,
    required this.title,
    required this.headline,
    required this.guidance,
  });

  final String label;
  final String title;
  final String headline;
  final String guidance;
}
