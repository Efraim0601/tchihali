# Déployer l'API Tchihali (serveur loué)

Les données de santé des patients sont sensibles : suivez cette liste dans l'ordre.

## 1. Serveur
- Un VPS Linux (Ubuntu LTS), dans le pays que vous avez choisi (à indiquer dans les textes légaux, `LegalConfig.hostingCountry`).
- **Disque chiffré** (option du fournisseur ou LUKS) : la base et les photos y sont stockées.
- Pare-feu : n'ouvrir que les ports **22** (SSH, par clé uniquement), **80** et **443**.
- Mises à jour de sécurité automatiques (`unattended-upgrades`), connexion SSH par mot de passe désactivée.
- Docker et Docker Compose installés.

## 2. Configuration
```bash
cd backend
mkdir -p secrets && openssl rand -base64 32 > secrets/db_password.txt && chmod 600 secrets/db_password.txt
cp .env.example .env     # puis éditer :
```
Dans `.env` :
- `TCHIHALI_ENV=production`
- `TCHIHALI_JWT_SECRET` et `TCHIHALI_OTP_SECRET` : chacun `openssl rand -hex 32` (le serveur **refuse de démarrer** avec les valeurs par défaut)
- `TCHIHALI_SMS_PROVIDER` : un vrai fournisseur (voir `app/sms.py`) — `console` est refusé en production
- `TCHIHALI_DEV_RETURN_CODE=false`
- `TCHIHALI_TERMS_VERSION` : identique à `LegalConfig.termsVersion` dans l'application

Nom de domaine : un enregistrement DNS `A` vers l'IP du serveur, puis :
```bash
export TCHIHALI_DOMAIN=api.exemple.cm
docker compose -f docker-compose.prod.yml up -d --build
```
Caddy obtient le certificat HTTPS tout seul. Vérifier : `curl https://api.exemple.cm/health`.

## 3. Comptes diététiciens
Un diététicien se connecte comme un patient (code SMS). Pour lui donner son rôle et le lier à sa fiche :
```bash
docker compose -f docker-compose.prod.yml exec api python -m app.admin dietitian +237XXXXXXXXX estelle
```
(`estelle` = identifiant de la fiche dans la table `dietitians`.)

## 4. Sauvegardes (obligatoire)
`scripts/backup.sh` (chiffrée avec `age`) chaque nuit via `cron`, et **copie hors du serveur**. Le script ne supprime jamais d'ancienne sauvegarde : à vous de fixer la durée de conservation. Voir `scripts/restore.md` ; testez une restauration.

## 5. Application mobile
Compiler en pointant vers l'API (HTTPS obligatoire) :
```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.exemple.cm
```

## 6. Ce qui reste à votre charge
- Fournisseur **SMS** et opérateurs **Mobile Money** : le paiement est aujourd'hui **simulé** (`TCHIHALI_PAYMENT_PROVIDER=simulated`), aucun argent ne bouge.
- Relecture **juridique** des textes (`lib/features/legal/legal_texts.dart`) et des obligations locales de protection des données de santé.
- Surveillance (disponibilité, espace disque) et plan en cas d'incident.
- Pas de limitation de débit globale : ajoutez-en une au niveau du serveur si besoin (le code SMS est déjà limité à 3 demandes / 10 min / numéro).
