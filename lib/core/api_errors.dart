import '../data/api/api_client.dart';
import '../l10n/gen/app_localizations.dart';

/// Message d'erreur lisible (traduit) pour une erreur d'API.
String apiErrorMessage(AppLocalizations l, Object error, {bool codeContext = false}) {
  if (error is ApiException) {
    if (error.isNetwork) return l.errorNetwork;
    if (error.isConflict) return l.errorSlotTaken;
    if (error.status == 429) return l.errorTooMany;
    if (codeContext && (error.status == 400 || error.status == 401)) return l.errorCode;
  }
  return l.errorGeneric;
}
