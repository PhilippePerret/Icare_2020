# encoding: UTF-8
=begin
  Constantes utiles pour les tests
=end
SPEC_FOLDER = File.expand_path('.','spec')
SPEC_SUPPORT_FOLDER   = File.join(SPEC_FOLDER,'support')
SPEC_FOLDER_DOCUMENTS = File.join(SPEC_SUPPORT_FOLDER, 'asset','documents')
FOLD_REL_PAGES = './_lib/_pages_' unless defined?(FOLD_REL_PAGES)

LIB_FOLDER = File.join(File.expand_path('.'),'_lib') unless defined?(LIB_FOLDER)

require './spec/support/data/signup_data'
# => DATA_SPEC_SIGNUP_INVALID
