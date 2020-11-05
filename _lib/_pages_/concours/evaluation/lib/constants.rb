# encoding: UTF-8
# frozen_string_literal: true
=begin

=end
require './_lib/_pages_/concours/xmodules/synopsis/constants'

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
