# Publier l'application Android

## 1. Créer la clé de signature (une seule fois — à conserver précieusement)
```bash
keytool -genkey -v -keystore ~/tchihali-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tchihali
```
Gardez ce fichier et ses mots de passe **en sécurité et sauvegardés** : sans eux, vous ne pourrez plus mettre à jour l'application sur le Play Store.
Ne les ajoutez jamais à git.

## 2. Déclarer la clé
```bash
cp android/key.properties.example android/key.properties
# puis renseigner les 4 valeurs
```

## 3. Compiler
```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.exemple.cm
```
Le fichier est dans `build/app/outputs/bundle/release/app-release.aab` (à envoyer au Play Console).
`API_BASE_URL` doit être en **HTTPS**.

## 4. Avant d'ouvrir à de vrais patients
- Textes légaux relus par un juriste (`lib/features/legal/legal_texts.dart`) et coordonnées complétées (`lib/app/legal_config.dart`).
- Serveur déployé selon `backend/DEPLOY.md` (HTTPS, disque chiffré, sauvegardes).
- Fournisseur SMS configuré et paiement Mobile Money branché (le paiement est simulé tant que ce n'est pas fait).
- Fiche Play Store : description, captures d'écran, politique de confidentialité (lien vers votre page), questionnaire « sécurité des données ».
- Incrémenter `version:` dans `pubspec.yaml` à chaque publication.
