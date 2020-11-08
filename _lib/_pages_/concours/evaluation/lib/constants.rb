# encoding: UTF-8
# frozen_string_literal: true
=begin

=end
require './_lib/_pages_/concours/xmodules/synopsis/constants'

UI_TEXTS.merge!({
  button_marquer_non_conforme: "Marquer NON conforme",
})

MESSAGES.merge!({
  msg_file_non_conforme:"Le synopsis a été marqué non conforme. %{pseudo} a été averti%{e}.",
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
  auteurs: {motif:'absence de la mention de ou des auteurs'},
  titre: {motif:'absence du titre du projet'},
  support: {motif:'absence de l’indication du support de destination', precision: "vous devez indiquer si c'est un roman, une nouvelle, un long-métrage, un court-métrage, une bande dessinée, etc."},
  attestation:{motif:'absence de l’attestion sur l’honneur'},
  signature:{motif:'absence de votre adresse mail (celle ayant servi à vous inscrire) en guise de signature dans l’attestation'},
  bio:{motif: 'absence de la courte biographie de l’auteur ou des auteurs', precision:"cette biographie, qui peut être très courte, nous permet de mieux vous connaitre"},
  incomplet: {motif: "synopsis incomplet", precision: "le synopsis doit raconter l'intégralité de l'histoire, du début jusqu'à sa conclusion"},
  corrupted: {motif: "fichier corrompu", precision: "malgré tous nos efforts, le fichier n'a pas pu être ouvert"},
  non_respect: {motif:"non respect des contraintes de contenu", precision:"cf. particulièrement l'alinea 4 de l'article 17 du #{REGLEMENT_LINK.with(full:true)}"}
}
