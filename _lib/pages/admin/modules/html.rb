# encoding: UTF-8
require_module('form')
require_module('absmodules')
class HTML

  # Le module d'apprentissage courant
  attr_reader :absmodule

  def titre
    "Étapes des modules".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    @absmodule = AbsModule.get(param(:absmodule_id)) unless param(:absmodule_id).nil?
    case param(:op)
    when 'show'
      # Rien à faire ici
    when 'edit-etape'
      message "Je dois éditer l'étape #{param(:eid)}"
    when 'save-etape'
      message "Je dois enregistrer l'étape #{param(:etape_id)}"
    end
  end
  # Fabrication du body
  def build_body
    @body = if param(:op) == 'edit-etape' || param(:op) == 'save-etape'
              deserb('absetape_form', AbsEtape.get(param(:eid)||param(:etape_id)))
            else
              deserb('body', self)
            end
  end

  # Retourne les OPTIONS pour le menu des modules
  def menus_absmodule
    tag = '<option value="%s"%s>%s</option>'
    AbsModule.collect do |absmod|
      selected = (absmodule && absmodule.id == absmod.id) ? ' SELECTED' : ''
      tag % [absmod.id, selected, absmod.name]
    end.unshift(tag % ['', '', 'Voir le module…']).join
  end #/ menus_absmodule

  # Retourne le code HTML pour une étape telle qu'elle s'affiche
  # pour l'icarien
  def work_of(absetape)
    deserb('./_lib/pages/bureau/travail/work/work.erb', absetape)
  end #/ work_of

  # Formulaire d'édition de l'étape +absetape+
  def bouton_edit_etape(absetape)
    <<-HTML
  <div class="buttons">
    <a href="#{route.to_s}?op=edit-etape&eid=#{absetape.id}" class="small btn">Éditer</a>
  </div>
    HTML
  end #/ bouton_edit_etape

end #/HTML
