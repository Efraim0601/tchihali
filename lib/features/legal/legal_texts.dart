import '../../app/legal_config.dart';
import '../../data/models.dart';

/// Section d'un texte juridique : titre + paragraphe.
class LegalSection {
  const LegalSection(this.title, this.body);
  final LText title;
  final LText body;
}

// ATTENTION : textes de travail rédigés sans relecture juridique. Ils doivent être relus et
// validés par un juriste (droit de la santé et protection des données applicable au Cameroun)
// avant la mise en production, puis `LegalConfig.termsVersion` doit être incrémenté.

final termsSections = <LegalSection>[
  LegalSection(
    const LText('Qui sommes-nous ?', 'Who we are'),
    LText(
      'Tchihali est une application de suivi nutritionnel avec une diététicienne ou un diététicien. Elle est éditée par ${LegalConfig.publisher}. Contact : ${LegalConfig.contactEmail}.',
      'Tchihali is a nutrition follow-up app with a dietitian. It is published by ${LegalConfig.publisher}. Contact: ${LegalConfig.contactEmail}.',
    ),
  ),
  const LegalSection(
    LText('Ce que fait l\'application', 'What the app does'),
    LText(
      'Tchihali vous permet de tenir un journal alimentaire, de suivre vos mesures, de prendre rendez-vous avec un diététicien, d\'échanger avec lui et de recevoir ses comptes rendus. Les diététiciens sont des professionnels indépendants : ils sont seuls responsables de leurs conseils.',
      'Tchihali lets you keep a food journal, track your measurements, book an appointment with a dietitian, chat with them and receive their reports. Dietitians are independent professionals: they alone are responsible for their advice.',
    ),
  ),
  const LegalSection(
    LText('Pas une urgence médicale', 'Not a medical emergency service'),
    LText(
      'L\'application ne remplace pas un médecin et ne convient pas aux urgences. En cas de malaise ou de symptôme grave, contactez immédiatement un service médical d\'urgence.',
      'The app does not replace a doctor and is not suitable for emergencies. In case of a serious symptom, contact an emergency medical service immediately.',
    ),
  ),
  const LegalSection(
    LText('Votre compte', 'Your account'),
    LText(
      'Vous vous connectez avec votre numéro de téléphone et un code reçu par SMS. Vous devez avoir 18 ans ou plus, fournir des informations exactes et ne pas partager votre accès.',
      'You sign in with your phone number and a code sent by text message. You must be 18 or older, provide accurate information and not share your access.',
    ),
  ),
  const LegalSection(
    LText('Rendez-vous et paiement', 'Appointments and payment'),
    LText(
      'Les tarifs sont affichés avant le paiement (en FCFA). Un rendez-vous est confirmé par le diététicien ; s\'il le refuse, vous êtes remboursé. L\'annulation est gratuite jusqu\'à 24 h avant le rendez-vous.',
      'Prices are shown before payment (in FCFA). An appointment is confirmed by the dietitian; if they decline, you are refunded. Cancellation is free up to 24 hours before the appointment.',
    ),
  ),
  const LegalSection(
    LText('Utilisation correcte', 'Proper use'),
    LText(
      'Vous vous engagez à utiliser l\'application de bonne foi, sans tenter d\'accéder aux données d\'autres personnes ni de perturber le service.',
      'You agree to use the app in good faith, without trying to access other people\'s data or disrupt the service.',
    ),
  ),
  const LegalSection(
    LText('Suppression et modification', 'Deletion and changes'),
    LText(
      'Vous pouvez supprimer votre compte à tout moment depuis votre profil. Nous pouvons modifier ces conditions ; en cas de changement important, nous vous demanderons de les accepter de nouveau.',
      'You can delete your account at any time from your profile. We may update these terms; for important changes, we will ask you to accept them again.',
    ),
  ),
];

final privacySections = <LegalSection>[
  LegalSection(
    const LText('Responsable du traitement', 'Data controller'),
    LText(
      '${LegalConfig.publisher} est responsable du traitement de vos données. Contact : ${LegalConfig.contactEmail}.',
      '${LegalConfig.publisher} is the controller of your data. Contact: ${LegalConfig.contactEmail}.',
    ),
  ),
  const LegalSection(
    LText('Les données que nous collectons', 'Data we collect'),
    LText(
      'Votre nom et votre numéro de téléphone ; vos informations de santé (objectif, pathologies, allergies, taille, poids, tour de taille, glycémie) ; vos repas, photos de repas, humeur et symptômes ; vos messages et photos échangés avec votre diététicien ; vos rendez-vous et paiements ; les comptes rendus rédigés pour vous.',
      'Your name and phone number; your health information (goal, conditions, allergies, height, weight, waist, glucose); your meals, meal photos, mood and symptoms; your messages and photos exchanged with your dietitian; your appointments and payments; the reports written for you.',
    ),
  ),
  const LegalSection(
    LText('Pourquoi', 'Why'),
    LText(
      'Pour assurer votre suivi nutritionnel, organiser vos rendez-vous, permettre les échanges avec votre diététicien et traiter les paiements. Les données de santé sont traitées avec votre consentement, que vous donnez en créant votre compte et pouvez retirer en supprimant votre compte.',
      'To provide your nutrition follow-up, organise your appointments, enable exchanges with your dietitian and process payments. Health data is processed with your consent, which you give when creating your account and can withdraw by deleting your account.',
    ),
  ),
  const LegalSection(
    LText('Qui voit vos données', 'Who sees your data'),
    LText(
      'Seuls vous et le ou les diététiciens avec qui vous avez un rendez-vous ou une conversation y accèdent. Vos notes privées de santé ne sont jamais visibles par d\'autres patients. Nous ne vendons pas vos données et ne les utilisons pas pour de la publicité.',
      'Only you and the dietitian(s) you have an appointment or conversation with can access them. Other patients never see your data. We do not sell your data or use it for advertising.',
    ),
  ),
  LegalSection(
    const LText('Hébergement et sécurité', 'Hosting and security'),
    LText(
      'Vos données sont hébergées sur des serveurs situés dans le pays suivant : ${LegalConfig.hostingCountry}. Les échanges sont chiffrés (HTTPS), les accès aux données de santé sont journalisés et votre session est protégée sur votre téléphone.',
      'Your data is hosted on servers located in: ${LegalConfig.hostingCountry}. Exchanges are encrypted (HTTPS), access to health data is logged and your session is protected on your phone.',
    ),
  ),
  const LegalSection(
    LText('Combien de temps', 'How long'),
    LText(
      'Nous conservons vos données tant que votre compte existe. Si vous supprimez votre compte, vos données sont effacées définitivement. Seule une trace technique de l\'effacement, sans donnée personnelle, est conservée.',
      'We keep your data as long as your account exists. If you delete your account, your data is permanently erased. Only a technical record of the deletion, with no personal data, is kept.',
    ),
  ),
  const LegalSection(
    LText('Vos droits', 'Your rights'),
    LText(
      'Depuis votre profil, vous pouvez exporter toutes vos données dans un fichier et supprimer votre compte. Vous pouvez aussi corriger votre nom. Pour toute autre demande (accès, rectification, opposition), écrivez-nous à l\'adresse de contact.',
      'From your profile you can export all your data in a file and delete your account. You can also correct your name. For any other request (access, rectification, objection), write to the contact address.',
    ),
  ),
];
