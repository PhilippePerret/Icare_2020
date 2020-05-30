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
  spanLib = Tag.span(text:libelle,  class:'libelle')
  spanVal = Tag.span(text:value,    class:'value')
  Tag.div(text:(spanLib + spanVal), class:'row-flex')
end #/ divRow
