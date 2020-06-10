# encoding: UTF-8
=begin
  Class Gel
  ---------
  Gestion des gels
=end
require 'fileutils'

# Tous les dossiers à conserver dans un gel
WORKING_FOLDERS = []
['downloads','mails','signups'].each do |subfolder|
  WORKING_FOLDERS << File.expand_path(File.join('.','tmp', subfolder)).freeze
end

FOLDER_GELS = File.expand_path(File.join('.','spec','support','Gel','gels'))

def gel(name)
  Gel.get(name)
end #/ gel

class Gel
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def get(gel_name)
    @gels ||= {}
    @gels[gel_name] ||= new(gel_name)
  end #/ initiate
end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :name
def initialize name
  @name = name
end #/ initialize

# Méthode qui dégel le gel s'il existe, ou procède à l'opération
# voulue et produit le gel.
# Si +force+ existe et est true, on force le gel en le détruisant
def degel_or_gel(force = false, &block)
  remove if force || ENV['GEL_FORCE']
  if exists?
    puts "Je dégèle “#{name}”"
    degel
  else
    puts "Je joue et je gèle “#{name}”"
    yield if block_given?
    gel
  end
end #/ degel_or_gel

# = main =
# Procède au gel du gel
def gel
  # Créer le dossier du gel
  FileUtils.mkdir_p(folder)
  # Faire un dump de la base de données
  `mysqldump -u root icare_test > "#{folder}/icare_test.sql"`
  # Faire une duplication des dossiers
  WORKING_FOLDERS.each do |dossier|
    next unless File.exists?(dossier)
    FileUtils.cp_r(dossier, folder)
  end
end #/ gel

# = main =
# Procède au dégel du gel
def degel
  # Vider la base de données
  # Utile ?
  # Charger les données dans la base de données
  `mysql -u root icare_test < "#{folder}/icare_test.sql"`
  # Détruire les dossiers
  vide_all_dossiers
  # Les remplacer par les dossiers du gel
  WORKING_FOLDERS.each do |dossier|
    next unless File.exists?(dossier)
    dossier_name = File.basename(dossier)
    FileUtils.cp_r(File.join(folder, dossier_name), dossier)
  end
end #/ degel

# Force la destruction du gel
def remove
  FileUtils.rm_rf(folder)
end #/ remove

# Retourne true si le gel existe
def exists?
  File.exists?(folder)
end #/ exists?
# Dossier du gel
def folder
  @folder ||= File.join(FOLDER_GELS, name)
end #/ folder
end #/Gel
