# encoding: UTF-8
=begin
  Ce module contient des méthodes pratiques pour les codes helpers récurrents.
=end
require './_lib/required/__first/handies/string' # pour safe, par exemple

ERRORS = {} unless defined?(ERRORS)
ERRORS.merge!({
  file_unfound: 'Fichier introuvable : %s'.freeze,
  mark_unfound_file: '[FICHIER MANQUANT : `%s`]'.freeze,
})

# Permet de créer le path +dirpath+ si le dossier n'existe pas
def mkdir dirpath
  `mkdir -p "#{dirpath}"` unless File.exists?(dirpath)
  dirpath
end #/ mkdir

def file_read(path)
  if File.exists?(path)
    begin
      File.open(path,'rb'){|f|safe(f.read)}
    rescue Exception => e
      log("PROBLÈME AVEC LE FICHIER: #{path}")
      return ""
    end
  else
    erreur ERRORS[:file_unfound] % [path]
    return ERRORS[:mark_unfound_file] % [path]
  end
end #/ file_read

def full_path(relpath)
  fromCaller(relpath, Kernel.caller)
end #/ full_path
alias :fullpath :full_path

def fromCaller(relpath, from)
  File.join(File.dirname(from[0].split(':')[0]), relpath.to_s)
end #/ fromCaller

# Demarkdownise le fichier de chemin relatif +relpath+ (par rapport au dossier
# courant)
def kramdown relpath, owner = nil, options = nil
  str = AIKramdown.kramdown(relpath, owner, File.dirname(Kernel.caller[0].split(':')[0]))
  return str if options && options[:formate] === false
  str&.special_formating
end #/ kramdown

def deyaml relpath
  MyYAML.my_load(relpath, Kernel.caller[0].split(':')[0])
end #/ deyaml

def first_is_older_than(file1, file2, default_if_not_exist)
  file1 = fromCaller(file1, Kernel.caller) unless File.exists?(file1)
  file2 = fromCaller(file2, Kernel.caller) unless File.exists?(file2)
  return default_if_not_exist unless File.exists?(file1) && File.exists?(file2)
  File.stat(file1).mtime < File.stat(file2).mtime
end #/ fisrt_is_older_than

def download(path, zipname = nil, options = nil)
  require_module('download')
  Downloader.new(path,zipname,options).download
end #/ download
