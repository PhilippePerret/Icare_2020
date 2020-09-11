# encoding: UTF-8
require_module('form')
class HTML
  attr_reader :absmodule

  def titre
    "#{RETOUR_MODULES+Emoji.get('objets/notebook').page_title+ISPACE}#{UI_TEXTS[:titre_commande_module]}".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    require_module('absmodules')
    @absmodule = AbsModule.get(param(:mid))
  end
  # Fabrication du body
  def build_body
    affixe =  case user.statut
              when :guest then 'nobody'.freeze
              when :actif, :en_pause then 'icarien_actif'.freeze
              else UI_TEXTS[:icarien]
              end
    @body = deserb("body_#{affixe}".freeze, self)
  end
end #/HTML
