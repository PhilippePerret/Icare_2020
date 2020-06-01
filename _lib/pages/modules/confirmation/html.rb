# encoding: UTF-8
class HTML
  attr_reader :absmodule
  def titre
    "#{RETOUR_MODULES}🗣️ Confirmation de commande".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    require_modules(['watchers', 'absmodules'])
    @absmodule = AbsModule.get(param(:mid))
    user.watchers.add(:commande_module, {objet_id: absmodule.id})
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
