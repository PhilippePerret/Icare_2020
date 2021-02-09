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
  # doc:out
  if visitor.is_a?(TConcurrent)
    visitor.identify
  elsif visitor.is_a?(TEvaluator)
    visitor.rejoint_le_concours
  end
  expect(page).not_to be_page_erreur
end #/ try_identify_visitor

# Quand on a changé un attribut du visiteur (par exemple ses options, ses
# préférences) on peut avoir besoin de le reconnecter.
def reconnecte_visitor
  # doc:out
  visitor.logout
  Capybara.reset_sessions!
  try_identify_visitor
end #/

def peut_rejoindre_le_concours
  # S'assure qu'un visiteur quelconque peut rejoindre l'accueil du concours par les différents moyens offerts : l'encart suivant la phase, le plan ou les formulaires d'identification ou d'inscription.
  scenario "trouve des liens pour rejoindre le concours" do
    phase = TConcours.current.phase || 0
    expect(page).not_to be_page_erreur
    if phase > 0 && phase < 6
      # Lien par l'encard d'annonce
      ['/','user/login','user/signup', 'plan'].each do |endroit|
        goto(endroit)
        expect(page).not_to be_page_erreur
        expect(page).to have_encart_concours
      end
    end
    # Lien sur le plan
    goto("plan")
    expect(page).not_to be_page_erreur
    expect(page).to have_css('a[href="concours"].goto')
  end
end #/ peut_rejoindre_le_concours
