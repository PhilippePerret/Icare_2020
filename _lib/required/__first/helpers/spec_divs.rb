# encoding: UTF-8
=begin
  Ce module contient des méthodes pratiques pour les codes helpers récurrents.
=end

# Pour construire un div "goto", comme on en trouve à l'accueil des sections
# en général, avec des blocs cliquables.
def divGoto(inner, options = {})
  css = ['goto']
  css << 'exergue' if options[:exergue]
  <<-HTML
<div class="#{css.join(' ')}">
  #{inner}
</div>
  HTML
end #/ divGoto

def divRow(libelle, value, options = {})
  DivRow.new(libelle,value,options).out
end #/ divRow

DivRow = Struct.new(:libelle, :value, :options) do
  def out
    Tag.div(text: spanLib + spanVal, class:'row-flex')
  end #/ out
  # Span pour le libellé
  def spanLib
    Tag.span(text:libelle,  class:'libelle'.freeze, style: styleLib)
  end #/ spanLib
  def styleLib
    sty = []
    if options.key?(:libelle_size)
      sty << "width:#{options[:libelle_size]}px"
    else
      sty << "flex:1"
    end
    return if sty.empty?
    sty.join(PV)
  end #/ styleLib
  # Span pour la valeur
  def spanVal
    Tag.span(text:value,    class:'value'.freeze, style: styleVal)
  end #/ spanVal
  def styleVal
    sty = []
    if options.key?(:libelle_size)
      sty << "width:#{options[:libelle_size]}px"
    else
      sty << "flex:2"
    end
    return if sty.empty?
    sty.join(PV)
  end #/ styleVal
end
