# encoding: UTF-8
# frozen_string_literal: true
feature "Destruction d'un participant au concours" do
  before(:all) do
    require_support('concours')
    TConcours.reset
    TConcours.peuple
    @concurrent = TConcurrent.get_random
  end
  let(:concurrent) { @concurrent }
  context 'Une participant inscrit' do
    scenario 'peut détruire son inscription facilement' do
      pitch("Le concurrent rejoint l'accueil du concours, s'identifie et rejoint son espace. Là, il trouve un bouton pour se détruire et l'active. Cela détruit son inscription.")
      goto("concours/accueil")
      click_on("Identifiez-vous")
      expect(page).to have_titre("Identification au concours") # juste pour être sûr
      within("form#concours-signedup-form") do
        fill_in("p_mail", with: concurrent.mail)
        fill_in("p_concurrent_id", with:concurrent.id)
        click_on(UI_TEXTS[:concours_bouton_sidentifier])
      end
      expect(page).to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_css("form#destroy-form")
      within("form#destroy-form") do
        fill_in("p_num", with: concurrent.id)
        sleep 10
        click_on(UI_TEXTS[:concours_button_destroy])
      end
      sleep 10

      # *** Vérifications ***

    end
  end


end
