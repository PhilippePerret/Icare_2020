# encoding: UTF-8
=begin
  Validation d'un user
=end
require_module('absmodules')
class Watcher < ContainerClass
  def signup
    raise "Je dois valider l'inscription"
  end #/ signup

  def contre_signup
    raise "Je dois refuer l'inscription"
  end #/ contre_signup

  # Retourne TRUE si le module +absmodule+ {AbsModule} est choisi par l'user
  def selected_module?(absmodule)
    params[:modules].include?(absmodule.id)
  end #/ selected_module?
end #/Watcher < ContainerClass
