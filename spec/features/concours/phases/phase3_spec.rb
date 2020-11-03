# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test du passage à la phase 3 du concours (donc la phase de lancement)
=end

feature "Phase 3 du concours" do

  before(:all) do
    require './_lib/_pages_/concours/admin/lib/PHASES_DATA'
    expect(defined?(Concours::PHASES_DATA)).not_to be_nil
    PHASES_DATA = Concours::PHASES_DATA
  end

  # Retourne le nombre de fichiers candidature conformes
  def nombre_fichiers_candidature
    TConcurrent.all_current.select{|c|c.specs[1]=="1"}.count
  end #/ nombre_fichiers_candidature
  before(:all) do
    require_support('concours')
    degel('concours')
  end
  before(:each) do
    # Il faut avoir un concours courant en phase 2
    TConcours.current.set_phase(2)
    TConcours.current.reset
    # S'assurer que 4 concurrents courants aient envoyé leur synopsis
    expect(TConcurrent.all_current.count).to be > 3,
      "Il faudrait au moins 4 concurrents courants !"

    # On fait deux concurrents dont un avec un fichier conforme et l'autre
    # sans fichier
    @conc_selected      = TConcurrent.get_random(avec_fichier_conforme: true)
    @conc_selected.set_preselected
    puts "\n\n@conc_selected: #{@conc_selected.inspect}" if VERBOSE
    @conc_non_selected  = TConcurrent.get_random(avec_fichier_conforme: true, not_mail:[@conc_selected.mail])
    @conc_non_selected.set_not_preselected
    puts "\n\n@conc_non_selected: #{@conc_non_selected.inspect}" if VERBOSE
    @conc_sans_fichier  = TConcurrent.get_random(avec_fichier: false, not_mail:[@conc_selected.mail, @conc_non_selected.mail])
    puts "\n\n@conc_sans_fichier: #{@conc_sans_fichier.inspect}" if VERBOSE

    # On compte le nombre de synopsis pour cette session
    @nombre_synopsis = nombre_fichiers_candidature.freeze
    if @nombre_synopsis < 2
      TConcurrent.all_current[0..2].each do |conc|
        conc.make_fichier_conforme
      end
      @nombre_synopsis = nombre_fichiers_candidature.freeze
    end
    expect(@nombre_synopsis).to be > 1
  end

  let(:conc_non_selected) { @conc_non_selected }
  let(:conc_selected) { @conc_selected }
  let(:conc_sans_fichier) { @conc_sans_fichier }

  context 'Un administrateur' do

    scenario 'peut lancer la phase 3 du concours en se rendant à l’administration', only:true do

      # Pour simplifier et pouvoir sauter d'une phase à l'autre
      numero_phase = 3
      ancien_titre_accueil  = "Les #{@nombre_synopsis} synopsis sont en cours de préselection"
      nouveau_titre_accueil = "Les 10 synopsis sélectionnés sont en pleiniaire"
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
      expect(page).to have_titre("Résultats du concours de synopsis")
      expect(page).to have_css('h3', text: "Synopsis présélectionnés")



      # La page d'accueil du concours présente le concours
      goto("concours/accueil")
      expect(page).not_to have_content(ancien_titre_accueil)
      expect(page).to have_content(nouveau_titre_accueil)
      # Les concurrents courants ont reçu un mail d'annonce.
      TConcurrent.all_current.each do |conc|
        puts "\n\nCONCURRENT ÉTUDIÉ : #{conc.inspect}"
        puts "conc.fichier_conforme?: #{conc.fichier_conforme?.inspect}"
        puts "conc.preselected?: #{conc.preselected?.inspect}"
        # Faire une différence entre les concurrents présélectionnés et
        # les autres
        # de candidature et un autre
        msg = if not(conc.fichier_conforme?)
                puts "pas de fichier"
                "été envoyé à temps ou jugé conforme"
              elsif conc.preselected?
                puts "sélectionné"
                "présélectionné pour la Finale du Concours de Synopsis"
              else
                puts "non sélectionné"
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
      # puts "conc_selected specs : #{conc_selected.specs}"
      goto("concours/accueil")
      expect(page).to have_content("Les 10 synopsis sélectionnés sont en pleiniaire")

      click_on("Identifiez-vous")
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc_selected.mail)
        fill_in("p_concurrent_id", with: conc_selected.id)
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

      conc_selected.se_deconnecte


      # puts "conc_non_selected specs : #{conc_non_selected.specs}"
      goto("concours/accueil")
      click_on("Identifiez-vous")
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc_non_selected.mail)
        fill_in("p_concurrent_id", with: conc_non_selected.id)
        click_on("S’identifier")
      end
      # La page doit présenter
      expect(page).to have_content("Votre projet n'a pas été sélectionné. Vous n'êtes pas en lice pour la sélection finale de la session #{ANNEE_CONCOURS_COURANTE}")

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
  end
end
