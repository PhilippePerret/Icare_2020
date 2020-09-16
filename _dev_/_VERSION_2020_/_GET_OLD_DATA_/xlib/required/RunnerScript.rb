# encoding: UTF-8
# frozen_string_literal: true

# Liste des scripts à jouer
SCRIPTS_LIST = [
  # '2_temoignages',
  # '3_check_processus_watchers', # simple vérification des processus # TODO Traiter en une seule fois
  # '4_actualites',
  # '5_connexions',
  '6_tickets'
]

class RunnerScript
# ---------------------------------------------------------------------
#
#   CLASS
#
# ---------------------------------------------------------------------
class << self
  # Pour ajouter un succès de script, c'est-à-dire un script qui
  # est aller jusqu'au bout
  def add_success(script)
    data['success'].merge!(script.name => true)
    save_data
  end #/ add_success

  # Retourne TRUE si le script +script+ {RunnerScript} a été joué
  # avec succès
  def has_been_proceeded?(script)
    data['success'][script.name] == true
  end #/ has_been_proceeded?

  # Pour enregistrer les données (fait fréquemment — à chaque script)
  def save_data
    File.open(data_path,'wb'){|f|f.write data.to_json}
  end #/ save_data

  # Toutes les données
  # (pour le moment, la donnée se contente de consigner les scripts qui
  #  sont allés jusqu'au bout)
  def data
    @data ||= begin
      if File.exists?(data_path)
        JSON.parse(File.read(data_path))
      else
        {'success' => {}}
      end
    end
  end #/ data

  def reset_all
    File.delete(data_path) if File.exists?(data_path)
  end #/ reset_all

  def data_path
    @data_path ||= File.join(GOD_DATA_FOLDER,'scripts_data.json')
  end #/ data_path

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :name
def initialize(script_name)
  @name = script_name
end #/ initialize

# = main =
# Pour lancer le script
def proceed_if_necessary
  puts "---> ./xlib/db_scripts/#{name}".gris
  File.exists?(path) || raise("SCRIPT INEXISTANT")
  if script_must_be_proceed?
    proceed
    self.class.add_success(self)
  else
    puts TABU + 'OK'.gris
  end
rescue ErreurFatale => e
  raise e
rescue Exception => e
  puts "#    #{e.message.rouge}"
  puts e.backtrace.join(RC).rouge
end #/ proceed_if_necessary

# Pour jouer vraiment le script
def proceed
  load path
  puts "<--- SCRIPT SUCCESS".vert
end #/ proceed


def script_must_be_proceed?
  RESET_ALL || self.class.has_been_proceeded?(self)
end #/ script_must_be_proceed?

def path
  @path ||= File.join(GOD_SCRIPTS_FOLDER, "#{name}.rb")
end #/ path
end #/RunnerScript
