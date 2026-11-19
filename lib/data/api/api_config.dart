/// Adresse de l'API Tchihali, fournie à la compilation :
/// `flutter run --dart-define=API_BASE_URL=https://api.exemple.cm`
/// Vide = mode démo : données fictives, aucune connexion réseau.
class ApiConfig {
  static const baseUrl = String.fromEnvironment('API_BASE_URL');
  static bool get isConfigured => baseUrl.isNotEmpty;
}
