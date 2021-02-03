# encoding: UTF-8
# frozen_string_literal: true
require './_lib/required/__first/constants/paths'
require './_lib/required/__first/handies/files'
# PAGES_FOLDER  = File.expand_path(File.join('.','_lib','_pages_'))
# DATA_FOLDER   = File.expand_path(File.join('.','_lib','data'))
CONCOURS_FOLDER       = File.join(PAGES_FOLDER,'concours')
TEMP_CONCOURS_FOLDER  = mkdir(File.join(TEMP_FOLDER,'concours'))
XMODULES_FOLDER       = File.join(CONCOURS_FOLDER,'xmodules')
CONCOURS_DATA_FOLDER  = mkdir(File.expand_path(File.join(DATA_FOLDER,'concours')))
NOMBRE_QUESTIONS_PATH = File.join(CONCOURS_DATA_FOLDER,'NOMBRE_QUESTIONS')
CALCUL_FOLDER         = File.join(CONCOURS_FOLDER,'xmodules','calculs')

require './_lib/_pages_/concours/xrequired/Concours_mini'
ANNEE_CONCOURS_COURANTE = Concours.annee_courante

DBTBL_CONCOURS = Concours.table
DBTBL_CONCURRENTS = "concours_concurrents"
DBTBL_CONCURS_PER_CONCOURS = "concurrents_per_concours"
