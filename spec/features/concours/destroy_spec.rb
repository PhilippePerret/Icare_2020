# encoding: UTF-8
# frozen_string_literal: true
feature "Destruction d'un participant au concours" do
  before(:all) do
    @concurrent = TConcurrent.get_random
  end
  let(:concurrent) { @concurrent }

  context 'Une participant inscrit' do
    scenario 'peut détruire son inscription facilement' do
      pitch("Le concurrent #{concurrent.patronyme} rejoint l'accueil du concours, s'identifie et rejoint son espace. Là, il trouve un bouton pour se détruire et l'active. Cela détruit son inscription.")

      # *** Vérifications préliminaires ***
      expect(File).to be_exists(concurrent.folder),
        "Le dossier du concurrent devrait exister avec ses documents."

      goto("concours/accueil")
      click_on("Identifiez-vous")
      expect(page).to have_titre("Identification au concours") # juste pour être sûr
      within("form#concours-login-form") do
        fill_in("p_mail", with: concurrent.mail)
        fill_in("p_concurrent_id", with:concurrent.id)
        click_on(UI_TEXTS[:concours_bouton_sidentifier])
      end
      expect(page).to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_css("form#destroy-form")
      within("form#destroy-form") do
        fill_in("c_numero", with: concurrent.id)
        click_on(UI_TEXTS[:concours_button_destroy])
      end
      screenshot("destroy-inscription")

      # *** Vérifications ***
      nb = db_count(DBTBL_CONCURS_PER_CONCOURS, {concurrent_id: concurrent.id})
      expect(nb).to eq(0),
        "Il ne devrait plus y avoir de participations du concurrent dans '#{DBTBL_CONCURS_PER_CONCOURS}'…"
      d = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE concurrent_id = ?", [concurrent.id])
      expect(d).to be_empty
      expect(File).not_to be_exists(concurrent.folder),
        "Le dossier du concurrent ne devrait plus exister."



      pitch("Le concurrent ne peut plus s'identifier avec ses identifiants.")
      goto("concours/accueil")
      click_on("Identifiez-vous")
      expect(page).to have_titre("Identification au concours") # juste pour être sûr
      within("form#concours-login-form") do
        fill_in("p_mail", with: concurrent.mail)
        fill_in("p_concurrent_id", with:concurrent.id)
        click_on(UI_TEXTS[:concours_bouton_sidentifier])
      end
      expect(page).to have_titre("Identification au concours") # juste pour être sûr
      expect(page).to have_error("Désolé, je ne vous remets pas")


    end
  end


end
