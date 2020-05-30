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
    ERB.new(w).result()
  end #/ section_etape_travail

  def travail_propre_formated
    if travail_propre
      ERB.new(travail_propre).result()
    else
      Tag.div(text:"Aucun travail propre pour cette étape", class:'italic small')
    end
  end #/ section_etape_travail_propre

  def etape_liens
    if has_liens?
      liens.collect { |lien| lien.out }.join
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
      when 'narration', 'page'
        'page'
      else
        raise "Cible inconnue : #{target}"
      end
    end
  end #/ cible
end
