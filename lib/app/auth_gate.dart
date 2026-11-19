import 'package:flutter/foundation.dart';

/// État de connexion lu par le routeur (redirection vers l'onboarding si non connecté).
class AuthGate extends ChangeNotifier {
  bool _signedIn = false;
  String _role = 'patient';

  bool get signedIn => _signedIn;
  String get role => _role;

  void set({required bool signedIn, String role = 'patient'}) {
    if (_signedIn == signedIn && _role == role) return;
    _signedIn = signedIn;
    _role = role;
    notifyListeners();
  }
}

final authGate = AuthGate();
