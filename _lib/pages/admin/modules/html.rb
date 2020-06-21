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
    when 'save-new-etape'
      # Note : seulement quand on vient du formulaire de création de la
      # nouvelle étape
      AbsEtape.create_new
    when 'save-etape'
      AbsEtape.get(param(:etape_id)).check_and_save
    when 'edit-twork'
      # Édition du travail param(:twdos)/param(:tw)
    when 'save-twork'
      TravailType.get(param(:twork_id)).check_and_save
    when 'create-temoignage'
      # La dernière étape affiche toujours le formulaire de témoignage,
      # on passe ici si on l'essaie
      if ONLINE
        erreur "Sur le site distant, on ne peut pas enregistrer de témoignage de cette façon".freeze
      else
        message "Sur le site local (et le site local seulement), on peut enregister un témoignage par l'édition des modules.".freeze
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

  def menu_films
    @menu_films ||= begin
      MyDB.DBNAME = 'scenariopole_biblio'
      films_options = db_exec("SELECT id AS value, titre FROM filmodico ORDER BY titre").collect do |dfilm|
        dfilm[:titre] = safe(dfilm[:titre])
        TAG_OPTION % dfilm.merge(selected:EMPTY_STRING)
      end.join
      MyDB.DBNAME = nil
      TAG_SELECT_SIMPLE % {id:'films-filmodico', name:'film_id', class:'filmodico', options:'<option>Choisir le film…</option>'+films_options}
    end
  end #/ menu_films

  def menu_mots
    @menu_mots ||= begin
      MyDB.DBNAME = 'scenariopole_biblio'
      mots_options = db_exec("SELECT id AS value, mot AS titre FROM scenodico ORDER BY mot").collect do |dmot|
        dmot[:titre] = safe(dmot[:titre]).downcase
        TAG_OPTION % dmot.merge(selected:EMPTY_STRING)
      end.join
      MyDB.DBNAME = nil
      TAG_SELECT_SIMPLE % {id:'mots-scenodico', name:'mot_id', class:'scenodico', options:'<option>Choisir le mot…</option>'+mots_options}
    end
  end #/ menu_mots


end #/HTML
