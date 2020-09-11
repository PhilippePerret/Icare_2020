# encoding: UTF-8
class HTML
  def titre
    "#{EMO_GYROPHARE.page_title}#{ISPACE}Aide de l’atelier".freeze
  end
  def exec
    # Code à exécuter avant la construction de la page
  end
  def build_body
    # Construction du body
    @body = aide_tdm
  end


  DIV_TITRE_AIDE = '<div class="titre">%{titre}</div>'.freeze
  DIV_ITEM_AIDE = '<div class="item"><a href="aide/fiche?aid=%{aid}">%{titre}</a></div>'.freeze
  def aide_tdm
    Aide::DATA_TDM.collect do |k, daide|
      is_titre = daide[:titre] === true
      div = is_titre ? DIV_TITRE_AIDE : DIV_ITEM_AIDE
      div % {aid:(daide[:id]||k), titre: daide[:hname]}
    end.join
  end #/ aide_tdm

end #/HTML
