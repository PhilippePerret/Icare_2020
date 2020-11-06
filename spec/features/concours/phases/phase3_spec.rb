# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test du passage à la phase 3 du concours (donc la phase de lancement)
=end

feature "Phase 3 du concours" do

  BTN_VOIR_PALMARES = "Voir le palmarès actuel"

  # Retourne le nombre de fichiers candidature conformes
  def nombre_fichiers_candidature
    TConcurrent.all_current.select{|c|c.specs[1]=="1"}.count
  end #/ nombre_fichiers_candidature

  before(:all) do

    require './_lib/_pages_/concours/admin/lib/PHASES_DATA'
    expect(defined?(Concours::PHASES_DATA)).not_to be_nil
    PHASES_DATA = Concours::PHASES_DATA

    degel('concours-phase-3')
    # On fait deux concurrents dont un avec un fichier conforme et l'autre
    # sans fichier
    @conc_preselected      = TConcurrent.get_random(preselected: true)
    puts "\n\n@conc_preselected: #{@conc_preselected.inspect}" if VERBOSE
    expect(@conc_preselected).not_to eq(nil)
    @conc_non_selected  = TConcurrent.get_random(preselected: false)
    puts "\n\n@conc_non_selected: #{@conc_non_selected.inspect}" if VERBOSE
    expect(@conc_non_selected).not_to eq(nil)
    @conc_sans_fichier  = TConcurrent.get_random(avec_fichier_conforme: false)
    puts "\n\n@conc_sans_fichier: #{@conc_sans_fichier.inspect}" if VERBOSE
    expect(@conc_sans_fichier).not_to eq(nil)
    # On compte le nombre de synopsis pour cette session
    @nombre_synopsis = nombre_fichiers_candidature.freeze
  end

  before(:each) do
    # Il faut avoir un concours courant en phase 2
    TConcours.current.set_phase(2)
    TConcours.current.reset
  end

  let(:conc_non_selected) { @conc_non_selected }
  let(:conc_preselected) { @conc_preselected }
  let(:conc_sans_fichier) { @conc_sans_fichier }

  context 'Un administrateur' do

    scenario 'peut lancer la phase 3 du concours en se rendant à l’administration' do

      # Pour simplifier et pouvoir sauter d'une phase à l'autre
      numero_phase = 3
      ancien_titre_accueil  = "Les #{@nombre_synopsis} synopsis sont en cours de préselection"
      nouveau_titre_accueil = "Les 10 synopsis sélectionnés\nsont en finale"
      item_menu_old_phase = PHASES_DATA[numero_phase - 1][:name_current]
      item_menu_new_phase = PHASES_DATA[numero_phase][:name] # p.e. "Annoncer fin de pré-sélection"
      # titre_nouvelle_phase = "Seconde sélection en cours" # correspond à
      titre_new_phase = PHASES_DATA[numero_phase][:name_current]

      # *** Vérifications préliminaires
      expect(TConcours.current.phase).to eq 2
      goto("concours/accueil")
      expect(page).to have_content(ancien_titre_accueil)

      # *** Pré-opérations ***

      TMails.remove_all
      phil.rejoint_le_site
      goto("concours/admin")
      expect(page).to have_titre "Administration du concours"
      expect(page).to have_css("form#concours-phase-form")
      within("form#concours-phase-form"){expect(page).to have_content(item_menu_old_phase)}
      expect(page).to have_select("current_phase", selected:item_menu_old_phase)
      expect(page).not_to have_select("current_phase", selected:item_menu_new_phase)

      # *** On procède à l'opération de changement de phase ***

      within("form#concours-phase-form") do
        select(item_menu_new_phase, from:"current_phase")
        click_on("Simuler pour procéder à cette étape…")
      end
      screenshot("admin-passe-phase-3")

      # *** On vérifie grossièrement la page ***

      expect(page).to have_css("div.etape-titre", text:"ÉTAPE #{numero_phase}. #{item_menu_new_phase}")
      btn_proceder = "Procéder aux opérations cochées"
      expect(page).to have_button(btn_proceder)
      # Le menu a changé
      expect(page).not_to have_select("current_phase", selected:item_menu_old_phase)
      expect(page).to have_select("current_phase", selected:titre_new_phase)

      # *** On procède vraiment au changement ***

      start_time = (Time.now.to_i - 1).freeze
      phil.click_on(btn_proceder)

      # *** On vérifie que le concours soit bien passé à la nouvelle phase
      # Le concours dans la base possède la bonne phase
      TConcours.current.reset
      expect(TConcours.current.phase).to eq numero_phase


      # *** Test de la page de résultats ***
      # TODO La remettre plus bas quand elle sera testée
      goto("concours/palmares")
      screenshot("palmares-phase-3")
      expect(page).to be_palmares
      expect(page).to have_css('h2', text: "Synopsis présélectionnés")
      expect(page).to have_css('h2', text: "Synopsis non présélectionnés")
      # Tous les concurrents avec un fichier doivent voir leur fiche
      TConcurrent.all_current.each do |conc|
        if conc.fichier_conforme?
          expect(page).to have_css("div.fiche-lecture", id:"fiche-lecture-#{conc.id}"),
            "Le concurrent #{conc.pseudo} (#{conc.id}) devrait avoir sa fiche dans le palmarès…"
        else
          expect(page).not_to have_css("div.fiche-lecture", id:"fiche-lecture-#{conc.id}"),
            "Le concurrent #{conc.pseudo} (#{conc.id}) ne devrait pas avoir sa fiche dans le palmarès…"
        end
      end

      # La page d'accueil du concours présente le concours
      goto("concours/accueil")
      expect(page).not_to have_content(ancien_titre_accueil)
      expect(page).to have_content(nouveau_titre_accueil)
      # Les concurrents courants ont reçu un mail d'annonce.
      TConcurrent.all_current.each do |conc|
        # puts "\n\nCONCURRENT ÉTUDIÉ : #{conc.inspect}"
        # puts "conc.fichier_conforme?: #{conc.fichier_conforme?.inspect}"
        # puts "conc.preselected?: #{conc.preselected?.inspect}"
        # Faire une différence entre les concurrents présélectionnés et
        # les autres
        # de candidature et un autre
        msg = if not(conc.fichier_conforme?)
                "été envoyé à temps ou jugé conforme"
              elsif conc.preselected?
                "présélectionné pour la Finale du Concours de Synopsis"
              else
                "ne fait malheureusement pas partie de la présélection"
              end
        # Le bon mail doit avoir été reçu
        expect(TMails).to have_mail(to: conc.mail, message: msg, subject:"[CONCOURS #{ANNEE_CONCOURS_COURANTE}] Fin des présélections", after: start_time),
          "#{conc.patronyme} (#{conc.mail}) aurait dû recevoir un mail lui annonçant la fin des présélections avec le bon message"
      end

      phil.se_deconnecte

      # Les membres du juru
      TConcours.jury.each do |jure|
        msg = case jure[:jury]
        when 1 then "Nous tenons à vous remercier chaleureusement pour votre investissement"
        when 2 then "le moment pour vous d'entrer en scène"
        when 3 then "En tant que membre des deux jurys"
        end
        expect(TMails).to have_mail(to:jure[:mail], subject:"[CONCOURS #{ANNEE_CONCOURS_COURANTE}] Fin des présélections", message:msg, after: start_time)
      end


      # *** On s'assure que les pages principales affichent l'annonce ***
      # Les pages principales affichent toujours un lien vers le concours
      ["home", "plan", "user/login", "user/signup"].each do |route|
        goto(route)
        expect(page).to have_link("Concours #{ANNEE_CONCOURS_COURANTE}")
      end
      # Une actualité a été produite
      # La page home affiche bien l'actualité correspondant à la phase
      actu_msg = "Fin de la présélection de la session #{ANNEE_CONCOURS_COURANTE} du Concours de Synopsis."
      expect(TActualites).to have_actualite(type:"CONCPRESEL", message:actu_msg)
      goto("home")
      expect(page).to have_content(actu_msg)

      # *** On poursuit la vérification avec un concurrent qui visite
      # *** l'accueil
      # puts "conc_preselected specs : #{conc_preselected.specs}"
      goto("concours/accueil")
      screenshot("concours-accueil-phase-3")
      expect(page).to have_content(nouveau_titre_accueil)
      expect(page).to have_link(BTN_VOIR_PALMARES, href: "concours/palmares")

      click_on("Identifiez-vous")
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc_preselected.mail)
        fill_in("p_concurrent_id", with: conc_preselected.id)
        click_on("S’identifier")
      end

      # *** L'espace personnel du concours ***
      # Les informations générales
      expect(page).to have_content("Les 10 synopsis présélectionnés sont en phase finale.")
      expect(page).not_to have_content("Nombre de synopsis en lice")
      expect(page).not_to have_css("span#nombre-concurrents", text: @nombre_synopsis)
      expect(page).to have_css("span.concours-phase", text: "Sélection finale")
      # La page doit présenter le bon message personnel
      expect(page).to have_content("Votre synopsis est en lice pour la sélection finale de la session #{ANNEE_CONCOURS_COURANTE}")

      conc_preselected.se_deconnecte


      # puts "conc_non_selected specs : #{conc_non_selected.specs}"
      goto("concours/accueil")
      click_on("Identifiez-vous")
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc_non_selected.mail)
        fill_in("p_concurrent_id", with: conc_non_selected.id)
        click_on("S’identifier")
      end
      screenshot("non-selected-apres-login")
      # La page doit présenter
      # puts "conc_non_selected.specs: #{conc_non_selected.specs.inspect}"
      expect(page).to have_content("Votre projet n'a pas été sélectionné. Vous n'êtes pas en lice pour la sélection finale de la session #{ANNEE_CONCOURS_COURANTE}")

      pitch("Le concurrent non présélectionné se rend sur la page des palmarès et trouve son synopsis en exergue.")
      conc_non_selected.click_on(BTN_VOIR_PALMARES)
      screenshot("non-selected-sur-palmares")
      expect(page).to be_palmares
      expect(page).to have_css("h2", text:"Synopsis présélectionnés")
      expect(page).to have_css("h2", text:"Synopsis non présélectionnés")
      expect(page).to have_css("div.fiche-lecture.current", id:"fiche-lecture-#{conc_non_selected.id}")
      expect(page).to have_css("div#fiche-lecture-#{conc_non_selected.id} div.position", text: '12')
      conc_non_selected.se_deconnecte


      goto("concours/accueil")
      click_on("Identifiez-vous")
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc_sans_fichier.mail)
        fill_in("p_concurrent_id", with: conc_sans_fichier.id)
        click_on("S’identifier")
      end
      # La page doit présenter
      expect(page).to have_content("Sans fichier envoyé ou conforme, vous ne pouvez pas être en lice pour la sélection finale de la session #{ANNEE_CONCOURS_COURANTE}")
      # Le palmarès ne doit pas présenter son synopsis
      goto("concours/palmares")
      expect(page).to be_palmares
      expect(page).not_to have_css("div.fiche-lecture", id:"fiche-lecture-#{conc_sans_fichier.id}")
    end





    scenario 'peut lancer la phase 3 du concours par route directe' do
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 2
      phil.rejoint_le_site
      goto("concours/admin?op=change_phase&current_phase=3")
      phil.se_deconnecte
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 3
    end

  end #/contexte un administrateur

  context 'Un non administrateur' do
    scenario 'ne peut pas lancer la phase 3 du concours en se rendant à l’administration' do
      goto("concours/admin")
      expect(page).not_to have_titre "Administration du concours"
    end
    scenario 'ne peut pas lancer la phase 3 par route directe' do
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 2
      goto("concours/admin?op=change_phase&current_phase=3")
      TConcours.current.reset
      expect(TConcours.current.phase).not_to eq 3
      expect(TConcours.current.phase).to eq 2
    end

    scenario 'ne peut pas rejoindre la page d’évaluation des synopsis' do
      goto("concours/evaluation")
      expect(page).not_to be_page_evaluation
      expect(page).to have_titre "Identification"
    end
  end #/ contexte : un non administrateur


  context 'Un administrateur' do
    before(:each) do
      TConcours.current.set_phase(3)
      TConcours.current.reset
    end
    scenario 'peut rejoindre la page d’évaluation' do
      phil.rejoint_le_site
      goto("concours/evaluation")
      expect(page).to be_page_evaluation
    end
    scenario 'trouve les bonnes fiches à évaluer (les 10 préssélections)', only:true do
      phil.rejoint_le_site
      # On s'assure que c'est la bonne phase
      goto("concours/admin")
      expect(page).to have_select("current_phase", selected:"Sélection finale en cours")
      goto("concours/evaluation")
      expect(page).to be_page_evaluation
      expect(page).to have_css("div#synopsis-container")
      sleep 30
      TConcurrent.all_current.each do |conc|
        if conc.preselected?
          expect(page).to have_css("div.synopsis", id: "synopsis-#{conc.id}-#{ANNEE_CONCOURS_COURANTE}"),
            "Le concurrent #{conc.ref} devrait avoir sa fiche affichée (est présélectionné)"
        else
          expect(page).not_to have_css("div.synopsis", id: "synopsis-#{conc.id}-#{ANNEE_CONCOURS_COURANTE}"),
            "Le concurrent #{conc.ref} NE devrait PAS avoir sa fiche affichée (ne fait pas partie des présélectionné)"
        end
      end
    end
  end
end
