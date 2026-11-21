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
mkdir -p secrets && openssl rand -hex 32 | tr -d '\n' > secrets/db_password.txt
sudo chown 10001:70 secrets/db_password.txt && sudo chmod 440 secrets/db_password.txt
cp .env.example .env     # puis éditer :
```
- Mot de passe en **hexadécimal** : il est inséré tel quel dans l'URL `postgresql://…`, où les caractères `/`, `+` et `=` du base64 cassent la connexion.
- Propriétaire `10001:70` : le fichier est monté tel quel dans les conteneurs. L'API tourne sous l'utilisateur `10001` (voir `Dockerfile`) et PostgreSQL sous le groupe `70` : avec `root` et `chmod 600`, l'API ne peut pas le lire et redémarre en boucle.
- `secrets/` et `.env` sont exclus de Git : ne jamais les committer.
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

Pas encore de nom de domaine : utiliser [sslip.io](https://sslip.io), qui associe un nom à l'IP du serveur (ex. IP `203.0.113.10` → `TCHIHALI_DOMAIN=203-0-113-10.sslip.io`). Let's Encrypt délivre le certificat normalement.

Données de démonstration (diététiciens fictifs), si besoin :
```bash
docker compose -f docker-compose.prod.yml exec api sh -c \
  'export TCHIHALI_DATABASE_URL="postgresql://tchihali:$(cat /run/secrets/db_password)@db:5432/tchihali"; python -m app.migrate --seed'
```

## 2 bis. Serveur de test public (sans fournisseur SMS)
Pour faire tester l'application avant d'avoir un fournisseur SMS, ajouter la surcouche `docker-compose.test.yml`. Dans `.env` : `TCHIHALI_SMS_PROVIDER=console` et `TCHIHALI_DEV_FIXED_CODE=123456` (les secrets JWT/OTP restent obligatoires).
```bash
docker compose -f docker-compose.prod.yml -f docker-compose.test.yml up -d --build
```
Tout le monde peut alors se connecter avec n'importe quel numéro et le code fixe : **données fictives uniquement**. Retirer la surcouche (et vider `TCHIHALI_DEV_FIXED_CODE`) avant d'accueillir de vrais patients.

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
