# encoding: UTF-8
=begin
  Méthodes d'helper pour construire le travail de l'étape et toutes ses
  sections, minifaq et quai des docs compris
=end
class IcEtape

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
    absetape.objectifs.collect do |obj|
      Tag.li({text:obj, class:'bold'})
    end.join
  end #/ section_etape_objectifs

  def travail_formated
    w = absetape.travail.gsub(AbsEtape::REG_TRAVAIL_TYPE){
      rubrique, fichier = $1.strip.gsub(/[ ']/,'').split(',')
      wtype = TravailType.get(rubrique, fichier)
      wtype.travail
    }
    ERB.new(safe(w)).result()
  end #/ section_etape_travail

  def travail_propre_formated
    if travail_propre
      ERB.new(safe(travail_propre)).result()
    else
      Tag.div(text:"Aucun travail propre pour cette étape", class:'italic small')
    end
  end #/ section_etape_travail_propre

  def etape_liens
    if has_liens?
      liens.collect { |lien| lien.out }.join.force_encoding(Encoding::UTF_8)
    else
      Tag.div(text:'Aucun lien utile pour cette étape.'.freeze, class:'italic small'.freeze)
    end
  end #/ section_etape_liens

  def etape_methode
    if absetape.methode
      ERB.new(absetape.methode).result()
    else
      Tag.div(text:'Aucun élément de méthode pour cette étape.'.freeze, class:'italic small'.freeze)
    end
  end #/ section_etape_methode

  # ---------------------------------------------------------------------
  #   MÉTHODE DE LA PARTIE MINIFAQ
  # ---------------------------------------------------------------------
  def formulaire_minifaq
    require_module('form')
    form = Form.new(id:'form-minifaq', route:'bureau/travail', libelle_size:100, class:'noborder nomargin')
    form.rows = {
      'ope-minifaq' => {name:'ope', type:'hidden', value: 'minifaq-add-question'},
      'Question'    => {name:'minifaq_question', type:'textarea', height:160, class:'w100pct'}
    }
    form.submit_button = "Poser cette question"
    form.out
  end #/ formulaire_minifaq

  def liste_reponses_minifaq
    # request = "SELECT * FROM mini_faq WHERE absetape_id = #{absetape_id}"
    request = "SELECT * FROM mini_faq WHERE absetape_id = 2".freeze
    reponses = db_exec(request)
    if MyDB.error
      log(MyDB.error)
      return erreur("Une erreur SQL est survenue. Consulter le journal de bord")
    end
    if reponses.empty?
      Tag.div(text:'Aucune question pour cette étape.'.freeze, class:'italic small'.freeze)
    else
      log("réponses minifaq: #{reponses.inspect}")
      reponses.collect do |dreponse|
        reponse = ReponseMinifaq.new(dreponse) # cf. en bas de ce module
        reponse.out
      end.join
    end
  end #/ liste_reponses_minifaq

  # ---------------------------------------------------------------------
  #   QUAI DES DOCS
  # ---------------------------------------------------------------------

  # Retourne la liste complète des documents, formatée
  def nombre_documents_qdd_et_lien
    # La logique pour récupérer le nombre :
    # Il faut trouver le nombre d'icetapes qui ont pour étapes absolues absetape_id
    # Et récolter tous les documents de ces étapes
    request = <<-SQL
SELECT COUNT(id)
  FROM icetapes ice
  INNER JOIN absetapes abe ON abe.id = ice.absetape_id
  INNER JOIN icdocuments doc ON doc.icetape_id = abe.id
  WHERE
    ice.absetape_id = #{absetape_id}
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
      Tag.div(text:"Les icarien·ne·s ont déjà produit et partagé <strong>#{nombre} document#{s} pour cette étape</strong>.<div class=\"center\"><a href=\"qdd/list?aet=#{absetape_id}\" class=\"btn\">Voir/lire les documents</a></div>")
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
      liens.count > 0
    end #/ has_liens?

    # Liste de tous les liens.
    # @return
    #   Une liste d'instances {LienEtape}
    # Noter qu'il ne faut pas confondre, ici, la propriété :liens de l''étape
    # absolue et cette propriété (qui rassemble tous les liens, même ceux des
    # travaux type)
    def liens
      @liens ||= begin
        lks = (absetape.liens||'').force_encoding('utf-8').split(RC)
        absetape.travaux_type.each{|wt| lks += wt.liens.split(RC) }
        lks.collect { |dlien| LienEtape.new(dlien) }
      end
    end #/ liens
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

class ReponseMinifaq
  def initialize data
    data.each { |k,v| self.instance_variable_set("@#{k}", v)}
  end #/ initialize
  def out
    <<-HTML
<div class="minifaq-qr">
  <div class="minifaq-question">
    <span class="fright">#{@pseudo}</span>
    #{@question}
  </div>
  <div class="minifaq-reponse">
    #{@reponse}
  </div>
</div>
    HTML
  end #/ out
end #/ReponseMinifaq
