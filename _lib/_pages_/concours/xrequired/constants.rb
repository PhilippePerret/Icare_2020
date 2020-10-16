# encoding: UTF-8
# frozen_string_literal: true

UI_TEXTS.merge!({
  # *** Titres ***
  titre_page_inscription: "Inscription au concours",
  concours_titre_participant: "Participation au concours",
  #  *** boutons ***
  concours_bouton_signup: "S’inscrire",
  concours_bouton_sidentifier: "S’identifier",
  concours_bouton_send_dossier: "Transmettre ce dossier",
})

ANNEE_CONCOURS_COURANTE = Time.now.month < 3 ? Time.now.year : Time.now.year + 1

DBTABLE_CONCURRENTS = "concours_concurrents"
DBTABLE_CONCOURS    = "concours"

# Lien conduisant au règlement du concours de l'année en cours
REGLEMENT_LINK = "<a href=\"public/Concours_ICARE_#{ANNEE_CONCOURS_COURANTE}.pdf\" target=\"_blank\">Réglement du concours</a>"
