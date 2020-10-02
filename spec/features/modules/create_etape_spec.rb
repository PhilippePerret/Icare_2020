# encoding: UTF-8
=begin
  Test de la création d'une étape de module
=end
UI_TEXTS.merge!({
  titre_page_edit_etape: 'Étapes des modules'.freeze,
  titre_edition_etape: 'Édition d’étape'.freeze,
})
feature "Création d'une étape de module" do
  before(:all) do
    # IL faut commencer par faire une sauvegarde des données actuelles
    # pour pouvoir les remettre
    # Non, inutile, puisqu'elles sont déjà consignées dans xbackups goods
    File.exists?("/Users/philippeperret/Sites/AlwaysData/xbackups/Goods_for_2020/absetapes.sql") || raise("Je ne trouve pas le backup des données absolues bonnes. Je préfère ne pas lancer ce test.")
  end

  after(:all) do
    # Remettre les données absolues des modules
    `mysql -u root icare_test < "/Users/philippeperret/Sites/AlwaysData/xbackups/Goods_for_2020/absetapes.sql"`
  end
  scenario "Un simple visiteur ne peut pas créer une étape de module" do
    goto("admin/modules")
    expect(page).not_to have_titre(UI_TEXTS[:titre_page_edit_etape])
  end


  scenario 'Un icarien ne peut pas créer une étape de module' do
    degel('demarrage_module')
    marion.rejoint_son_bureau
    goto("admin/modules")
    expect(page).not_to have_titre(UI_TEXTS[:titre_page_edit_etape])
  end





  scenario 'Un administrateur peut créer une étape de module' do
    pitch('Phil va rejoindre son tableau de bord pour créer une nouvelle étape de travail.')
    phil.rejoint_son_bureau
    expect(page).to have_css('a[href="admin/modules"]', text: 'Modules')
    click_on('Modules')
    expect(page).to have_titre(UI_TEXTS[:titre_page_edit_etape])
    expect(page).not_to have_css('a', text:'Nouvelle étape')
    pitch('Il n’y a pas encore de bouton “Nouvelle étape”')
    expect(page).to have_css('select#absmodules_list[name="absmodule_id"]')
    pitch('Il trouve le menu des modules et choisit le module Découverte')
    select('Découverte', from: 'absmodules_list')
    expect(page).to have_css('a[href="admin/modules?op=create-etape&mid=13"]', text:'Nouvelle étape')
    pitch("Phil trouve le bouton 'Nouvelle étape' et le clique")
    click_on('Nouvelle étape')
    # --- On se trouve dans la page d'édition ---
    expect(page).to have_titre(UI_TEXTS[:titre_edition_etape])
    expect(page).not_to have_css('input[type="text"][name="etape_id"]'),
      "La page ne devrait pas avoir le champ visible pour l'identifiant"
    data_new_etape = {
      numero: '951', titre: "Titre nouvelle étape #{Time.now}",
      objectif: "Tester la création d'une nouvelle étape de travail",
      duree: 10, duree_max: 20,
      travail: "Le travail pour le moment",
      methode: "Un simple élément de méthode",
      liens: "18::narration::Une page qui existe peut-être"
    }
    within('form#form-edit-etape') do
      fill_in('etape_numero', with: data_new_etape[:numero])
      fill_in('etape_titre',  with: data_new_etape[:titre])
      fill_in('etape_objectif',  with: data_new_etape[:objectif])
      fill_in('etape_duree',  with: data_new_etape[:duree])
      fill_in('etape_duree_max',  with: data_new_etape[:duree_max])
      fill_in('etape_travail',  with: data_new_etape[:travail])
      fill_in('etape_methode',  with: data_new_etape[:methode])
      fill_in('etape_liens',  with: data_new_etape[:liens])
    end
    click_on('Enregistrer')
    screenshot('phil-remplit-champs-new-etape-et-soumet')
    pitch("Phil a renseigné le formulaire et cliqué le bouton “Enregistrer”")

    expect(page).to have_css('input[type="text"][name="etape_id"]'),
      "La page devrait avoir le champ visible avec le nouvel identifiant"

    # La donnée est enregistrée, le champ 'etape_id' doit être renseigné
    new_id = page.find('input[name="etape_id"]')['value'].to_i
    expect(new_id).to be > 0,
      "Le nouvelle identifiant ne devrait pas être égal à 0…"
    # On prend la nouvelle étape dans la base de données pour la checker
    dnew_etape = db_get('absetapes', new_id)
    # On vérifie les nouvelles données
    data_new_etape.each do |k, v|
      errmsg = safe("La propriété #{k.inspect} devrait valoir “#{v.to_s}”, elle vaut “#{safe(dnew_etape[k].to_s)}”…")
      expect(dnew_etape[k].to_s).to eq(v.to_s), errmsg

    end
    pitch("Les données enregistrées de l'étape sont correctes.")

    expect(page).to have_css('button', text: 'Voir l’étape'),
      "La page devrait avoir un bouton pour voir tout de suite l’étape."
    pitch("Phil clique sur le bouton Voir l’étape pour la visualiser.")
    click_on('Voir l’étape')
    # Pour passer à l'onglet suivant
    page.driver.browser.switch_to.window page.driver.browser.window_handles.last
    screenshot('phil-visualise-new-etape')
    expect(page).to have_titre('Visualisateur d’étape')
    expect(page).to have_content(data_new_etape[:titre])
    expect(page).to have_content(data_new_etape[:objectif])
    expect(page).to have_content(data_new_etape[:travail])
    pitch("… et il peut voir que tout est là.")
    logout

  end






  scenario 'Phil peut éditer une étape existante' do
    pitch('Phil va rejoindre son tableau de bord pour modifier une étape existante.')
    phil.rejoint_son_bureau
    expect(page).to have_css('a[href="admin/modules"]', text: 'Modules')
    click_on('Modules')
    expect(page).to have_titre(UI_TEXTS[:titre_page_edit_etape])
    pitch('Il choisit le module Découverte')
    select('Découverte', from: 'absmodules_list')
    expect(page).to have_css('p', text: '1. Introduction au module découverte')
    page.find('p', text:'1. Introduction au module découverte').click
    expect(page).to have_css('a[href="admin/modules?op=edit-etape&eid=198"]', text: 'Éditer')
    within('div#content-etape-198') do
      click_on('Éditer', match: :first)
    end
    # Pour passer à l'onglet suivant
    page.driver.browser.switch_to.window page.driver.browser.window_handles.last
    screenshot("phil-veut-modifier-etape")
    # --- On se trouve dans la page d'édition ---
    expect(page).to have_titre(UI_TEXTS[:titre_edition_etape])
    expect(page).to have_css('input[type="text"][name="etape_id"][value="198"]'),
      "La page devrait avoir le champ visible pour l'identifiant"
    pitch("Phil trouve le formulaire d'édition rempli. Il modifie la durée de l'étape et son titre en s'assurant qu'ils sont différents des précédents.")

    new_titre = "La découvre à #{Time.now}"
    new_duree = 50
    detape = db_get('absetapes', 198)
    expect(detape[:titre]).not_to eq(new_titre)
    expect(detape[:duree]).not_to eq(new_duree)

    # Modification dans le formulaire et soumission
    within('form#form-edit-etape') do
      fill_in('etape_titre', with: new_titre)
      fill_in('etape_duree', with: new_duree)
    end
    click_on 'Enregistrer'

    # On vérifie que ce soit bien enregistré
    detape = db_get('absetapes', 198)
    expect(detape[:titre]).to eq(new_titre)
    expect(detape[:duree]).to eq(new_duree)
    pitch("Les nouvelles données de l'étape ont bien été enregistrées")
    logout

  end

end
