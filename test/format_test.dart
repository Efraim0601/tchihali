import 'package:flutter_test/flutter_test.dart';
import 'package:tchihali/core/format.dart';
import 'package:tchihali/features/auth/signup_state.dart';

void main() {
  test('prix en FCFA : espace insécable en français, virgule en anglais', () {
    expect(formatFcfa(12000, 'fr_FR'), '12 000 FCFA');
    expect(formatFcfa(15000, 'en'), '15,000 FCFA');
    expect(formatFcfa(950, 'fr'), '950 FCFA');
    expect(formatInt(1700, 'fr'), '1 700');
  });

  test('capitalize', () {
    expect(capitalize('mardi'), 'Mardi');
    expect(capitalize(''), '');
  });

  test('numéro de téléphone : saisie locale <-> format international', () {
    expect(toE164('677 21 36 90'), '+237677213690');
    expect(toE164('677213690'), '+237677213690');
    expect(toLocalPhone('+237677213690'), '677 21 36 90');
  });
}
