# encoding: UTF-8
# frozen_string_literal: true
require_relative './Concours_mini'

require './_lib/required/__first/constants/paths'
require './_lib/required/__first/helpers/Linker'

UI_TEXTS.merge!({
  # *** Titres ***
  concours_titre_home_page: "Concours de synopsis de l’atelier Icare",
  titre_page_inscription: "Inscription au concours",
  concours_bouton_inscription: "Inscription au concours",
  concours_btn_signup_next: 'Inscription au prochain concours',
  concours_titre_participant: "Espace personnel",
  #  *** boutons ***
  concours_bouton_signup: "S’inscrire",
  concours_bouton_sidentifier: "S’identifier",
  concours_btn_identifiez_vous: "Identifiez-vous",
  concours_bouton_send_dossier: "Transmettre ce fichier",
  bouton_recup_numero: "Me renvoyer mon numéro d'inscription",
  concours_button_destroy: "Détruire mon inscription",
  concours_signup_session_concours: "Vous inscrire à la session %{annee} du concours",
})

ERRORS.merge!({
  concours_mail_required: "Votre mail est requis, pour récupérer votre numéro d'inscription.",
  concours_mail_unknown: "Désolé, mais le mail '%s' est inconnu de nos services…",
  concours_login_required: "Identifiez-vous pour pouvoir rejoindre cette page.",
  invalid_num_for_destroy: "Le numéro d'inscription que vous avez fourni pour la destruction est invalide.",
  titre_required: "Le titre du projet est requis.",
  too_long: "%s est trop long (maximum : %i).",
  concours_invalid_informations: "Désolé, je ne vous remets pas… Merci de vérifier votre adresse mail et le numéro de concurrent qui vous a été remis dans le message de confirmation lors de votre inscription.",
})

MESSAGES.merge!({
  concours_signed_confirmation: "Confirmation de votre inscription au concours de synopsis",
  concours_new_signup_titre: "Nouvelle inscription au concours de synopsis",
  concours_sujet_retrieve_numero: "Récupération de votre numéro d'inscription au concours",
  concours_confirm_destroyed: "Votre inscription au concours est détruite.",
  merci_fichier_et_titre: "Merci %s, votre fichier de candidature et votre titre ont bien été pris en compte.",
  concours_signup_ok: "Votre inscription au concours a été effectuée avec succès, %s !",
  concours_just_icarien_login_required: "Vous êtes icarien%{ne}, identifiez-vous pour vous inscrire facilement au concours !",
  concours_icarien_inscrit_login_required: "%{pseudo}, vous êtes déjà inscrit%{e}. Il vous suffit de vous identifier pour demander à participer à cette session du concours.",
  concours_confirm_inscription_session_courante: "Vous êtes maintenant inscrit%{e} à la session courante du concours.",
  concurrent_login_required: "Vous êtes déjà concurrent du concours, vous devez vous identifier (pour participer à la nouvelle session ou rejoindre votre espace personnel).",
})

CONCOURS_FOLDER = File.join(PAGES_FOLDER,'concours')
XMODULES_FOLDER = File.join(CONCOURS_FOLDER,'xmodules')
CONCOURS_DATA_FOLDER = File.expand_path(File.join(DATA_FOLDER,'concours')).tap{|p|`mkdir -p #{p}`}
NOMBRE_QUESTIONS_PATH = File.join(CONCOURS_DATA_FOLDER,'NOMBRE_QUESTIONS')

ANNEE_CONCOURS_COURANTE = Concours.annee_courante

DBTBL_CONCOURS = Concours.table
DBTBL_CONCURRENTS = "concours_concurrents"
DBTBL_CONCURS_PER_CONCOURS = "concurrents_per_concours"

REQUEST_CHECK_CONCURRENT = "SELECT * FROM #{DBTBL_CONCURRENTS} WHERE concurrent_id = ? AND mail = ?"

CONCOURS_LINK   = Linker.new(route:"concours/accueil", text:"Concours de Synopsis de l'atelier ICARE")
DOSSIER_LINK    = Linker.new(route:"concours/dossier", text:"fichier de candidature")
CONCOURS_SIGNUP = Linker.new(route:'concours/inscription', text:"formulaire d'inscription")
CONCOURS_LOGIN  = Linker.new(route:'concours/identification', text:"formulaire d'identification")
ESPACE_LINK     = Linker.new(route:'concours/espace_concurrent', text:"espace personnel")
PALMARES_LINK   = Linker.new(route:'concours/palmares', text:"palmarès #{ANNEE_CONCOURS_COURANTE}")

# Lien conduisant au règlement du concours de l'année en cours
REGLEMENT_LINK = Linker.new(route:"public/Concours_ICARE_#{ANNEE_CONCOURS_COURANTE}.pdf", target: :blank, text:"Règlement du concours")
