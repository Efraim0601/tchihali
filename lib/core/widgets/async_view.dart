import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../api_errors.dart';
import 'tch_button.dart';

/// Affiche un chargement, une erreur avec « Réessayer », ou le contenu d'une donnée asynchrone.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.onRetry, required this.builder});
  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) => value.when(
        data: builder,
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator(color: Tch.green)),
        ),
        error: (e, _) {
          final l = AppLocalizations.of(context);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Text(apiErrorMessage(l, e),
                    textAlign: TextAlign.center,
                    style: Tch.style(15, color: Tch.textSecondary, height: 1.5)),
                const SizedBox(height: 16),
                TchButton(label: l.retry, expand: false, height: 48, onPressed: onRetry),
              ],
            ),
          );
        },
      );
}
