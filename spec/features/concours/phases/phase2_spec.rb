# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test du passage à la phase 2 du concours (donc la phase de lancement)
=end
feature "Phase 2 du concours" do

  # Retourne le nombre de fichiers candidature conformes
  def nombre_fichiers_candidature
    TConcurrent.all_current.select do |c| c.specs[1]=="1" end.count
  end #/ nombre_fichiers_candidature

  before(:all) do
    require_support('concours')
    degel('concours-phase-2')
  end
  before(:each) do
    # Il faut avoir un concours courant en phase 0 (pour le premier c'est
    # inutile, mais c'est pour ceux ensuite)
    TConcours.current.set_phase(1)
    TConcours.current.reset
    expect(TConcours.current.phase).to eq(1)

    # On fait deux concurrents dont un avec un fichier conforme et l'autre
    # sans fichier
    @conc_avec_file = TConcurrent.get_random(avec_fichier_conforme: true)
    # puts "@conc_avec_file: #{@conc_avec_file.inspect}"
    expect(@conc_avec_file).not_to eq(nil)
    @conc_sans_file = TConcurrent.get_random(avec_fichier_conforme: false)
    # puts "@conc_sans_file: #{@conc_sans_file.inspect}"
    expect(@conc_sans_file).not_to eq(nil)

    # On compte le nombre de synopsis pour cette session
    @nombre_synopsis = nombre_fichiers_candidature.freeze
    # puts "@nombre_synopsis: #{@nombre_synopsis.inspect}"
    expect(@nombre_synopsis).to be > 1

  end

  let(:conc_sans_file) { @conc_sans_file }
  let(:conc_avec_file) { @conc_avec_file }


  context 'Un administrateur' do
    scenario 'peut lancer la phase 2 du concours en se rendant à l’administration' do

      # *** Vérifications préliminaires
      expect(TConcours.current.phase).to eq 1
      goto("concours/accueil")
      expect(page).to have_content("Le concours est ouvert !")

      # *** Pré-opérations ***
      TMails.remove_all
      phil.rejoint_le_site
      goto("concours/admin")
      expect(page).to have_titre "Administration du concours"
      expect(page).to have_css("form#concours-phase-form")
      within("form#concours-phase-form"){expect(page).to have_content("Concours lancé et annoncé")}
      expect(page).to have_select("current_phase", selected:"Concours lancé et annoncé")
      expect(page).not_to have_select("current_phase", selected:"Annoncer l'échéance des dépôts")

      # *** On procède à l'opération ***
      within("form#concours-phase-form") do
        select("Annoncer l'échéance des dépôts", from:"current_phase")
        click_on("Simuler pour procéder à cette étape…")
      end
      screenshot("admin-passe-phase-2")

      # *** On vérifie grossièrement la page ***
      expect(page).to have_css("div.etape-titre", text:"ÉTAPE 2. Annoncer l'échéance des dépôts")
      btn_proceder = "Procéder aux opérations cochées"
      expect(page).to have_button(btn_proceder)
      # Le menu a changé
      expect(page).not_to have_select("current_phase", selected:"Concours lancé et annoncé")
      expect(page).to have_select("current_phase", selected:"Première sélection en cours")

      # *** On procède vraiment au changement ***
      start_time = Time.now.to_i.freeze
      phil.click_on(btn_proceder)

      # *** On vérifie que le concours soit bien passé en phase 1
      # Le concours dans la base possède la phase 1
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 2

      # La page d'accueil du concours présente le concours
      goto("concours/accueil")
      expect(page).not_to have_content("Le concours est ouvert !")
      expect(page).to have_content("Les #{@nombre_synopsis} synopsis sont en cours de préselection")
      # Les anciens concurrents ont reçu un mail d'annonce.
      dcs = db_exec("SELECT mail, patronyme FROM concours_concurrents")
      TConcurrent.all_current.each do |conc|
        # Faire une différence entre un concurrent ayant envoyé un fichier
        # de candidature et un autre
        msg = if conc.fichier_conforme?
          "Vous avez transmis un fichier de candidature conforme"
        else
          "Vous n'avez pas transmis de fichier de candidature"
        end
        expect(TMails).to have_mail(to: conc.mail, message: msg, subject:"[CONCOURS] Fin de l’échéance des dépôts", after: start_time),
          "#{conc.patronyme} (#{conc.mail}) aurait dû recevoir un mail lui annonçant l'échéance de fin du concours (avec le bon message)"
      end

      phil.se_deconnecte


      # *** On s'assure que les pages principales affichent l'annonce ***
      # Les pages principales affichent toujours un lien vers le concours
      ["home", "plan", "user/login", "user/signup"].each do |route|
        goto(route)
        expect(page).to have_link("Concours #{ANNEE_CONCOURS_COURANTE}")
      end
      # Une actualité a été produite
      # La page home affiche bien l'actualité de fin d'échéance
      expect(TActualites).to have_actualite(type:"CONCECHE", message:"Fin d'échéance de la session #{ANNEE_CONCOURS_COURANTE} du Concours de Synopsis.")
      goto("home")
      expect(page).to have_content("La session #{ANNEE_CONCOURS_COURANTE} du Concours de Synopsis est arrivée à échéance. Préselection en cours.")

      # *** On poursuit la vérification avec un concurrent qui visite
      # *** l'accueil
      # puts "conc_avec_file specs : #{conc_avec_file.specs}"
      goto("concours/accueil")
      click_on("Identifiez-vous")
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc_avec_file.mail)
        fill_in("p_concurrent_id", with: conc_avec_file.id)
        click_on("S’identifier")
      end

      # *** L'espace personnel du concours ***
      # Les informations générales
      expect(page).to have_content("Nombre de synopsis en lice")
      expect(page).to have_css("span#nombre-concurrents", text: @nombre_synopsis)
      expect(page).to have_css("span.concours-phase", text: "Présélections")
      # La page doit présenter le bon message personnel
      expect(page).to have_content("Votre synopsis est conforme, il est en lice pour la session #{ANNEE_CONCOURS_COURANTE}")

      conc_avec_file.se_deconnecte


      # puts "conc_sans_file specs : #{conc_sans_file.specs}"
      goto("concours/accueil")
      click_on("Identifiez-vous")
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc_sans_file.mail)
        fill_in("p_concurrent_id", with: conc_sans_file.id)
        click_on("S’identifier")
      end
      # La page doit présenter
      expect(page).to have_content("Vous n'êtes pas en lice pour la session #{ANNEE_CONCOURS_COURANTE}")

      conc_sans_file.se_deconnecte

      # Des mails ont été envoyés à chaque concurrrent pour annoncer
      # la fin de l'échéance
      TConcurrent.all_current.each do |conc|
        expect(conc).to have_mail(subject: "[CONCOURS] Fin de l’échéance des dépôts", after: start_time)
      end
      # On vérifie particulièrement les deux mails des concurrents connus
      expect(conc_avec_file).to have_mail(after:start_time, message: "Vous avez transmis un fichier de candidature conforme dans les temps")
      expect(conc_sans_file).to have_mail(after:start_time, message:"Vous n'avez pas transmis de fichier de candidature conforme")

      # Des mails ont été envoyés aux jurés
      TConcurrent.jury.each do |dj|
        expect(TMails).to have_mail(to: dj[:mail], subject:"[CONCOURS] Fin de l'échéance", after: start_time)
      end

    end

    scenario 'peut lancer la phase 2 du concours par route directe' do
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 1
      phil.rejoint_le_site
      goto("concours/admin?op=change_phase&current_phase=2")
      phil.se_deconnecte
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 2
    end

  end #/contexte un administrateur

  context 'Un non administrateur' do
    scenario 'ne peut pas lancer la phase21 du concours en se rendant à l’administration' do
      goto("concours/admin")
      expect(page).not_to have_titre "Administration du concours"
    end
    scenario 'ne peut pas lancer la phase 2 par route directe' do
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 1
      goto("concours/admin?op=change_phase&current_phase=2")
      TConcours.current.reset
      expect(TConcours.current.phase).not_to eq 2
      expect(TConcours.current.phase).to eq 1
    end

    scenario 'ne peut pas évaluer les fichiers' do
      goto("concours/evaluation")
      expect(page).not_to be_page_evaluation
      expect(page).to have_titre("Identification")
    end
  end # / contexte un non administrateur




  context 'Un administrateur' do
    scenario 'peut rejoindre la section des évaluations', only:true do
      phil.rejoint_le_site
      goto("concours/evaluation")
      expect(page).not_to be_identification
      expect(page).to be_page_evaluation
      phil.se_deconnecte
    end
    scenario 'trouve toutes les fiches à évaluer (phase 2)', only:true do
      phil.rejoint_le_site
      goto("concours/evaluation")
      expect(page).to be_page_evaluation
      TConcurrent.all_current.each do |conc|
        if conc.fichier_conforme?
          expect(page).to have_css("div.synopsis", id: "synopsis-#{conc.id}-#{ANNEE_CONCOURS_COURANTE}"),
            "Le concurrent #{conc.ref} devrait avoir une fiche d'évaluation pour son synopsis"
        else
          expect(page).not_to have_css("div.synopsis", id: "synopsis-#{conc.id}-#{ANNEE_CONCOURS_COURANTE}"),
            "Le concurrent #{conc.pseudo} ne devrait pas avoir de fiche (fichier absent ou non conforme)"
        end
      end
      phil.se_deconnecte
    end
  end
end
