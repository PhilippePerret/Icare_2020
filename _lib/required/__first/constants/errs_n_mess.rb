# encoding: UTF-8
=begin
  Constantes pour les messages d'erreur courants
=end
ERRORS    = {} unless defined?(ERRORS) # cas des tests
MESSAGES  = {} unless defined?(MESSAGES) # cas des tests
UI_TEXTS  = {} unless defined?(UI) # cas des tests

ERRORS.merge!({
  unfound_user_with_id: "Impossible de trouver un utilisateur d'identifiant %s…".freeze,
  alert_intrusion: "Ceci ressemble à une intrusion en force. Je ne peux pas vous laisser passer…".freeze,
  no_data_modified: 'Aucune donnée n’a été modifiée…'.freeze,
  no_initial_data_provided: 'Aucune donnée d’initialisation fournie.'.freeze,
  unfound_data: 'Données introuvables (avec %{with})'.freeze,
  file_unfound: 'Fichier introuvable : %s'.freeze,
  mark_unfound_file: '[FICHIER MANQUANT : `%s`]'.freeze,
  erb_error_with: 'ERB ERROR AVEC %s'.freeze,
})

MESSAGES.merge!({
  ask_identify: 'Merci de vous identifier avant de rejoindre cette page.'.freeze
})

UI_TEXTS.merge!({
  destroy: 'Détruire'.freeze,
  btn_edit:  'éditer'.freeze,
})
