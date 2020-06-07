# encoding: UTF-8
require_module('form')
require_module('user/modules')
class HTML
  def titre
    # Note : le titre est dynamique en fonction de la chose à envoyer
    "#{RETOUR_BUREAU}📡 #{MESSAGES["titre_#{param(:id)}".to_sym]}".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required

  end
  # Fabrication du body
  def build_body
    @body = deserb(param(:id), self)
  end
end #/HTML
