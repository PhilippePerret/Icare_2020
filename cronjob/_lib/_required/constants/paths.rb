# encoding: UTF-8
=begin
  Constantes paths (chemins d'accès)
=end

CJDATA_FOLDER = File.join(CRON_FOLDER,'data')
LIB_FOLDER  = File.join(CRON_FOLDER,'_lib')
MODULES_FOLDER  = File.join(LIB_FOLDER,'modules')
APP_MODULES_FOLDER = File.join(APPFOLDER,'_lib','modules')

# Chemin d'accès au fichier contennant les données sur les
# dernières étapes
DATA_WORKS_PATH = File.join(CJDATA_FOLDER,'data_last_works.msh')
DATA_WORKS = {} # on mergera dedans le contenu du fichier précédent

DATA_FOLDER = File.join(APPFOLDER,'_lib','data')
