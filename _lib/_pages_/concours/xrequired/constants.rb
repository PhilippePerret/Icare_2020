# encoding: UTF-8
# frozen_string_literal: true
require './_lib/required/__first/helpers/Linker'

UI_TEXTS.merge!({
  # *** Titres ***
  titre_page_inscription: "Inscription au concours",
  concours_titre_participant: "Participation au concours",
  #  *** boutons ***
  concours_bouton_signup: "S’inscrire",
  concours_bouton_sidentifier: "S’identifier",
  concours_bouton_send_dossier: "Transmettre ce fichier",
  bouton_recup_numero: "Me renvoyer mon numéro d'inscription",
  concours_button_destroy: "Détruire mon inscription"
})

ERRORS.merge!({
  concours_mail_required: "Votre mail est requis, pour récupérer votre numéro d'inscription.",
  concours_mail_unknown: "Désolé, mais le mail '%s' est inconnu de nos services…",
  concours_login_required: "Identifiez-vous pour pouvoir rejoindre cette page.",
  invalid_num_for_destroy: "Le numéro d'inscription que vous avez fourni pour la destruction est invalide."
})

MESSAGES.merge!({
  concours_signed_confirmation: "Confirmation de votre inscription au concours de synopsis",
  concours_new_signup_titre: "Nouvelle inscription au concours de synopsis",
  concours_sujet_retrieve_numero: "Récupération de votre numéro d'inscription au concours",
  concours_confirm_destroyed: "Votre inscription au concours est détruite."
})

ANNEE_CONCOURS_COURANTE = Time.now.month < 3 ? Time.now.year : Time.now.year + 1
CONCOURS_THEME_COURANT = "L'ACCIDENT"
CONCOURS_THEME_DESCRIPTION = <<-TEXT
Avant l'accident, après l'accident, pendant l'accident, accident de la route ou de caddie, accident involontaire ou provoqué, peu importe le temps, le lieu, la durée choisis, l'histoire présentée dans le synopsis devra s'articuler autour de cet évènement dramatique.
TEXT

CONCOURS_DATA_FOLDER = File.expand_path(File.join('.','_lib','data','concours')).tap{|p|`mkdir -p #{p}`}


DBTABLE_CONCOURS = "concours"
DBTABLE_CONCURRENTS = "concours_concurrents"
DBTBL_CONCURS_PER_CONCOURS = "concurrents_per_concours"

REQUEST_CHECK_CONCURRENT = "SELECT * FROM #{DBTABLE_CONCURRENTS} WHERE concurrent_id = ? AND mail = ?"

CONCOURS_KNOWLEDGE_VALUES = [
  ["none", "Vous avez entendu parler de ce concours par…"],
  ["google", "une recherche google"],
  ["forum", "un forum d'écriture"],
  ["facebook", "un groupe Facebook"],
  ["someone", "bouche à oreille"],
  ["medias", "les médias"],
  ["autre", "un autre moyen"]
]

CONCOURS_LINK   = Linker.new(route:"concours/accueil", text:"Concours de Synopsis de l'atelier ICARE")
DOSSIER_LINK    = Linker.new(route:"concours/dossier", text:"fichier de candidature")
CONCOURS_SIGNUP = Linker.new(route:'concours/inscription', text:"formulaire d'inscription")
CONCOURS_LOGIN  = Linker.new(route:'concours/identification', text:"formulaire d'identification")

# Lien conduisant au règlement du concours de l'année en cours
REGLEMENT_LINK = Linker.new(route:"public/Concours_ICARE_#{ANNEE_CONCOURS_COURANTE}.pdf", target: :blank, text:"Réglement du concours")
