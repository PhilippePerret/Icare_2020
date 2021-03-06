# encoding: UTF-8
# frozen_string_literal: true
require_modules(['form', 'absmodules','scenariopole'])
class HTML

  # Le module d'apprentissage courant
  attr_reader :absmodule

  def titre
    tit = case param(:op)
          when NilClass, 'show'
            "Étapes des modules"
          when 'edit-etape', 'create-etape', 'save-etape'
            "Édition d’étape"
          when 'show-etape'
            "Visualisateur d’étape"
          else
            "OP inconnue à régler (#{param(:op)})"
          end
    # Le titre complet
    "#{RETOUR_MODULE unless param(:op).nil?}#{tit}"
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
    when 'save-new-etape'
      # Note : seulement quand on vient du formulaire de création de la
      # nouvelle étape
      AbsEtape.create_new
    when 'save-etape'
      AbsEtape.get(param(:etape_id)).check_and_save
    when 'show-etape'

    when 'edit-twork'
      # Édition du travail param(:twdos)/param(:tw)
    when 'save-twork'
      TravailType.get(param(:twork_id)).check_and_save
    when 'create-temoignage'
      # La dernière étape affiche toujours le formulaire de témoignage,
      # on passe ici si on l'essaie
      if ONLINE
        erreur "Sur le site distant, on ne peut pas enregistrer de témoignage de cette façon"
      else
        message "Sur le site local (et le site local seulement), on peut enregister un témoignage par l'édition des modules."
        require_module('temoignages')
      end
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
    when 'create-etape'
      ['absetape_form', AbsEtape.instantiate(AbsEtape::DEFAULT_DATA.merge(absmodule_id: param(:mid).to_i)), {formate:false}]
    when 'edit-etape', 'save-etape'
      ['absetape_form', AbsEtape.get(param(:eid)||param(:etape_id)), {formate:false}]
    when 'show-etape'
      ['absetape_show', AbsEtape.get(param(:eid)||param(:etape_id)), {formate:false}]
    when 'create-twork'
      ['travail_type_form', TravailType.instantiate(TravailType::DEFAULT_DATA)]
    when 'edit-twork',  'save-twork'
      ['travail_type_form', TravailType.get_by_name(param(:twdos), param(:tw))]
    else
      ['body', self]
    end
  end #/ partiel_per_op

  # Retourne le code HTML pour une étape telle qu'elle s'affiche
  # pour l'icarien
  #
  # [1] Ici, on ne fait pas le formatage spécial (special_formating) parce
  #     qu'il sera exécuté plus tard avec l'évalution de la page complète.
  def work_of(absetape)
    deserb("#{FOLD_REL_PAGES}/bureau/travail/work/work.erb", absetape, {formate:false}) # [1]
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

  def menu_films
    @menu_films ||= begin
      films_options = Scenariopole.db_exec("SELECT id AS value, titre FROM filmodico ORDER BY titre").collect do |dfilm|
        dfilm[:titre] = safe(dfilm[:titre])
        TAG_OPTION % dfilm.merge(selected:EMPTY_STRING)
      end.join
      TAG_SELECT_SIMPLE % {id:'films-filmodico', name:'film_id', class:'filmodico', options:'<option>Choisir le film…</option>'+films_options}
    end
  end #/ menu_films

  def menu_mots
    @menu_mots ||= begin
      mots_options = Scenariopole.db_exec("SELECT id AS value, mot AS titre FROM scenodico ORDER BY mot").collect do |dmot|
        dmot[:titre] = safe(dmot[:titre]).downcase
        TAG_OPTION % dmot.merge(selected:EMPTY_STRING)
      end.join
      TAG_SELECT_SIMPLE % {id:'mots-scenodico', name:'mot_id', class:'scenodico', options:'<option>Choisir le mot…</option>'+mots_options}
    end
  end #/ menu_mots


end #/HTML
