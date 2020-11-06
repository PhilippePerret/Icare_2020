# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de l'historique de l'icarien.

  Je ne le teste pas en détail, je veille juste à ce qu'il ne soit
  atteignable que par ceux qui peuvent en fonction des différents réglages.

=end
require_relative './_required'
require "#{FOLD_REL_PAGES}/overview/icariens/lib/constants"

class TUser

  def has_lien_histo?
    page.has_css?(selector_histo, text: UI_TEXTS[:btn_voir_historique])
  end #/ has_lien_histo?

  def selector_histo
    @selector_histo ||= "div#icarien-#{id} div.tools a[href=\"#{route_histo}\"]"
  end #/ selector_histo
  alias :lien_histo :selector_histo

  def route_histo
    @route_histo ||= "bureau/historique?uid=#{id}"
  end #/ route_histo

end #/TUser

class Capybara::Session
  def page_histo?
    ok = self.has_css?('h2.page-title', text: 'Historique de travail')
    ok = ok && self.has_css?('div.historique') # conforme à peu près
    return ok
  end #/ page_histo?

  def has_bouton_changer_partage?
    self.has_css?('p.presentation a[href="bureau/preferences"]')
  end #/ has_bouton_changer_partage?

end #/Capybara::Session

feature "Section Historique du bureau de l'icarien" do
  before(:all) do
    degel('marion-a-quitte-discussion-benoit')
    # On régle les préférences de chacun
    # Marion #10 partage tout,
    # Benoit #11 partage avec icarien,
    # Élie #12 ne partage avec personne
    [[10,9],[11,1],[12,0]].each do |uid, valbit|
      opts = db_exec("SELECT options FROM users WHERE id = #{uid}").first[:options]
      opts[21] = valbit.to_s
      begin
        db_exec("UPDATE users SET options = '#{opts}' WHERE id = #{uid}")
      rescue MyDBError => e
        raise e
      end
    end
  end

  before(:each) do
    Capybara.reset_sessions!
  end

  # === VISITEUR QUELCONQUE ===
  context 'avec un visiteur quelconque' do

    context 'et un icarien que ne partage son historique avec personne' do
      scenario 'alors aucun lien ne se trouve dans la salle des icariens' do
        goto 'overview/icariens'
        screenshot('salle-icariens-sans-liens-histo')
        expect(elie).not_to have_lien_histo
      end
      scenario 'alors le visiteur ne peut pas l’atteindre par la route directe' do
        goto elie.route_histo
        expect(page).not_to be_page_histo
      end
    end

    context 'et un icarien qui ne partage son historique qu’avec les icariens' do
      scenario 'alors aucun lien ne se trouve dans la salle des icariens' do
        goto 'overview/icariens'
        screenshot('salle-icariens-sans-liens-histo')
        expect(benoit).not_to have_lien_histo
      end
      scenario 'alors le visiteur ne peut pas l’atteindre par la route directe' do
        goto benoit.route_histo
        expect(page).not_to be_page_histo
      end
    end #/context icarien partage icarien

    context 'et un icarien qui partage son historique avec le monde' do
      scenario "Un lien vers l'historique est affiché dans la salle des icariens" do
        goto('overview/icariens')
        screenshot('salle-icariens-avec-liens-histo')
        expect(marion).to have_lien_histo
      end
      scenario 'alors on peut atteindre l’historique par la salle des icariens' do
        goto('overview/icariens')
        page.find(marion.lien_histo).click
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
      end
      scenario 'il ne trouve pas de lien pour changer son partage' do
        goto marion.route_histo
        expect(page).to be_page_histo
        expect(page).not_to have_bouton_changer_partage
      end
      scenario 'alors on peut atteindre l’historique par la route directe' do
        goto marion.route_histo
        expect(page).to be_page_histo
      end
    end #/context icarien partage monde

  end #/context visiteur quelconque


  # === VISITEUR ICARIEN IDENTIFIÉ ===

  context 'avec un icarien identifié' do

    context 'et un icarien que ne partage son historique avec personne' do
      before(:each) do
        marion.rejoint_le_site
      end
      scenario 'alors aucun lien ne se trouve dans la salle des icariens' do
        goto 'overview/icariens'
        screenshot('salle-icariens-sans-liens-histo')
        expect(elie).not_to have_lien_histo
      end
      scenario 'alors le visiteur ne peut pas l’atteindre par la route directe' do
        goto elie.route_histo
        expect(page).not_to be_page_histo
      end
    end

    context 'et un icarien qui ne partage son historique qu’avec les icariens' do
      before(:each) do
        marion.rejoint_le_site
      end
      scenario 'alors un lien se trouve dans la salle des icariens' do
        goto 'overview/icariens'
        screenshot('salle-icariens-avec-liens-histo')
        expect(benoit).to have_lien_histo
      end
      scenario 'alors on peut atteindre l’historique par la salle des icariens' do
        goto('overview/icariens')
        page.find(benoit.lien_histo).click
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
        expect(page).not_to have_bouton_changer_partage
      end
      scenario 'il ne trouve pas de lien pour changer son partage' do
        goto benoit.route_histo
        expect(page).to be_page_histo
        expect(page).not_to have_bouton_changer_partage
      end
      scenario 'alors l’icarien peut atteindre l’historique par la route directe' do
        goto benoit.route_histo
        expect(page).to be_page_histo
      end
    end #/context icarien partage icarien

    context 'et un icarien qui partage son historique avec le monde' do
      before(:each) do
        benoit.rejoint_le_site
      end
      scenario "Un lien vers l'historique est affiché dans la salle des icariens" do
        goto('overview/icariens')
        screenshot('salle-icariens-avec-liens-histo')
        expect(marion).to have_lien_histo
      end
      scenario 'alors on peut atteindre l’historique par la salle des icariens' do
        goto('overview/icariens')
        page.find(marion.lien_histo).click
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
        expect(page).not_to have_bouton_changer_partage
      end
      scenario 'il ne trouve pas de lien pour changer son partage' do
        goto marion.route_histo
        expect(page).to be_page_histo
        expect(page).not_to have_bouton_changer_partage
      end
      scenario 'alors on peut atteindre l’historique par la route directe' do
        goto marion.route_histo
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
      end
    end #/context icarien partage monde

  end #/context visiteur icarien



  # === VISITEUR ADMINISTRATEUR ===

  context 'avec un administrateur' do
    before(:each) do
      phil.rejoint_le_site
    end

    context 'et un icarien que ne partage son historique avec personne' do
      scenario 'alors un lien se trouve dans la salle des icariens' do
        goto 'overview/icariens'
        screenshot('salle-icariens-avec-liens-histo')
        expect(elie).to have_lien_histo
      end
      scenario 'alors l’administrateur peut atteindre l’historique par la route directe' do
        goto elie.route_histo
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
      end
      scenario 'il ne trouve pas de lien pour changer le partage' do
        goto elie.route_histo
        expect(page).to be_page_histo
        expect(page).not_to have_bouton_changer_partage
      end
    end

    context 'et un icarien qui ne partage son historique qu’avec les icariens' do
      scenario 'alors un lien se trouve dans la salle des icariens' do
        goto 'overview/icariens'
        screenshot('salle-icariens-avec-liens-histo')
        expect(benoit).to have_lien_histo
      end
      scenario 'alors l’admin peut atteindre l’historique par la salle des icariens' do
        goto('overview/icariens')
        page.find(benoit.lien_histo).click
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
      end
      scenario 'alors l’admin peut atteindre l’historique par la route directe' do
        goto benoit.route_histo
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
      end
      scenario 'il ne trouve pas de lien pour changer le partage' do
        goto benoit.route_histo
        expect(page).to be_page_histo
        expect(page).not_to have_bouton_changer_partage
      end
    end #/context icarien partage icarien

    context 'et un icarien qui partage son historique avec le monde' do
      scenario "Un lien vers l'historique est affiché dans la salle des icariens" do
        goto('overview/icariens')
        screenshot('salle-icariens-avec-liens-histo')
        expect(marion).to have_lien_histo
      end
      scenario 'alors l’admin peut atteindre l’historique par la salle des icariens' do
        goto('overview/icariens')
        page.find(marion.lien_histo).click
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
      end
      scenario 'alors l’admin peut atteindre l’historique par la route directe' do
        goto marion.route_histo
        screenshot('page-histo-expected')
        expect(page).to be_page_histo
      end
      scenario 'il ne trouve pas de lien pour changer le partage' do
        goto marion.route_histo
        expect(page).to be_page_histo
        expect(page).not_to have_bouton_changer_partage
      end
    end #/context icarien partage monde

  end #/context visiteur administrateur


  # === PROPRIÉTAIRE DE L'HISTORIQUE ===

  context 'avec le propriétaire qui ne partage avec personne' do
    before(:each) do
      elie.rejoint_le_site
    end

    scenario 'il trouve un lien dans la salle des icariens' do
      goto 'overview/icariens'
      screenshot('salle-icariens-avec-liens-histo')
      expect(elie).to have_lien_histo
    end

    scenario 'il peut atteindre l’historique par la salle des icariens' do
      goto('overview/icariens')
      page.find(benoit.lien_histo).click
      expect(page).to be_page_histo
    end

    scenario 'il peut atteindre son historique par la route directe' do
      goto elie.route_histo
      expect(page).to be_page_histo
    end

    scenario 'il trouve un bouton pour changer son réglage' do
      goto elie.route_histo
      expect(page).to be_page_histo
      expect(page).to have_bouton_changer_partage
    end

  end #/context visiteur owner

end
