import 'package:intl/intl.dart';

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

bool isFrench(String locale) => locale.startsWith('fr');

/// « 12 000 FCFA » (fr, espace insécable) ou « 12,000 FCFA » (en).
String formatFcfa(int amount, String locale) {
  final sep = isFrench(locale) ? ' ' : ',';
  final digits = amount.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(sep);
    out.write(digits[i]);
  }
  return '$out FCFA';
}

/// « Mar. 24 nov. » (fr) / « Tue, Nov 24 » (en) : créneau dans l'annuaire.
String formatSlotDay(DateTime d, String locale) => capitalize(
  DateFormat(isFrench(locale) ? 'EEE d MMM' : 'EEE, MMM d', locale).format(d),
);

/// « Mar 24 nov. » (fr) / « Tue 24 Nov » (en) : récapitulatif de réservation.
String formatSummaryDay(DateTime d, String locale) {
  final wd = capitalize(
    DateFormat('EEE', locale).format(d).replaceAll('.', ''),
  );
  return '$wd ${d.day} ${DateFormat('MMM', locale).format(d)}';
}

/// « mardi 24 novembre » (fr) / « Tuesday, November 24 » (en).
String formatLongDay(DateTime d, String locale, {bool capital = false}) {
  final s = DateFormat(
    isFrench(locale) ? 'EEEE d MMMM' : 'EEEE, MMMM d',
    locale,
  ).format(d);
  return isFrench(locale) && !capital ? s : capitalize(s);
}

String hhmm(DateTime d) => DateFormat('HH:mm').format(d);

/// Entier avec séparateur de milliers : « 1 700 » (fr, espace insécable) ou « 1,700 » (en).
String formatInt(int n, String locale) =>
    formatFcfa(n, locale).replaceAll(' FCFA', '');
