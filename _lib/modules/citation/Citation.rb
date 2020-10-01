# encoding: UTF-8
=begin
  Class Citation
  --------------
  Gestion des citations
=end
require_module('scenariopole')
class Citation
  class << self

    # Retourne une citation au hasard
    def rand
      data_citation = Scenariopole.get_citation(no_last_sent: OFFLINE)
      new(data_citation)
    end #/ rand
  end # /<< self

attr_reader :data
def initialize data
  @data = data
end #/ initialize

# Pour écrire la citation sur une page
#
# @usage        Citation.rand.out
def out
  <<-HTML
<div class="citation">
  <span class="content">« #{texte} »</span>
  <span> – </span><span class="auteur">#{auteur}</span>
  <div class="avertissement">(citation aléatoire)</div>
</div>
  HTML
end #/ out

def texte
  @texte ||= data['citation']
end #/ texte

def auteur
  @auteur ||= data['auteur']
end #/ auteur

end #/Citation
