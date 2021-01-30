# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class CDossier
  --------------
  Gestion du dossier (c'est un fichier) de participation à un concours
=end
require 'yaml'

class CDossier
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :name
def initialize(dosname)
  @name = dosname
end

# Méthode appelée pour downloader le fichier
# Retourne TRUE si le téléchargement s'est bien passé
def download
  ensure_local_folder
  cmd_download = IcareCLI::SSH_CONCOURS_DOWNLOAD_FILE % {local_path: local_path, cid:concurrent_id, fname: name}
  res = `#{cmd_download} 2>&1`
  puts "Résulat du download : #{res.inspect}"
  # On fait un fichier des données du concurrent avec les infos minimales
  File.open(info_file_path,'wb'){|f| f.write YAML.dump(file_info_data)}
  # On ouvre le dossier principal dans le finder
  `open -a Finder "#{local_folder}"`
  return local_file_exists?
end #/ download

# Données enregistrées dans le fichier de données
def file_info_data
  @file_info_data ||= {
    patronyme: concurrent_data['patronyme'],
    id:concurrent_id.to_i,
    annee:annee.to_i,
    filename: name,
    distant_path: distant_path,
    local_path: local_path
  }
end #/ file_info_data

def concurrent_data
  @concurrent_data ||= begin
    command = IcareCLI::SSH_CONCOURS_DATA_CONCURRENT % [concurrent_id.to_s]
    # puts "Command = #{command}"
    JSON.parse(`#{command}`)
  end
end #/ concurrent_data

# Chemin d'accès absolu au fichier local
def local_path
  @local_path ||= File.join(local_folder, name)
end #/ local_path

def local_file_exists?
  File.exists?(local_path)
end

def local_folder
  @local_folder ||= File.join(self.class.folder, concurrent_id)
end #/ local_folder

def distant_path
  @distant_path ||= File.join('www','_lib','data','concours',concurrent_id, name)
end #/ distant_path

def concurrent_id
  @concurrent_id ||= name.split(/[\.\-]/)[0]
end #/ concurrent_id

def annee
  @annee ||= name.split(/[\.\-]/)[1].to_i
end #/ annee

def info_file_path
  @info_file_path ||= File.join(local_folder, 'info.yaml')
end

# Pour s'assurer que le dossier local existe
def ensure_local_folder
  `mkdir -p "#{File.dirname(local_path)}"`
end #/ ensure_local_folder

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def folder
    @folder ||= begin
      ensure_folder(File.expand_path(File.join('.','_lib','data','concours_distant')))
    end
  end #/ folder
end # /<< self
end #/CDossier