# encoding: UTF-8
=begin
  Validation d'un user
=end
require_module('absmodules')
class Watcher < ContainerClass
  def signup
    # Validation inscription
    owner.valide_inscription
  end #/ signup

  def download_signup
    download(signup_folder,nil,{keep:true})
  end #/ download_signup

  # Retourne TRUE si le module +absmodule+ {AbsModule} est choisi par l'user
  def selected_module?(absmodule)
    params[:modules].include?(absmodule.id)
  end #/ selected_module?

  def signup_folder
    @signup_folder ||= File.join(TEMP_FOLDER,'signups',params[:folder])
  end #/ signup_folder
end #/Watcher < ContainerClass
