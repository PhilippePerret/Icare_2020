# encoding: UTF-8
=begin
  Classe Cronjob
  Diverses fonctions
=end
class Cronjob
class << self
  def require_folder(folder_path)
    Dir["#{folder_path}/**/*.rb"].each{|m|require m}
  end #/ require_folder

  def require_module(module_name)
    require_folder(File.join(MODULES_FOLDER,module_name))
  end #/ require_module

  def require_app_module(module_name)
    require_folder(File.join(APP_MODULES_FOLDER,module_name))
  end #/ require_app_module
end # /<< self
end #/Cronjob
