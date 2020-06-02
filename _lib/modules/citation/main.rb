# encoding: UTF-8
=begin
  Class Citation
  --------------
  Gestion des citations
=end
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

def texte
  @texte ||= data['citation']
end #/ texte

def auteur
  @auteur ||= data['auteur']
end #/ auteur

end #/Citation
