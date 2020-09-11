# encoding: UTF-8
# frozen_string_literal: true

ERRORS.merge!({
  pseudo_required:      'Le pseudo est requis',
  pseudo_too_short:     'Le pseudo doit faire au moins 4 caractères',
  pseudo_too_long:      'Le pseudo est trop long (50 signes maximum)',
  pseudo_already_exists: 'Ce pseudo est déjà utilisé. Merci d’en choisir un autre',
  patronyme_to_long:    'Le patronyme est trop long (100 caractères maximum)',
  mail_required:        'Votre mail est requis',
  mail_invalid:         'Ce mail est invalide',
  mail_already_exists:  'Ce mail est déjà utilisé par un icarien. Si vous voulez créer un autre compte à l’atelier, vous devez utiliser une autre adresse mail.',
  conf_mail_dont_match: 'La confirmation ne correspond pas au mail donné',
  # Mot de passe
  password_required: 'Le mot de passe est requis',
  password_too_short: 'Votre mot de passe est trop court (6 signes minimum)',
  password_too_long: 'Votre mot de passe est trop long (50 signes maximum)',
  password_invalid: 'Votre mot de passe ne doit contenir que des lettres, des chiffres et des ponctuations',
  conf_password_doesnt_match: 'La confirmation de votre mot de passe ne correspond pas',
  # CGU
  cgu_required: 'Vous devez approuver les <a href="https://www.atelier-icare.net/CGU_Atelier_ICARE.pdf" target="_blank">Conditions Générales d’Utilisation</a> de l’atelier Icare.',
  rgpd_required: 'Vous devez approuver la <a href="overview/policy" target="_blank">politique de confidentialité</a> de l’atelier Icare.',
  # DOCUMENTS
  presentation_required: 'Le document de votre présentation est requis',
  presentation_format_invalid: 'Le document de présentation doit être dans un format valide (PDF, .odt, .docx, Markdown ou RTF)',
  motivation_required: 'Votre lettre de motivation est requise',
  motivation_format_invalid: 'La lettre de motivation doit être dans un format valide (PDF, .odt, .docx, Markdown ou RTF)',
  # MODULES
  modules_required: 'Vous devez choisir au moins 1 module'
})
