# encoding: UTF-8
# frozen_string_literal: true

def peut_detruire_son_inscription
  it "peut détruire son inscription" do
    if visitor.is_a?(TUser)
      # Cas particulier où le visiteur est un icarien
      # Je pense qu'il faut transformer le 'visitor' ici par un vrai
      # TConcurrent car sinon les propriétés '.folder', '.id' etc.
      # seront fausses.
      testedvisitor = visitor.as_concurrent
    else
      testedvisitor = visitor
    end
    # *** Vérifications préliminaires ***
    if not File.exists?(testedvisitor.folder)
      mkdir(testedvisitor.folder)
    end
    expect(File).to be_exists(testedvisitor.folder), "Le dossier du concurrent devrait exister avec ses documents."

    goto("concours/espace_concurrent")
    expect(page).to have_css("form#destroy-form")
    within("form#destroy-form") do
      fill_in("c_numero", with: testedvisitor.id)
      click_on(UI_TEXTS[:concours_button_destroy])
    end
    screenshot("destroy-inscription")

    # *** Vérifications ***
    nb = db_count(DBTBL_CONCURS_PER_CONCOURS, {concurrent_id: testedvisitor.id})
    expect(nb).to eq(0),
      "Il ne devrait plus y avoir de participations du concurrent dans '#{DBTBL_CONCURS_PER_CONCOURS}'…"
    d = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE concurrent_id = ?", [testedvisitor.id])
    expect(d).to be_empty
    expect(File).not_to be_exists(testedvisitor.folder), "Le dossier du concurrent ne devrait plus exister."

    goto("concours/accueil")
    # Étonnament (ou pas), ci-dessous, le lien s'appelle "Identifiez-vous" même
    # lorsque la phase du concours est à 1.
    # btn_login_name = TConcours.current.phase < 2 ? "vous identifier" : "Identifiez-vous"
    btn_login_name = "Identifiez-vous"
    click_on(btn_login_name)
    expect(page).to have_titre("Identification au concours") # juste pour être sûr
    within("form#concours-login-form") do
      fill_in("p_mail", with: testedvisitor.mail)
      fill_in("p_concurrent_id", with:testedvisitor.id)
      click_on(UI_TEXTS[:concours_bouton_sidentifier])
    end
    expect(page).to have_titre("Identification au concours") # juste pour être sûr
    expect(page).to have_error("Désolé, je ne vous remets pas")
  end

  @visitor = nil # pour forcer sa réinitialisation
end #/ peut_detruire_son_inscription
