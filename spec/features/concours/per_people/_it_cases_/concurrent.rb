# encoding: UTF-8
# frozen_string_literal: true

def peut_detruire_son_inscription
  it "peut détruire son inscription" do
    # *** Vérifications préliminaires ***
    expect(File).to be_exists(visitor.folder), "Le dossier du concurrent devrait exister avec ses documents."

    goto("concours/espace_concurrent")
    expect(page).to have_css("form#destroy-form")
    within("form#destroy-form") do
      fill_in("c_numero", with: visitor.id)
      click_on(UI_TEXTS[:concours_button_destroy])
    end
    screenshot("destroy-inscription")

    # *** Vérifications ***
    nb = db_count(DBTBL_CONCURS_PER_CONCOURS, {concurrent_id: visitor.id})
    expect(nb).to eq(0),
      "Il ne devrait plus y avoir de participations du concurrent dans '#{DBTBL_CONCURS_PER_CONCOURS}'…"
    d = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE concurrent_id = ?", [visitor.id])
    expect(d).to be_empty
    expect(File).not_to be_exists(visitor.folder), "Le dossier du concurrent ne devrait plus exister."

    goto("concours/accueil")
    click_on(btn_login_name)
    expect(page).to have_titre("Identification au concours") # juste pour être sûr
    within("form#concours-login-form") do
      fill_in("p_mail", with: visitor.mail)
      fill_in("p_concurrent_id", with:visitor.id)
      click_on(UI_TEXTS[:concours_bouton_sidentifier])
    end
    expect(page).to have_titre("Identification au concours") # juste pour être sûr
    expect(page).to have_error("Désolé, je ne vous remets pas")
  end

  @visitor = nil # pour forcer sa réinitialisation
end #/ peut_detruire_son_inscription
