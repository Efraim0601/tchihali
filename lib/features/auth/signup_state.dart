import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupData {
  const SignupData({this.name = 'Nadège Ngono', this.phone = '677 21 36 90'});
  final String name;
  final String phone;
}

class SignupNotifier extends Notifier<SignupData> {
  @override
  SignupData build() => const SignupData();
  void set(String name, String phone) => state = SignupData(name: name, phone: phone);
}

final signupProvider = NotifierProvider<SignupNotifier, SignupData>(SignupNotifier.new);
