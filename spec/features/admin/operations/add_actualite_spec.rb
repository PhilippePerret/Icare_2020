# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de l'ajout d'une actualité
=end
feature "Operation Ajout d'une actualité" do
  before(:all) do
    require "#{FOLD_REL_PAGES}/admin/tools/constants"
  end

  context 'Un visiteur quelconque' do
    scenario 'ne peut pas ajouter une actualité (par les outils administrateur)' do
      goto('admin/tools')
      expect(page).not_to have_titre('Outils')
      expect(page).to have_titre('Identification')
    end

    scenario 'ne peut pas forcer l’ajout d’une actualité (par URL)' do
      start_time = Time.now
      querystring = {"uid":"[\"1\",\"integer\"]","icarien":"[\"1\",\"string\"]","operation":"[\"add_actualite\",\"string\"]","long_value":"[\"C'est à voir ?\",\"string\"]","medium_value":"[\"SIMPLEMESS\",\"string\"]","short_value":"[\"\",\"string\"]","script":"[\"operation_icarien.rb\",\"string\"]"}
      querystring = querystring.collect{|k,vs| "#{k}=#{URI.encode(vs)}"}.join('&')
      goto('_lib/ajax/ajax.rb?'+querystring)
      screenshot('geek-force-actualite')
      expect(TActualites).not_to have_actualite(after: start_time, type: 'SIMPLEMESS', user_id: phil.id)
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
    scenario 'peut ajouter une actualité' do
      phil.rejoint_le_site # pour ne pas charger le bureau avec toutes ses images
      goto('admin/tools')
      expect(page).to have_titre('Outils')
      start_time = Time.now # c'est parti
      # On choisit l'icarien (statut puis icarien)
      phil.click('cb-statut-actif', within: '#div-statuts')
      select('Marionm', from: 'icariens')
      select('Ajouter actualité', from: 'operations')
      expect(page).to have_css('textarea#long_value')
      expect(page).to have_css('select#select_value')
      within('div#div-fields') do
        fill_in('long_value', with: 'Ceci est le texte de l’actualité')
        fill_in('select_value', with: 'SIMPLEMESS')
        click_on(UI_TEXTS[:btn_execute_operation])
      end
      expect(page).to have_message('de type SIMPLEMESS ajoutée pour Marion')
      expect(page).to have_aucune_erreur()
      expect(TActualites).to have_actualite(after: start_time, type: 'SIMPLEMESS', user: marion)
    end
  end
end
