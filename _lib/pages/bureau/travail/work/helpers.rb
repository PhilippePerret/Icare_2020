# encoding: UTF-8
=begin
  Méthodes d'helper pour construire le travail de l'étape et toutes ses
  sections, minifaq et quai des docs compris
=end
class AbsEtape

  def owner
    @owner ||= user
  end #/ owner
  def owner= u
    @owner = u
  end #/ owner=

  # ---------------------------------------------------------------------
  #   TROIS SECTIONS PRINCIPALES

  def section_etape_work
    deserb('work', self)
  end #/ section_etape_work

  def section_etape_mini_faq
    deserb('minifaq', self)
  end #/ section_etape_mini_faq

  def section_etape_qdd
    deserb('qdd', self)
  end #/ section_etape_qdd

  # ---------------------------------------------------------------------
  #   SECTIONS DE LA PARTIE TRAVAIL

  def objectifs_formated
    objectifs.collect do |obj|
      Tag.li({text:obj, class:'bold'})
    end.join
  end #/ section_etape_objectifs

  def travail_formated
    deserb_or_markdown(travail, self)
  end #/ section_etape_travail

  def travail_propre_formated
    if !user.admin? && user.icetape.travail_propre
      travail = deserb_or_markdown(user.icetape.travail_propre, self)
      <<-HTML
<fieldset class="noborder">
  <legend>TRAVAIL PROPRE</legend>
  #{travail}
</fieldset>
      HTML
    else
      # On n'affiche rien, s'il n'y a pas de travail propre
    end
  end #/ section_etape_travail_propre

  def etape_liens
    if has_liens?
      safe(instances_liens.collect { |lien| lien.out }.join)
    else
      Tag.div(text:'Aucun lien utile pour cette étape.'.freeze, class:'italic small'.freeze)
    end
  end #/ section_etape_liens

  def methode_formated
    unless methode.nil?
      deserb_or_markdown(methode, self)
    else
      Tag.div(text:'Aucun élément de méthode pour cette étape.'.freeze, class:'italic small'.freeze)
    end
  end #/ section_methode_formated

  # ---------------------------------------------------------------------
  #   MÉTHODE DE LA PARTIE MINIFAQ
  # ---------------------------------------------------------------------
  def formulaire_minifaq
    MiniFaq.form(:absetape, id)
  end #/ formulaire_minifaq

  def liste_reponses_minifaq
    MiniFaq.block_reponses(:absetape, id)
  end #/ liste_reponses_minifaq

  # ---------------------------------------------------------------------
  #   QUAI DES DOCS
  # ---------------------------------------------------------------------

  # Retourne la liste complète des documents, formatée
  def nombre_documents_qdd_et_lien
    # La logique pour récupérer le nombre :
    # Il faut trouver le nombre d'icetapes qui ont pour étapes absolues absetape_id
    # Et récolter tous les documents de ces étapes
    request = <<-SQL.freeze
SELECT COUNT(id)
  FROM icetapes ice
  INNER JOIN absetapes abe ON abe.id = ice.absetape_id
  INNER JOIN icdocuments doc ON doc.icetape_id = abe.id
  WHERE
    ice.absetape_id = #{id}
    SQL
    # -- AND doc.options LIKE '2%' OR doc.options LIKE '_________2%'
    # Ajouter la ligne ci-dessus si on veut exclure les documents
    # non partagés (mais normalement, lorsque l'on est sur une étape, on peut
    # voir tous les documents, même les documents non partagés, à partir du
    # moment où ils sont sur le QdD).
    nombre = db_exec(request)
    if nombre.nil?
      Tag.div(text:"Il n'y a aucun document partagé pour cette étape.", class:'small italic')
    else
      nombre = nombre[0][:"COUNT(id)"]
      s = nombre > 1 ? 's' : ''
      Tag.div(text:"Les icarien·ne·s ont déjà produit et partagé <strong>#{nombre} document#{s} pour cette étape</strong>.<div class=\"center\"><a href=\"qdd/list?aet=#{id}\" class=\"btn\">Voir/lire les documents</a></div>")
    end
  end #/ liste_documents_qdd

  # Retourne l'avertissement donné pour un icarien à l'essai, qui ne
  # peut télécharger que 5 documents
  def avertissement_non_vrai_icarien
    return '' if owner.real?

  end #/ avertissement_non_vrai_icarien

  private

    # Return TRUE si l'étape possède des liens, soit par l'étape absolue,
    # soit par les travaux types
    def has_liens?
      instances_liens.count > 0
    end #/ has_liens?

    # Liste de tous les liens.
    # @return
    #   Une liste d'instances {LienEtape}
    # Noter qu'il ne faut pas confondre, ici, la propriété :liens de l''étape
    # absolue et cette propriété (qui rassemble tous les liens, même ceux des
    # travaux type)
    def instances_liens
      @instances_liens ||= begin
        lks = safe(liens||'').split(RC)
        travaux_type.each{|wt| lks += wt.liens.split(RC) unless wt.liens.nil?}
        lks.collect { |dlien| LienEtape.new(dlien) }
      end
    end #/ instances_liens
end #/IcEtape

LienEtape = Struct.new(:dataline) do
  attr_reader :page_id, :target
  def parse_line
    @page_id, @target, @titre = dataline.split('::')
    @page_id = @page_id.to_i
  end #/ parse_line

  # Sortie pour affichage
  def out
    parse_line
    lk = Tag.lien(titre:titre, route:"http://www.scenariopole.fr/narration/#{cible}/#{page_id}".freeze, new: true)
    Tag.li(lk)
  end #/ out

  def titre
    @titre ||= begin
      # Si le titre n'est pas donné, il faut le chercher dans la collection
      # narration
      MyDB.DBNAME = 'scenariopole_cnarration'
      dpage = db_get('narration', {id: page_id}, columns:['titre'])
      MyDB.DBNAME = 'icare'
      tit = dpage[:titre]
      case target
      when 'page','livre','narration'
        tit << " <span class='small'>(collection Narration)</span>"
      end
    end
  end #/ titre

  def cible
    @cible ||= begin
      case target
      when 'livre'
        'livre'
      when 'narration', 'page', 'collection'
        'page'
      else
        raise "Cible inconnue : #{target}"
      end
    end
  end #/ cible
end
