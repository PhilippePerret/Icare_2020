# encoding: UTF-8
# frozen_string_literal: true
PAGES_FOLDER  = File.expand_path(File.join('.','_lib','_pages_'))
DATA_FOLDER   = File.expand_path(File.join('.','_lib','data'))
CONCOURS_FOLDER = File.join(PAGES_FOLDER,'concours')
XMODULES_FOLDER = File.join(CONCOURS_FOLDER,'xmodules')
CONCOURS_DATA_FOLDER = File.expand_path(File.join(DATA_FOLDER,'concours')).tap{|p|`mkdir -p #{p}`}
NOMBRE_QUESTIONS_PATH = File.join(CONCOURS_DATA_FOLDER,'NOMBRE_QUESTIONS')

require './_lib/_pages_/concours/xrequired/Concours_mini'
ANNEE_CONCOURS_COURANTE = Concours.annee_courante

DBTBL_CONCOURS = Concours.table
DBTBL_CONCURRENTS = "concours_concurrents"
DBTBL_CONCURS_PER_CONCOURS = "concurrents_per_concours"
