# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class CDossier
  --------------
  Gestion du dossier (c'est un fichier) de participation à un concours
=end
require 'yaml'
require_relative './constants'

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
  unless res.empty?
    puts "Résulat du download de '#{local_path}' : #{res.inspect}"
  end
  # On fait un fichier des données du concurrent avec les infos minimales
  File.open(info_file_path,'wb'){|f| f.write YAML.dump(file_info_data)}
  # Si le fichier est un docx, on le transforme en PDF
  if extension != '.pdf'
    begin
      to_pdf && upload_pdf
    rescue Exception => e
      log(e)
      msg = e.message + "\n" + e.backtrace.join
      puts "ERREUR (to_pdf) : #{msg}".rouge
    end
  end
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

# Transforme le fichier en PDF
# Retoure TRUE si le fichier PDF a été produit
def to_pdf
  print "Je fabrique le PDF, merci de patienter…".bleu
  case extension
  when '.docx'  then docx2pdf(local_path)
  when '.odt'   then odt2pdf(local_path)
  else raise "Je ne sais pas comment transformer un document #{extension} en PDF…"
  end
  puts "\rFichier #{extension} converti en PDF avec succès.".vert
  return File.exists?(local_pdf_path)
end #/ to_pdf

# Upload le fichier PDF produit
def upload_pdf
  if File.exists?(local_pdf_path)
    print "Transmission du PDF…".bleu
    res = `scp -p '#{local_pdf_path}' #{SSH_ICARE_SERVER}:#{distant_pdf_path}`
    puts "\rFichier PDF uploadé sur le site distant".vert
  else
    puts "Impossible d'uploader le fichier PDF, il est introuvable (#{local_pdf_path})".rouge
  end
end #/ upload_pdf

# Chemin d'accès absolu au fichier local
def local_path
  @local_path ||= File.join(local_folder, name)
end
def local_pdf_path
  @local_pdf_path ||= File.join(local_folder, pdf_name)
end
def pdf_name
  @pdf_name ||= "#{File.basename(name, File.extname(name))}.pdf"
end

def local_file_exists?
  File.exists?(local_path)
end

def local_folder
  @local_folder ||= File.join(self.class.folder, concurrent_id)
end

def distant_path
  @distant_path ||= File.join('www','_lib','data','concours',concurrent_id, name)
end #/ distant_path
def distant_pdf_path
  @distant_pdf_path ||= File.join('www','_lib','data','concours',concurrent_id, pdf_name)
end

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
  mkdir(File.dirname(local_path))
end #/ ensure_local_folder

def extension
  @extension ||= File.extname(name)
end

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def folder
    @folder ||= begin
      mkdir(File.expand_path(File.join('.','_lib','data','concours_distant')))
    end
  end #/ folder
end # /<< self
end #/CDossier
