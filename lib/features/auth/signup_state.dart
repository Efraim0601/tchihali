import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupData {
  const SignupData({this.name = 'Nadège Ngono', this.phone = '677 21 36 90'});
  final String name;
  final String phone;
}

/// Numéro international (+237…) à partir de la saisie locale « 677 21 36 90 ».
String toE164(String local) => '+237${local.replaceAll(RegExp(r'\D'), '')}';

/// « +237677213690 » -> « 677 21 36 90 ».
String toLocalPhone(String e164) {
  final d = e164.replaceFirst('+237', '').replaceAll(RegExp(r'\D'), '');
  if (d.length != 9) return d;
  return '${d.substring(0, 3)} ${d.substring(3, 5)} ${d.substring(5, 7)} ${d.substring(7)}';
}

class SignupNotifier extends Notifier<SignupData> {
  @override
  SignupData build() => const SignupData();
  void set(String name, String phone) => state = SignupData(name: name, phone: phone);
}

final signupProvider = NotifierProvider<SignupNotifier, SignupData>(SignupNotifier.new);
