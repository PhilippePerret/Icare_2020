# encoding: UTF-8
require_module('user/modules')
class Watcher < ContainerClass

  # Pour les mails et messages
  attr_reader :new_icetape, :new_numero, :new_titre

  # Exécution du watcher
  # On procède au changement d'étape de l'icarien
  def change
    newetape_id = param(:force_etape_id).nil_if_empty || param(:absetape_id)
    @new_icetape = IcEtape.create_for(owner.icmodule, {absetape_id: newetape_id})
    @new_numero = new_icetape.numero
    @new_titre  = new_icetape.titre
    owner.icmodule.set(icetape_id: new_icetape.id)
    message("#{owner.pseudo} passé#{owner.fem(:e)} avec succès à l’#{new_icetape.ref}.")
  end # / change

  # Produire le menu des étapes
  # Note : on peut le faire ici car c'est seulement ici qu'on
  # devrait en avoir besoin
  def menu_etapes
    owner_etape_id = owner.icetape.absetape_id
    next_is_selected = false
    options = []
    owner.icmodule.absmodule.etapes.each do |etape|
      options << TAG_OPTION % {value:etape.id, titre:"#{etape.numero}. #{etape.titre}", selected:(next_is_selected ? ' SELECTED' : '')}
      next_is_selected = etape.id == owner_etape_id
    end
    TAG_SELECT % {
      id: "absetapes-watcher-#{id}",
      name: "absetape_id",
      prefix: "watcher-#{id}", class: '', style:'',
      options: options.join.freeze
    }
  end #/ menu_etapes
end # /Watcher < ContainerClass
