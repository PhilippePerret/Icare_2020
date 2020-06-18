# encoding: UTF-8
require_modules(['form', 'absmodules'])
class HTML

  # Le module d'apprentissage courant
  attr_reader :absmodule

  def titre
    "#{RETOUR_MODULE unless param(:op).nil?}Étapes des modules".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    case param(:op)
    when 'show'
      # Affichage des étapes du module choisi
      @absmodule = AbsModule.get(param(:absmodule_id)) unless param(:absmodule_id).nil?
    when 'edit-etape'
      # Édition de l'étape param(:eid)"
    when 'save-etape'
      AbsEtape.get(param(:etape_id)).check_and_save
    when 'edit-twork'
      # Édition du travail param(:twdos)/param(:tw)
    when 'save-twork'
      TravailType.get(param(:twork_id)).check_and_save
    end
  end
  # Fabrication du body
  def build_body
    add_css(File.join(PAGES_FOLDER,'bureau','xrequired','mef.css'))
    partiel, bindee, options = partiel_per_op
    @body = deserb("partiels/#{partiel}", bindee, options)
  end

  # Retourne le partiel, le bindee et les options de déserbage en
  # fonction de l'opération demandée qui, dans ce module peut avoir
  # de nombreuses valeurs.
  def partiel_per_op
    case param(:op)
    when 'edit-etape', 'save-etape'
      ['absetape_form', AbsEtape.get(param(:eid)||param(:etape_id)), {formate:false}]
    when 'edit-twork',  'save-twork'
      ['travail_type_form', TravailType.get_by_name(param(:twdos), param(:tw))]
    else
      ['body', self]
    end
  end #/ partiel_per_op

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
  #
  # [1] Ici, on ne fait pas le formatage spécial (special_formating) parce
  #     qu'il sera exécuté plus tard avec l'évalution de la page complète.
  def work_of(absetape)
    deserb('./_lib/pages/bureau/travail/work/work.erb', absetape, {formate:false}) # [1]
  end #/ work_of

  # Bouton, dans la liste des étapes du module, qui permet d'éditer
  # l'étape. L'édition se fait toujours dans un autre onglet
  def bouton_edit_etape(absetape)
    <<-HTML
  <div class="buttons">
    #{Tag.lien(route:"#{route.to_s}?op=edit-etape&eid=#{absetape.id}", class:'small btn', text:'Éditer', target:true)}
  </div>
    HTML
  end #/ bouton_edit_etape

  def toolbox(binder)
    deserb('partiels/toolbox', binder)
  end #/ toolbox

end #/HTML
