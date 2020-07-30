# encoding: UTF-8
=begin
  Test de l'ajout d'une actualité
=end
feature "Operation Arrêt d'un module d'apprentissage (forcé ou non)" do
  before(:all) do
    require './_lib/pages/admin/tools/constants'
  end

  context 'Un visiteur quelconque' do
    scenario 'ne peut pas ajouter stopper de force un module d’apprentissage' do
      goto('admin/tools')
      expect(page).not_to have_titre('Outils')
      expect(page).to have_titre('Identification')
    end
  end


  context 'Un administrateur' do
    before(:all) do
      degel('define_sharing')
    end
    scenario 'peut rejoindre les outils depuis son bureau' do
      phil.rejoint_son_bureau
      click_on('OUTILS')
      expect(page).to have_titre('Outils')
    end

    scenario 'ne peut pas stopper un module d’apprentissage déjà arrêté' do
      pending
    end
    scenario 'peut stopper un module d’apprentissage', only:true do
      phil.rejoint_le_site # pour ne pas charger le bureau avec toutes ses images
      goto('admin/tools')
      expect(page).to have_titre('Outils')
      start_time = Time.now # c'est parti
      # On choisit l'icarien (statut puis icarien)
      phil.click('cb-statut-actif', within: '#div-statuts')
      select('Marion', from: 'icariens')
      select('Ajouter actualité', from: 'operations')
      expect(page).to have_css('textarea#long_value')
      expect(page).to have_css('input[type="text"]#medium_value')
      within('div#div-fields') do
        fill_in('long_value', with: 'Ceci est le texte de l’actualité'.freeze)
        fill_in('medium_value', with: 'SIMPLEMESS'.freeze)
        click_on(UI_TEXTS[:btn_execute_operation])
      end
      expect(page).to have_message('de type SIMPLEMESS ajoutée pour Marion')
      expect(page).to have_aucune_erreur()
      expect(TActualites).to have_actualite(after: start_time, type: 'SIMPLEMESS', user: marion)
    end
  end
end
