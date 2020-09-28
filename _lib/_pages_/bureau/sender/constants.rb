# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour la partie bureau/sender
=end
UI_TEXTS.merge!({
  btn_transmettre_documents: 'Transmettre les documents',
})
MESSAGES.merge!({
  # Pour les titres de page possible
  titre_:           'Transmission de documents non définie',
  titre_send_work_form:  'Envoi des documents de travail',
  titre_sent_work_confirmation: 'Bonne réception des documents',
  actualite_send_work: '<span><strong>%{pseudo}</strong> transmet ses documents pour l’étape %{numero} de son module “%{module}”</span>',
  subject_mail_envoi_documents: "Envoi de documents de travail",
  subject_mail_document_recus: "Document%{s} de travail bien reçu%{s}"
})

ERRORS.merge!({
  sent_documents_required: 'Il faut choisir le document à transmettre !',
  unable_document_treatment: 'Impossible de traiter le document %{name} : %{error}.',
  note_required: 'vous devez définir la note estimative de ce document',
  nothing_to_send: 'Vous n’avez rien à envoyer !'
})

# Le temps approximatif pour commenter une page de document
NOMBRE_JOURS_PER_PAGE = 1.55

MOTS_PER_PAGE = 450

JOUR = 3600 * 24

RATIO_MOTS_PER_DOCTYPE = {
  '.odt'  => 0.097,
  '.rtf'  => 0.107,
  '.doc'  => 0.02,
  '.docx' => 0.162,
  'any'   => 0.097
}
