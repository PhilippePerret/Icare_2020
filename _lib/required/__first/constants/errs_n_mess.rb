# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour les messages d'erreur courants
=end
ERRORS    = {} unless defined?(ERRORS) # cas des tests
MESSAGES  = {} unless defined?(MESSAGES) # cas des tests
UI_TEXTS  = {} unless defined?(UI_TEXTS) # cas des tests

# --- Termes récurrents ---
UI_TEXTS.merge!({
  icarien: 'icarien',
  destroy: 'Détruire',
  btn_apercu: 'Aperçu',
  btn_edit:  'éditer',
  btn_envoyer: 'Envoyer',
  modules_apprentissage: 'Les Modules d’apprentissage',
})

ERRORS.merge!({
  unfound_user_with_id: "Impossible de trouver un utilisateur d'identifiant %s…",
  alert_intrusion: "Ceci ressemble à une intrusion en force. Je ne peux pas vous laisser passer…",
  no_data_modified: 'Aucune donnée n’a été modifiée…',
  no_initial_data_provided: 'Aucune donnée d’initialisation fournie.',
  unfound_data: 'Données introuvables (avec %{with})',
  admin_required: 'Cette opération requiert impérativement un administrateur…',
})

MESSAGES.merge!({
  ask_identify: 'Merci de vous identifier avant de rejoindre cette page.'
})
