# encoding: UTF-8
=begin
  Class Gel
  ---------
  Gestion des gels
=end
require 'fileutils'
require_relative '../../lib/required' # pour quand appelé depuis IcareCLI

# Tous les dossiers à conserver dans un gel
WORKING_FOLDERS = []
['downloads','mails','signups'].each do |subfolder|
  WORKING_FOLDERS << File.expand_path(File.join('.','tmp', subfolder)).freeze
end

FOLDER_GELS = File.expand_path(File.join('.','spec','support','Gel','gels'))

def gel(name)
  Gel.get(name)
end #/ gel

# Pour procéder à un dégel
def degel(name)
  Gel.get(name).degel
end #/ degel

def degel_or_gel(name, force = false, &block)
  Gel.get(name).degel_or_gel(force, &block)
end #/ degel_or_gel

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
    degel
  else
    proceed_gel(&block)
  end
end #/ degel_or_gel

# = main =

# Joue le code et procède au gel
#
def proceed_gel(&block)
  puts "Je joue et je gèle “#{name}”"
  yield if block_given?
  gel
end #/ run_and_gel

# Procède au gel du gel
def gel
  # Créer le dossier du gel
  FileUtils.mkdir_p(folder)
  # Faire un dump de la base de données
  `mysqldump -u root icare_test > "#{folder}/icare_test.sql"`
  supfolder = File.dirname(folder)
  # Faire une duplication des dossiers
  WORKING_FOLDERS.each do |dossier|
    next unless File.exists?(dossier)
    # puts "Je place le dossier #{dossier.inspect} dans le dossier #{folder.inspect}"
    FileUtils.cp_r(dossier, folder)
  end
end #/ gel

# = main =
# Procède au dégel du gel
def degel
  remove if ENV['GEL_FORCE']
  unless exists?
    # Si le gel n'existe pas
    proceed_gel
    return self
  end
  puts "Dégel de #{name}…"
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
    src_folder = File.join(folder, dossier_name)
    dst_folder = File.dirname(dossier)
    # puts "Je REPLACE le dossier #{src_folder.inspect} dans le dossier #{dst_folder.inspect}"
    FileUtils.cp_r(src_folder, dst_folder)
  end
  return true
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