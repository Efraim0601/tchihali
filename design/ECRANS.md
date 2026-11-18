# Tchihali — description des écrans

Chaque écran correspond à un fichier dans `maquettes/`. Format téléphone : 390 × 844. Espace praticien : page web fluide (largeur de référence 1280).

| # | Écran | Fichier | Route proposée | Onglet actif |
|---|---|---|---|---|
| 1 | Bienvenue + langue | Main.dc.html | /onboarding/1 | — |
| 2 | Onboarding 2 (journal photo) | Onboarding2.dc.html | /onboarding/2 | — |
| 3 | Onboarding 3 (cabinet ou vidéo) | Onboarding3.dc.html | /onboarding/3 | — |
| 4 | Inscription | Inscription.dc.html | /signup | — |
| 5 | Questionnaire (objectif) | Questionnaire.dc.html | /questionnaire | — |
| 6 | Annuaire des diététiciens | Annuaire.dc.html | /directory | Agenda |
| 7 | Réservation | Reservation.dc.html | /booking | Agenda |
| 8 | Paiement | Paiement.dc.html | /booking/payment | — |
| 9 | Accueil patient | Accueil.dc.html | /home | Accueil |
| 10 | Journal alimentaire | Journal.dc.html | /journal | Journal |
| 11 | Progrès | Progres.dc.html | /profile/progress | Profil |
| 12 | Messagerie | Messages.dc.html | /messages | Messages |
| 13 | Salle d'attente | SalleAttente.dc.html | /video/waiting | — |
| 14 | Téléconsultation | Teleconsultation.dc.html | /video/call | — |
| 15 | Carnet de suivi | Carnet.dc.html | /profile/record | Profil |
| 16 | Recettes | Recettes.dc.html | /journal/recipes | Journal |
| 17 | Fiche recette | FicheRecette.dc.html | /journal/recipes/:id | — |
| 18 | Profil | Profil.dc.html | /profile | Profil |
| 19 | Praticien — Agenda | ProAgenda.dc.html | /pro/agenda | — |
| 20 | Praticien — Fiche patient | ProFichePatient.dc.html | /pro/patients/:id | — |
| 21 | Praticien — Compte rendu | ProCompteRendu.dc.html | /pro/reports/:id | — |

## Patient

**1. Bienvenue** — Logo + « Tchihali ». Sélecteur FR / EN en haut à droite (change la langue de toute l'app et la mémorise). Illustration d'assiette qui flotte. Titre sur 2 lignes, texte court. Boutons « Commencer » (→ 2) et « J'ai déjà un compte » (→ 4).

**2–3. Onboarding** — Bouton retour, « Passer » (→ 4). Illustration, points de progression (3), titre, texte, bouton « Suivant » (→ suivant) / « Créer mon compte » (→ 4).

**4. Inscription** — Pas de mot de passe ni d'e-mail. Champs : nom, téléphone (préfixe +237 + numéro). Case « J'accepte les conditions… ». Bouton « Recevoir mon code » → (écran de saisie du code SMS à prévoir, même style) → 5.

**5. Questionnaire** — Barre de progression 1/3. Question « Quel est votre objectif ? ». 4 grandes cartes à choix unique (icône colorée, libellé, bouton radio). Bouton « Continuer ». Étapes 2/3 et 3/3 (santé, allergies) sur le même modèle.

**6. Annuaire** — Titre, champ de recherche + bouton Filtres, contrôle segmenté Tous / Vidéo / Cabinet qui **filtre la liste**. Cartes : avatar (initiales), nom, ville · spécialités, langues, prochain créneau (corail), bouton « Réserver » (→ 7).

**7. Réservation** — En-tête avec la diététicienne. Choix Vidéo / Cabinet (le prix change : 12 000 / 15 000 FCFA). **Calendrier mensuel** (semaine commençant le lundi, flèches mois précédent / suivant) : jours libres sur fond vert clair, jour choisi en vert plein, aujourd'hui entouré, week-ends / jours passés / jours fériés grisés et non cliquables. Créneaux en grille de 3 ; créneau complet en pointillés, non cliquable. Barre du bas : récapitulatif (jour · heure · mode), prix, « Continuer » (→ 8).

**8. Paiement** — Récapitulatif (diététicienne, mode, date). Choix Orange Money / MTN MoMo / Carte (radio). Si Mobile Money : champ numéro. Bouton « Payer 12 000 FCFA » (→ 9). Mention d'annulation gratuite 24 h avant.

**9. Accueil** — Date, « Bonjour Nadège ». Carte verte du prochain RDV (date, heure, diététicienne, mode, bouton « Salle d'attente » → 13). Carte « Aujourd'hui » : 3 objectifs cochables avec compteur x / 3. Carte pêche avec le dernier message de la diététicienne (→ 12). Bouton flottant corail « + » qui pulse (→ 10, ajout de repas).

**10. Journal** — Titre + lien « Recettes » (→ 16). Navigation par jour (flèches, « Aujourd'hui », kcal du jour / objectif). Carte repas : photo, étiquette « Déjeuner · 13:05 », nom du plat, kcal, 3 barres (protéines, glucides, lipides) qui se remplissent. Carte humeur : 5 visages (choix unique, le choisi grossit légèrement). Symptômes « Après le repas » en puces multi-choix.

**11. Progrès** — Retour (→ Profil). Segmenté Poids / IMC / Tour de taille : change la courbe. Valeur actuelle, évolution, courbe avec zone remplie, ligne d'objectif en pointillés corail, point final. Badges (3).

**12. Messages** — En-tête : avatar avec point « en ligne », nom, délai de réponse, bouton vidéo. Bulles : patiente à droite en vert, diététicienne à gauche en blanc ; photo de repas partagée. Saisie : bouton photo, champ, bouton envoyer corail (le message s'ajoute à la conversation).

**13. Salle d'attente** — Aperçu caméra, boutons micro / caméra (rouge quand coupés ; caméra coupée = avatar). Carte « Estelle arrive », point jaune qui pulse. Bouton « Entrer en consultation » (→ 14).

**14. Téléconsultation** — Vidéo plein écran de la diététicienne, vignette de soi en haut à droite, étiquette nom + « En cours » + minuteur (point qui pulse). 4 boutons ronds en bas : micro, caméra, messages, raccrocher (rouge, → 15).

**15. Carnet** — Retour (→ Profil). Segmenté Séance / Plan / Documents. Séance : date, résumé, objectifs. Plan : 4 repas avec heure en pastille colorée. Documents : liste avec bouton télécharger.

**16. Recettes** — Puces filtres (Toutes, Minceur, Diabète, Végétarien) qui filtrent la grille de 2 colonnes (illustration, nom, kcal · durée). Carte → 17.

**17. Fiche recette** — Image en haut, retour, favori (cœur). Feuille arrondie : titre, durée · portions · difficulté, 4 pastilles nutrition (kcal, protéines, glucides, lipides), ingrédients. Bouton « Ajouter à mon journal ».

**18. Profil** — Carte identité (initiales, nom, téléphone, bouton modifier). Ligne Langue avec segmenté Français / English. Liste : Mes progrès (→ 11), Mon carnet de suivi (→ 15), Mes informations de santé (→ 5), Notifications, Aide et contact. Bouton « Se déconnecter » (bordure corail) → feuille de confirmation (glisse du bas) : « Se déconnecter » (rouge, → 1) / « Annuler ».

## Praticien (page web fluide, menu latéral + contenu)

Menu latéral commun : logo, Agenda / Patients / Comptes rendus, en bas : segmenté Français / English, bloc praticienne (initiales, nom, rôle) + icône de déconnexion (→ écran 1 ou écran de connexion pro). Sur petit écran, le menu passe au-dessus du contenu.

**19. Agenda** — Titre + date, bouton « + Ajouter un créneau ». Semaine (lun–ven, 8 h–18 h) : RDV en blocs colorés (vert = cabinet, pêche = vidéo), jour courant mis en avant. Colonne « Demandes à valider » avec compteur : carte patient (initiales, nom, date, mode) + boutons Refuser / Valider → la carte affiche le résultat (validé : patient prévenu par SMS ; refusé : autre créneau proposé) et le compteur diminue.

**20. Fiche patient** — En-tête patient (initiales, nom, âge, taille, date de début, étiquettes) + bouton « Rédiger le compte rendu » (→ 21). 3 indicateurs (poids, tour de taille, glycémie à jeun) avec évolution. Courbe de poids avec objectif. Derniers repas (un repas tardif surligné en pêche). Notes privées (zone de texte, « visible uniquement par vous »).

**21. Compte rendu** — Contexte (patiente, séance, date), état « Brouillon enregistré à… », bouton « Envoyer à la patiente » (devient « Envoyé »). Gauche : mesures du jour (3 champs), « Ce qu'il faut retenir » (texte), objectifs (cases à cocher). Droite : plan alimentaire, onglets Lun → Dim, 4 repas avec kcal, total du jour / 1 700 kcal.
