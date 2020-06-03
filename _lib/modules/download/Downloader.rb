# encoding: UTF-8
=begin
  Class Downloader
  ----------------
  Pour procéder au téléchargement d'un document

  Les trois utilisations principales
  - télécharger un travail d'icarien (admin)
  - télécharger les commentaires (icarien)
  - télécharger des documents Quai des docs
=end
require 'zip' # rubyzip

class Downloader
class << self

end # /<< self

attr_reader :original_paths, :zipfile_name
# On initialise le downloader avec le chemin d'accès aux documents originaux
# et un nom qui servira pour le fichier zip
def initialize paths, zipfile_name = nil
  paths = [paths] unless paths.is_a?(Array)
  @original_paths = paths
  @zipfile_name   = zipfile_name || "download-#{Time.now.to_i}.zip"
  @zipfile_name << '.zip' unless @zipfile_name.end_with?('.zip')
end #/ initialize

# Pour faire un zip contenant les documents à downloader
def zipper_paths
  Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
    original_paths.each do |fpath|
      zipfile.add(File.basename(fpath), fpath)
    end
    # TODO plus tard, on pourra se servir de la ligne suivante pour
    # mettre l'avertissement de non divulgation
    # zipfile.get_output_stream("myFile") { |f| f.write "myFile contains just this" }
  end
end #/ zip_paths

# On procède véritablement au téléchargement
def download
  zipper_paths unless File.exists?(zip_path)
  File.exists?(zip_path) || raise("Impossible de zipper les fichiers à télécharger…")
  STDOUT.puts "Content-type: application/zip"
  STDOUT.puts "Content-disposition: attachment;filename=\"#{zipfile_name}\""
  STDOUT.puts "Content-length: #{zipfile_size}"
  STDOUT.puts ""
  STDOUT.puts File.open( zip_path, 'rb'){ |f| f.read }
  remove
end #/ download

# Destruction du zip
def remove
  File.unlink(zip_path) if File.exists?(zip_path)
end #/ remove

# Taille du fichier zip
def zipfile_size
  @zipfile_size ||= File.size(zip_path)
end #/ zipfile_size

# Chemin d'accès au zip contenant les documents
def zip_path
  @zip_path ||= File.join(DOWNLOAD_FOLDER, zipfile_name)
end #/ zip_path

end #/Downloader