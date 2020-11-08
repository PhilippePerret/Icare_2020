# encoding: UTF-8
# frozen_string_literal: true
=begin

=end
require './_lib/_pages_/concours/xmodules/synopsis/constants'

UI_TEXTS.merge!({
  button_marquer_non_conforme: "Marquer NON conforme"
})

# * Dossiers *
PARTIAL_FOLDER      = File.join(EVALUATION_FOLDER,'partials')

# * Partiels *
PARTIAL_CHECKLIST       = File.join(PARTIAL_FOLDER,'checklist.erb')
CHECKLIST_TEMPLATE      = File.join(XMODULES_FOLDER,'evaluation','checklist_template.erb')
FICHE_LECTURE_TEMP_PATH = File.join(XMODULES_FOLDER,'synopsis','templates','fiche_lecture_template.erb')

# * Data *
DATA_CHECK_LIST_FILE  = File.join(EVAL_DATA_FOLDER, 'data_evaluation.yaml')

# * Développement *
REBUILDER_CHECK_LIST = File.join(XMODULES_FOLDER,'evaluation','rebuild_checklist.rb')

# *** Les motifs de non conformité du synopsis ***
# Alimente la liste des checkboxes du formulaire de non conformité et
# permet de rédiger le mail au concurrent.
MOTIF_NON_CONFORMITE = {
  auteurs: {motif:'Absence du nom de ou des auteurs'},
  titre: {motif:'Absence du titre du projet'},
  support: {motif:'Absence de l’indication du support (roman, BD…)'},
  attestation:{motif:'Absence de l’attestion sur l’honneur'},
  bio:{motif: 'Absence du CV de l’auteur ou des auteurs'},
  incomplet: {motif: "Synopsis incomplet", precision: "le synopsis doit raconter l'intégralité de l'histoire, du début jusqu'à la conclusion"},
  corrupted: {motif: "Fichier corrompu", precision: "le fichier ne peut pas être ouvert"},
}
