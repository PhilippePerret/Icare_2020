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

# Requérir plusieurs modules en une méthode
def require_modules ary_modname
  ary_modname.each do |modname|
    require_module(modname)
  end
end #/ require_modules

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
  # Ensuite on charge tous les dossiers xrequired dans la
  # hiérarchie
  load_xrequired_on_hierarchy(path)
end

# Charge les dossiers xrequired qui pourraient se trouver dans la hiérarchie
# du module
def load_xrequired_on_hierarchy(the_path)
  while the_path && File.basename(the_path) != 'modules'
    the_path = File.dirname(the_path)
    path_xrequired = File.join(the_path,'xrequired')
    if File.exists?(path_xrequired)
      require_folder(path_xrequired)
      log("Dossier xrequired chargé : #{path_xrequired}")
    end
  end
end
