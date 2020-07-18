# encoding: UTF-8
=begin
  Constantes paths (chemins d'accès)
=end

DATA_FOLDER = File.join(CRON_FOLDER,'data')
LIB_FOLDER  = File.join(CRON_FOLDER,'_lib')
MODULES_FOLDER  = File.join(LIB_FOLDER,'modules')

# Chemin d'accès au fichier contennant les données sur les
# dernières étapes
DATA_WORKS_PATH = File.join(DATA_FOLDER,'data_last_works.msh')
DATA_WORKS = {} # on mergera dedans le contenu du fichier précédent
