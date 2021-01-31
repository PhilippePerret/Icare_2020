# encoding: UTF-8
# frozen_string_literal: true
=begin

  ============================================================================
  JOUER CE SCRIPT (CMD i) POUR ACTUALISER LA LISTE DES MÉTHODES TDD (IT-CASES)
  DANS LE FICHIER __all_it-cases__.html
  ============================================================================

  Script qui récupère tous les it-cases pour les documenter (une liste
  complète, avec description et lien vers la méthode)

  Pour qu'un it-case soit répertorié, il faut que sa définition ressemble à :

    def nom_de_la_methode
      # TEST: Description du test

    Où :
      Le nom_de_la_methode est constitué de telle sorte qu'on peut ajouter
      "un visiteur" devant pour obtenir une phrase. Par exemple, si la
      méthode est 'peut_rejoindre_le_concours', ça donnera la documentation
      pour le test "Un visiteur peut rejoindre le concours"

=end

class ItCase
class << self
  def add(itcase)
    @items ||= []
    @items << itcase
  end
  def last
    @items.last
  end
  def remove_last
    @items.pop
  end
  def build_documentation
    File.delete(path_documentation) if File.exists?(path_documentation)
    stream = File.open(path_documentation,'a')
    stream << '<h2>Liste des it-cases pour le test du concours</h2>'
    stream << header
    stream << "<dl>\n"
    @items.each do |item|
      stream << item.output
    end
    stream << "</dl>\n"
    stream << footer
    puts "La documentation a été établie (au-dessus de ce fichier)"
  ensure
    stream.close if stream
  end #/ build_documentation
  def header
    <<-HTML
<!DOCTYPE html>
<html lang='fr' dir='ltr'>
  <head>
    <meta charset='utf-8'>
    <title>Méthodes TDD Test concours</title>
#{CSS_CODE.gsub(/_LISTE_WIDTH_/, '680')}
#{JS_CODE}
  </head>
  <body>
    <div>Le visiteur testé…</div>
    <div id="boutons">
      <button id="btn-show-all" class="invisible" type="button" onclick="afficherTout()">Tout afficher</button>
      <br />
      <input type="text" id="searched" value="" style="width:300px;" placeholder="Mots à filtrer" />
      <button type="button" onclick="search()">Filtrer</button>
    </div>
    <div id="method_list">

    HTML
  end #/ header
  def footer
    @footer ||= <<-HTML
</div>
<em>Pour actualiser cette liste, lancer le script '#{__FILE__}' et recharger cette page</em>
</body>
</html>
    HTML
  end

  def path_documentation
    @path_documentation ||= File.join(THIS_FOLDER,'__all_it-cases__.html')
  end

end # /<< self


attr_reader :data
attr_accessor :description # pour la définir après
def initialize(data)
  @data = data
  self.class.add(self)
end #/ initialize
def output
  <<-TEXT
<dt onclick="toggleMethod(this)">#{phrase}</dt><!-- rien ! --><dd class="hidden">
  <div class="description">#{description}</div>
  <div class='method'>#{method_linked}</div>
</dd>
  TEXT
end #/ output
def method; @method ||= data[:method] end
def phrase; @phrase ||= data[:phrase] end
def file  ; @file   ||= data[:file]   end
def line  ; @line   ||= data[:line]   end
def method_linked
  @method_linked ||= begin
    "<a href='atm://open?url=file://#{file}:#{line}'>#{method}</a>"
  end
end

end #/ItCase


THIS_FOLDER = __dir__
Dir["#{THIS_FOLDER}/**/*.rb"].each do |fpath|
  next if fpath == __FILE__
  next_is_description = false
  File.readlines(fpath).each_with_index do |line, idx|
    line = line.force_encoding('utf-8')
    if line.start_with?('def ')
      next if line.match(';')
      method_name = line[4..-1].strip
      phrase_test = "… #{method_name.gsub(/_/,' ')}"
      ItCase.new(method: method_name, phrase:phrase_test, line:idx, file:fpath)
      next_is_description = true
    elsif next_is_description
      if line.strip.start_with?('# ')
        com = line.strip[2..-1]
        if com == 'doc:out'
          ItCase.remove_last
        else
          ItCase.last.description = com
        end
      end
      next_is_description = false
    end
  end
end


JS_CODE = <<-JAVASCRIPT
<script type='text/javascript'>
function toggleMethod(titre){
  const o = titre.nextSibling.nextSibling
  const ouvrir = o.classList.contains('hidden')
  o.classList[ouvrir?'remove':'add']('hidden')
}
function search(){
  const searched = []
  DGet('#searched').value.split(' ').forEach(str => {
    searched.push(new RegExp(`${str}`))
  })
  var outers = 0
  DGet('#method_list').querySelectorAll('dt').forEach(dt => {
    const isOk = containsSearch(dt.innerText, searched)
    dt.classList[isOk?'remove':'add']('hidden')
    isOk || ++outers
  })
  outers && DGet('#btn-show-all').classList.remove('invisible')
}
function afficherTout(){
  DGet('#method_list').querySelectorAll('dt').forEach(dt => dt.classList.remove('hidden'))
  DGet('#btn-show-all').classList.add('invisible')
}
function containsSearch(str, expected){
  for(var i = 0, len = expected.length; i < len; ++i){
    if ( ! str.match(expected[i]) ){
      console.log("Le texte '%s' ne contient pas '%s'", str, expected[i])
      return false
    }
  }
  return true
}
function DGet(selector){return document.querySelector(selector)}
</script>

JAVASCRIPT

CSS_CODE = <<-CSS
<style media="screen">
body {
  font-size:16pt;
  }
div#method_list {
  height:600px;font-size:0.9em;
  border:1px solid grey;
  overflow:auto;
  width: _LISTE_WIDTH_px;
}
dl {}
dl dt {font-family:Arial,Geneva, Helvetica;cursor:pointer;margin-top:0.3em;}
dl dd {font-size: 0.9em;}
.hidden {display:none;}
.invisible {visibility: hidden;}
div#boutons, div#boutons * {font-size:inherit;}
div#boutons {position:fixed;top: 100px;left: calc(_LISTE_WIDTH_px + 20px);padding: 0.5em 1em;}
</style>
CSS

ItCase.build_documentation
