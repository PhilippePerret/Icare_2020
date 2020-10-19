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
  concours_bouton_send_dossier: "Transmettre ce dossier",
  bouton_recup_numero: "Me renvoyer mon numéro d'inscription"
})

ERRORS.merge!({
  concours_mail_required: "Votre mail est requis, pour récupérer votre numéro d'inscription.",
  concours_mail_unknown: "Désolé, mais le mail '%s' est inconnu de nos services…",
  concours_login_required: "Identifiez-vous pour pouvoir rejoindre cette page."
})

MESSAGES.merge!({
  concours_signed_confirmation: "Confirmation de votre inscription au concours de synopsis",
  concours_new_signup_titre: "Nouvelle inscription au concours de synopsis",
  concours_sujet_retrieve_numero: "Récupération de votre numéro d'inscription au concours"
})

ANNEE_CONCOURS_COURANTE = Time.now.month < 3 ? Time.now.year : Time.now.year + 1
CONCOURS_THEME_COURANT = "L'ACCIDENT"
CONCOURS_THEME_DESCRIPTION = <<-TEXT
Avant l'accident, après l'accident, pendant l'accident, accident de la route ou de caddie, accident involontaire ou provoqué, peu importe le temps, le lieu, la durée choisis, l'histoire présentée dans le synopsis devra s'articuler autour d'un accident.
TEXT

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
DOSSIER_LINK    = Linker.new(route:"concours/dossier", text:"dossier de candidature")
CONCOURS_SIGNUP = Linker.new(route:'concours/inscription', text:"formulaire d'inscription")
CONCOURS_LOGIN  = Linker.new(route:'concours/identification', text:"formulaire d'identification")

# Lien conduisant au règlement du concours de l'année en cours
REGLEMENT_LINK = Linker.new(route:"public/Concours_ICARE_#{ANNEE_CONCOURS_COURANTE}.pdf", target: :blank, text:"Réglement du concours")
