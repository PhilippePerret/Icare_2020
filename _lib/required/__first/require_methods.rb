# encoding: UTF-8

def require_folder foldername
  Dir["#{foldername}/**/*.rb"].each{|m|require m}
  require_css_in(foldername)
  require_js_in(foldername)
end

# Méthode qui permet de requérir les fichiers css dans le dossier
# folderpath
def require_css_in folderpath
  Dir["#{folderpath}/**/*.css"].each do |csspath|
    html.add_css(csspath)
  end
end

# Méthode qui permet de requérir les fichiers javascript dans le dossier
# folderpath
def require_js_in folderpath
  Dir["#{folderpath}/**/*.js"].each do |jspath|
    html.add_js(jspath)
  end
end

def require_module modname
  # Pour éviter de recharger un module déjà chargé
  @loaded_modules ||= {}
  return if @loaded_modules[modname]
  @loaded_modules.merge!(modname => true)
  # On charge le module
  path = File.join(MODULES_FOLDER, modname.to_s)
  pathrb = "#{path}.rb"
  if File.exists?(path) && File.directory?(path)
    require_folder(path)
  elsif File.exists?(path) || File.exists?(pathrb)
    require path
  else
    raise "Impossible de charger le module #{modname} (#{path})"
  end
end
