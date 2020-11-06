# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test du passage à la phase 1 du concours (donc la phase de lancement)
=end
feature "Phase 1 du concours" do
  before(:all) do
    degel('concours-phase-0')
  end
  before(:each) do
    # Il faut avoir un concours courant en phase 0 (pour le premier c'est
    # inutile, mais c'est pour ceux ensuite)
    TConcours.current.set_phase(0)
    TConcours.current.reset
    expect(TConcours.current.phase).to eq(0)
  end
  context 'Un administrateur' do

    scenario 'peut lancer la phase 1 du concours en se rendant à l’administration' do

      # *** Vérifications préliminaires
      expect(TConcours.current.phase).to eq 0
      goto("concours/accueil")
      expect(page).to have_content("Le prochain concours de synopsis de l'atelier Icare n'est pas encore lancé.")

      # *** Pré-opérations ***
      TMails.remove_all
      phil.rejoint_le_site
      goto("concours/admin")
      expect(page).to have_titre "Administration du concours"
      expect(page).to have_css("form#concours-phase-form")
      within("form#concours-phase-form"){expect(page).to have_content("En attente")}
      expect(page).to have_select("current_phase", selected:"En attente")
      expect(page).not_to have_select("current_phase", selected:"Lancer et annoncer le concours")

      # *** On procède à l'opération ***
      within("form#concours-phase-form") do
        select("Lancer et annoncer le concours", from:"current_phase")
        click_on("Simuler pour procéder à cette étape…")
      end
      screenshot("admin-passe-phase-1")

      # *** On vérifie grossièrement la page ***
      expect(page).to have_css("div.etape-titre", text:"ÉTAPE 1. Lancer et annoncer le concours")
      btn_proceder = "Procéder aux opérations cochées"
      expect(page).to have_button(btn_proceder)
      # Le menu a changé
      expect(page).not_to have_select("current_phase", selected:"En attente")
      expect(page).to have_select("current_phase", selected:"Concours lancé et annoncé")

      # *** On procède vraiment au changement ***
      start_time = Time.now.to_i.freeze
      phil.click_on(btn_proceder)

      # *** On vérifie que le concours soit bien passé en phase 1
      # Le concours dans la base possède la phase 1
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 1

      # La page d'accueil du concours présente le concours
      goto("concours/accueil")
      expect(page).not_to have_content("Le prochain concours de synopsis de l'atelier Icare n'est pas encore lancé.")
      expect(page).to have_content("Le concours est ouvert !")
      # Les anciens concurrents ont reçu un mail d'annonce.
      dcs = db_exec("SELECT mail, patronyme FROM concours_concurrents")
      dcs.each do |dc|
        expect(TMails).to have_mail(to: dc[:mail], subject:"Lancement du Concours de Synopsis de l'atelier Icare", after: start_time),
          "#{dc[:patronyme]} (#{dc[:mail]}) aurait dû recevoir un mail lui annonçant le démarrage du concours"
      end
      TUser.contactables.each do |tuser|
        expect(tuser).to have_mail(subject:"Lancement du Concours de Synopsis de l'atelier", after: start_time),
          "#{tuser.pseudo} (icarien) aurait dû recevoir un mail lui annonçant le démarrage du concours."
      end


      phil.se_deconnecte


      # *** On s'assure que les pages principales affichent l'annonce ***
      # Une actualité a été produite
      expect(TActualites).to have_actualite(type:"CONCSTART", message:"LANCEMENT DE LA SESSION #{ANNEE_CONCOURS_COURANTE} DU CONCOURS DE SYNOPSIS.")
      # Les pages principales affichent un lien vers le concours
      ["home", "plan", "user/login", "user/signup"].each do |route|
        goto(route)
        expect(page).to have_link("Concours #{ANNEE_CONCOURS_COURANTE}")
      end

      # *** On poursuit la vérification avec un ancien concurrent qui vient
      # *** s'inscrire
      conc = TConcurrent.get_random(not_inscrit:true)
      goto("concours/accueil")
      click_on("vous identifier")
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc.mail)
        fill_in("p_concurrent_id", with: conc.id)
        click_on("S’identifier")
      end
      # La page doit présenter un bouton pour s'inscrire
      expect(page).to have_link("Vous inscrire à la session #{ANNEE_CONCOURS_COURANTE} du concours")
    end

    scenario 'peut lancer la phase 1 du concours par route directe' do
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 0
      phil.rejoint_le_site
      goto("concours/admin?op=change_phase&current_phase=1")
      phil.se_deconnecte
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 1
    end
  end #/contexte un administrateur

  context 'Un non administrateur' do
    scenario 'ne peut pas lancer la phase 1 du concours en se rendant à l’administration' do
      goto("concours/admin")
      expect(page).not_to have_titre "Administration du concours"
    end
    scenario 'ne peut pas lancer la phase 1 par route directe' do
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 0
      goto("concours/admin?op=change_phase&current_phase=1")
      TConcours.current.reset
      expect(TConcours.current.phase).not_to eq 1
      expect(TConcours.current.phase).to eq 0
    end
  end
end
