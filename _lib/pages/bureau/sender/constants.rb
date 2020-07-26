# encoding: UTF-8
=begin
  Constantes pour la partie bureau/sender
=end
UI_TEXTS.merge!({
  btn_transmettre_documents: 'Transmettre les documents'.freeze,
})
MESSAGES.merge!({
  # Pour les titres de page possible
  titre_:           'Transmission de documents non définie'.freeze,
  titre_send_work_form:  'Envoi des documents de travail'.freeze,
  titre_sent_work_confirmation: 'Bonne réception des documents'.freeze,
  actualite_send_work: '<span><strong>%{pseudo}</strong> transmet ses documents pour l’étape %{numero} de son module “%{module}”</span>'.freeze
})

ERRORS.merge!({
  sent_documents_required: 'Il faut choisir le document à transmettre !'.freeze,
  unable_document_treatment: 'Impossible de traiter le document %{name} : %{error}.'.freeze,
  note_required: 'vous devez définir la note estimative de ce document'.freeze
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
