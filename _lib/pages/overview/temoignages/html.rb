# encoding: UTF-8
require_module('temoignages')
class HTML
  def titre
    "#{DIV_AIR+Emoji.get('objets/journal').page_title+ISPACE}Témoignages d’icarien·ne·s#{DIV_AIR}".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    if param(:op) == 'plebisciter'
      icarien_required
      Temoignage.get(param(:temid)).plebiscite
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
