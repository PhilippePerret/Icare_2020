# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthode utilisée par la partie administration (données par graphe/cartes)
  pour remonter les informations propre à un type d'objet (icarien, modules,
  etc.)
=end

=begin
  Sont placées ici toutes les requêtes pour obtenir des informations sur les
  éléments
=end

# Permet de récupérer les watchers de l'icarien
WATCHERS_ICARIEN_REQUEST  = "SELECT * FROM watchers WHERE user_id = ? ORDER BY created_at ASC"
WATCHERS_REQUEST          = "SELECT * FROM watchers WHERE objet_id = ? ORDER BY created_at ASC"

# Permet de récupérer les informations sur les modules d'un icarien
MODULES_REQUEST = <<-SQL
SELECT
  im.id, am.id AS abs_id, am.name AS module_name,
  im.started_at, im.ended_at, im.project_name
  FROM icmodules im
  INNER JOIN absmodules am ON am.id = im.absmodule_id
  WHERE user_id = ?
  ORDER BY im.started_at ASC
SQL

# Permet de récupérer les informations sur les étapes d'un module
ETAPES_REQUEST = <<-SQL
SELECT
  ie.*, ae.numero, ae.titre, ae.objectif
  FROM icetapes ie
  INNER JOIN absetapes ae ON ae.id = ie.absetape_id
  WHERE icmodule_id = ?
  ORDER BY ie.started_at ASC
SQL

# Permet de récupérer les informations sur les documents d'une étape
DOCUMENTS_REQUEST = <<-SQL
SELECT
  *
  FROM icdocuments idoc
  WHERE icetape_id = ?
  ORDER BY created_at ASC
SQL

# Méthode qui retourne les données des watchers pour l'objet de nom +objet_name+
# et d'identifiant +item_id+. Il peut s'agir par exemple qu'un icarien
# (objet_name = 'Icarien') ou d'une étape (objet_name = 'IcEtape')
#
# On retourne toutes les informations sur ces watchers, à savoir
#   - leurs données propres, telles qu'enregistrées dans la table watchers
#   - leurs données absolues, en fonction du wtype
#   - leur type d'objet pour l'outil administration, pour ne pas avoir à le
#     chercher, par exemple "Icarien" ou "IModule" respectivement pour les
#     icariens ou les IcModules.
#
def get_watchers_of(objet_name, item_id)
  require "#{APP_FOLDER}/_lib/_watchers_processus_/_constants_" # => DATA_WATCHERS
  # Traitement particulier pour les icariens, car c'est la propriété user_id
  # qu'il faut lire et on remonte des watchers de toutes sortes
  if objet_name == 'Icarien'
    rows_watchers = db_exec(WATCHERS_ICARIEN_REQUEST, item_id)
  else
    wtype_to_folder # pour forcer sa fabrication et voir
    rows_watchers = db_exec(WATCHERS_REQUEST, item_id).collect do |dw|
      next if not( wtype_to_folder[ dw[:wtype] ] == objet_name )
      dw
    end.compact
  end

  rows_watchers.collect do |dw|
    dw.merge({
      absdata: DATA_WATCHERS[dw[:wtype].to_sym]
    })
  end
end #/ get_watchers_of

def wtype_to_folder
  @wtype_to_folder ||= begin
    if not(File.exists?(path_wtype_to_folder)) || File.stat(path_wtype_to_folder).mtime < (Time.now - 7 * 3600 * 24)
      log("Il faut (re)faire le fichier path_wtype_to_folder.rb")
      File.delete(path_wtype_to_folder) if File.exists?(path_wtype_to_folder)
      coderb = {}
      DATA_WATCHERS.each do |wt, wd|
        coderb.merge!( wt => wd[:relpath].split('/').first )
      end
      coderb = <<-RUBY
# encoding: UTF-8
# frozen_string_literal: true
WTYPE_TO_OBJET = #{coderb.inspect}
      RUBY
      File.open(path_wtype_to_folder,'wb'){|f| f.write coderb }
    end
    require(path_wtype_to_folder)
    WTYPE_TO_OBJET
  end
end #/ wtype_to_folder

def path_wtype_to_folder
  @path_wtype_to_folder ||= File.join(APP_FOLDER,'_lib','ajax','ajax','module','wtype_to_objet.rb')
end #/ path_wtype_to_folder

begin
  type  = Ajax.param(:type)
  id    = Ajax.param(:objet_id)
  data = {}
  case type
  when 'Icarien'
    # Les modules suivis par l'icarien
    data.merge!(modules: db_exec(MODULES_REQUEST, id))
    # Les watchers de l'icarien
    data.merge!(watchers: get_watchers_of('Icarien', id))
  when 'IModule'
    # Les étapes du module
    data.merge!(etapes: db_exec(ETAPES_REQUEST, id))
    # Les watchers
    data.merge!(watchers: get_watchers_of('IcModule', id))
  when 'IEtape'
    # Les documents
    data.merge!(documents:db_exec(DOCUMENTS_REQUEST, id))
    # Les watchers
    data.merge!(watchers: get_watchers_of('IcEtape', id))
  end
  Ajax << {data: data, message:"Données de type #{type}"}
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
