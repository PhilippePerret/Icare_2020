# encoding: UTF-8
# frozen_string_literal: true
=begin

=end

# * Dossiers *
EVALUATION_FOLDER   = File.join(CONCOURS_FOLDER,'evaluation')
PARTIAL_FOLDER      = File.join(EVALUATION_FOLDER,'partials')
EVAL_DATA_FOLDER    = File.join(EVALUATION_FOLDER,'data')

# * Partiels *
PARTIAL_CHECKLIST  = File.join(PARTIAL_FOLDER,'checklist.erb')
CHECKLIST_TEMPLATE  = File.join(XMODULES_FOLDER,'evaluation','checklist_template.erb')


# * Data *
DATA_CHECK_LIST_FILE  = File.join(EVAL_DATA_FOLDER, 'data_evaluation.yaml')

# * Développement *
REBUILDER_CHECK_LIST = File.join(XMODULES_FOLDER,'evaluation','rebuild_checklist.rb')
