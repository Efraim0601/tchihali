/// Informations juridiques à compléter avant la mise en production.
/// Ces valeurs apparaissent dans les conditions d'utilisation et la politique de confidentialité.
class LegalConfig {
  LegalConfig._();

  /// Version des textes : à changer à chaque modification. Doit correspondre à
  /// `TCHIHALI_TERMS_VERSION` du serveur (preuve de consentement datée et versionnée).
  static const termsVersion = '2026-11';

  static const publisher = '[Nom de l\'éditeur de Tchihali — à compléter]';
  static const contactEmail = '[adresse e-mail de contact — à compléter]';
  static const hostingCountry = '[pays d\'hébergement — à compléter]';
}
