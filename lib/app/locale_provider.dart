import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'locale';

/// Langue de l'app : français par défaut, choix mémorisé.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('fr');

  Future<void> load() async {
    try {
      final code = (await SharedPreferences.getInstance()).getString(_key);
      if (code == 'fr' || code == 'en') state = Locale(code!);
    } catch (_) {}
  }

  Future<void> set(Locale locale) async {
    state = locale;
    try {
      await (await SharedPreferences.getInstance()).setString(_key, locale.languageCode);
    } catch (_) {}
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
