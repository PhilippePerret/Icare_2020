# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthodes d'expectation générales, utilisables pour toutes les phases

  Dans le before :all (ou :each), on définit la personne qui visite par
  @member ou @concurrent et ensuite on met le nom des méthodes dans des it :

  context 'qui ?'
    le_nom_de_la_methode
  end

  Par exemple :

  before :all do
    @concurrent = TConcurrent.get_random(current: true)
  end

  context 'un concurrent courant identifié'
    before :each do
      @concurrent.rejoint_le_concours
    end
    peut_rejoindre_son_espace_personnel
  end

=end

def visitor ; @visitor end
def member ; @member end
def concurrent ; @concurrent end
def annee ; ANNEE_CONCOURS_COURANTE end

# Méthode à appeler avant les tests où il faut que le visiteur soit
# identifié.
def try_identify_visitor
  if visitor.is_a?(TConcurrent)
    visitor.rejoint_le_concours
  elsif visitor.is_a?(TEvaluator)
    visitor.rejoint_le_concours
  end
end #/ try_identify_visitor
