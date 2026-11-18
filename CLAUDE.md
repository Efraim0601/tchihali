# Tchihali — instructions pour Claude Code

Tchihali est une application mobile (Android d'abord, iOS ensuite) de suivi nutritionnel avec diététicien, pour des adultes de 25 à 60 ans au **Cameroun**. Elle est **bilingue français / anglais**. Un espace praticien (tablette / web) permet aux diététiciens de gérer leur agenda, leurs patients et leurs comptes rendus.

Objectif n°1 : **reproduire fidèlement les maquettes**. Ne pas réinventer le design, ne pas ajouter d'écrans ou d'éléments qui n'y sont pas sans le demander.

## Source de vérité visuelle

- `design/maquettes/*.dc.html` : une maquette par écran (21 écrans). C'est la référence exacte.
- `design/captures/` : captures PNG des écrans (si présentes). Les regarder avant de coder un écran.
- `design/ECRANS.md` : description écran par écran (rôle, éléments, interactions, navigation).

### Comment lire un fichier `.dc.html`

- Le contenu visible est dans `<x-dc> … </x-dc>`. Ignorer `<script src="./support.js">` et `<helmet>` (sauf pour les animations CSS, voir plus bas).
- Les **styles inline** (`style="…"`) donnent les valeurs exactes : couleurs, tailles, marges, rayons, ombres, graisses. Les reprendre tels quels.
- `{{ t.cle }}` = texte traduit. Les textes **FR et EN** sont dans le `<script type="text/x-dc">`, dans `renderVals()` (objets `fr` / `en`). Les reprendre mot pour mot dans les fichiers ARB.
- `<sc-for list="{{ x }}" as="item">` = liste répétée (→ `ListView` / `Column` + `map`).
- `<sc-if value="{{ cond }}">` = affichage conditionnel.
- `onClick="{{ fonction }}"` + `this.setState(...)` = comportement interactif attendu (sélection, bascule, etc.).
- `<a href="Autre.dc.html">` = navigation vers un autre écran.
- Les styles calculés en JS (`style="{{ item.style }}"`) décrivent l'état sélectionné / non sélectionné : reproduire les deux états.
- Les illustrations sont des SVG inline : les reprendre en `flutter_svg` (ou `CustomPaint`) en attendant de vraies photos.

## Stack technique

- **Flutter** (stable), Dart, null-safety.
- Navigation : `go_router` (avec `StatefulShellRoute` pour la barre du bas).
- État : `flutter_riverpod`.
- Police : `google_fonts` → **Poppins** (400, 500, 600, 700). Ne pas utiliser d'autres graisses.
- Traductions : `flutter_localizations` + `intl` avec `lib/l10n/app_fr.arb` et `app_en.arb`. **Aucune chaîne en dur dans les widgets.** Langue par défaut : français. Choix de langue au premier écran et dans le Profil, mémorisé (`shared_preferences`).
- Courbes : `fl_chart`.
- Icônes : SVG des maquettes (traits arrondis, épaisseur 2) via `flutter_svg`.
- Données : commencer avec des **dépôts factices** (mock) qui renvoient les données de test ci-dessous. Le backend (auth SMS, paiement Mobile Money, vidéo) viendra plus tard derrière les mêmes interfaces.

## Thème (design tokens)

Couleurs :
| Rôle | Valeur |
|---|---|
| Fond de page | `#FAF7F2` |
| Surface / cartes | `#FFFFFF` |
| Vert principal (boutons, sélection) | `#4F7A5A` |
| Vert foncé (texte sur vert clair) | `#2F5238` / `#3E6448` |
| Vert clair (fonds doux, onglet actif) | `#E7EFE4` |
| Vert déco | `#8FB394` |
| Corail (accent, bouton +) | `#E0704F` |
| Corail texte | `#A9482F` |
| Pêche (avatars, cartes message) | `#F6C7B4` / `#FCE9E0` |
| Jaune doux | `#FBF0C9` (texte `#5E4700`) |
| Texte principal | `#2F3437` |
| Texte secondaire | `#646B6F` |
| Bordures | `#E4DED4` / `#EFEAE2` |
| Fond segmenté | `#EFEAE2` |
| Danger (raccrocher, déconnexion) | `#C4533A` |

Formes et espacements :
- Marge de page : 20 px (24 px sur inscription / questionnaire, 28 px sur l'onboarding).
- Cartes : rayon 22–24 px, ombre `0 4 16 rgba(47,52,55,0.05–0.06)`.
- Bouton principal : hauteur 56, rayon 18, fond `#4F7A5A`, texte blanc 16–17 px graisse 600.
- Champs : hauteur 54–56, rayon 16, bordure 1,5 px `#E4DED4`, fond blanc ; focus = bordure verte + halo.
- Puces (chips) : hauteur 40–42, rayon 14. Sélection = fond vert, texte blanc.
- Contrôle segmenté : fond `#EFEAE2`, padding 5, onglet actif blanc avec ombre légère.
- Boutons icône : 44 × 44 minimum, rayon 14.
- Zones tactiles : 44 px minimum partout.

Typographie (Poppins) :
- Titre d'écran : 24–30 px, 700.
- Titre de section : 15–17 px, 600.
- Corps : 14–16 px, 400/500.
- Méta / légendes : 12–13 px, couleur `#646B6F`.
- Barre de navigation : 11 px (500 inactif, 700 actif).

Barre de navigation du bas (5 onglets) : Accueil, Agenda, Journal, Messages, Profil. Fond blanc, bordure haute `#EFEAE2`. Onglet actif : icône dans une pastille `#E7EFE4`, texte `#3E6448`.

## Animations (à reproduire)

- Apparition des titres et cartes : fondu + glissement de 16 px vers le haut, 600 ms, courbe `Cubic(0.2, 0.8, 0.2, 1)`, décalage de 80 ms entre les cartes.
- Appui sur un bouton : léger rétrécissement (échelle 0,95), 180 ms.
- Changement de sélection : transition de couleur 250 ms.
- Courbes : tracé progressif de gauche à droite (1,6 s).
- Barres de progression et de macros : remplissage depuis la gauche (1 s).
- Pulsation douce : bouton « + » de l'accueil, voyant « En cours » de la visio, voyant de la salle d'attente.
- Feuille de confirmation (déconnexion) : glisse depuis le bas.
- Illustrations de l'onboarding : flottement lent (5 s).
- Si `MediaQuery.disableAnimations` est vrai : aucune animation.

## Données de test (Cameroun)

- Patiente : **Nadège Ngono**, +237 677 21 36 90, 38 ans, 1,65 m, prédiabète, intolérance au lactose, objectif 75 kg. Poids de 84,0 à 79,6 kg en 12 semaines.
- Diététicienne : **Estelle Mbarga**, Yaoundé, français / anglais / ewondo. Prochain RDV : mardi 24 novembre 2026, 10:30, vidéo.
- Annuaire : Serge Fotso (Douala, anglais / français / pidgin, vidéo seulement), Aïssatou Bello (Yaoundé, français / fulfulde, cabinet seulement).
- Patients praticien : Paul Atangana, Grâce Ekotto, Ibrahim Njoya, Martin Essomba, Linda Kamga, etc.
- Tarifs : vidéo 12 000 FCFA, cabinet 15 000 FCFA.
- Paiement : Orange Money, MTN MoMo, carte bancaire.
- Plats : ndolé léger, poisson braisé & miondo, koki de haricots, poulet DG allégé, bouillie de maïs, eru, plantain bouilli, foléré sans sucre.

## Structure de code attendue

```
lib/
  main.dart
  app/            router.dart, theme.dart (tokens ci-dessus), l10n
  core/widgets/   TchButton, TchCard, TchChip, TchSegmented, TchBottomNav, TchAvatar, TchBackButton, animations (FadeSlideIn, PressScale, Pulse)
  data/           modèles + dépôts factices (mock)
  features/
    onboarding/  auth/  questionnaire/  directory/  booking/  payment/
    home/  journal/  progress/  messages/  video/  record/  recipes/  profile/
    pro/agenda/  pro/patient/  pro/report/
  l10n/           app_fr.arb, app_en.arb
```

## Règles de travail

1. Avant de coder un écran, lire sa maquette `.dc.html` et sa description dans `design/ECRANS.md`.
2. Construire d'abord les widgets communs et le thème, puis les écrans un par un.
3. Reprendre les valeurs exactes (couleurs, tailles, rayons, textes FR/EN).
4. Chaque écran doit fonctionner sur un petit Android (largeur 360 px) sans débordement : utiliser le défilement si besoin.
5. Après chaque tâche : `flutter analyze` sans erreur, puis vérifier l'écran sur le téléphone (`flutter run`).
6. Ne pas ajouter de dépendance sans raison. Ne pas toucher au design sans demande explicite.

## Ordre conseillé

1. Thème, police, traductions FR/EN, widgets communs, barre de navigation.
2. Onboarding (3 écrans + choix de langue) → Inscription → Questionnaire.
3. Accueil, Journal, Profil (langue + déconnexion).
4. Annuaire → Réservation (calendrier mensuel) → Paiement.
5. Messages, Progrès, Carnet, Recettes, Fiche recette.
6. Salle d'attente, Téléconsultation (interface seulement au début).
7. Espace praticien : Agenda, Fiche patient, Compte rendu.
