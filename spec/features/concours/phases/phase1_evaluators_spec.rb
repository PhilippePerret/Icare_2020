# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'
=begin
  Tests des évaluateurs en phase 1

  En phase 1, c'est-à-dire quand le concours est ouvert et que les
  concurrents peuvent s'inscrire, un évaluateur peut déjà consulter et
  évaluer un synopsis qui aurait déjà été déposé.

=end
feature "Possibilité d'un évaluateur en phase 1" do
  before(:all) do
    # headless()
    degel('concours-phase-1')
    @member = TEvaluator.get_random
  end
  let(:member) { @member }
  let(:annee) { ANNEE_CONCOURS_COURANTE }
  context 'un vrai évaluateur' do
    scenario 'peut s’identifier sur le site et voir les concurrents et les synopsis' do
      goto("concours/evaluation")

      # *** Vérifications préliminaires ***
      expect(page).to have_css("form#concours-membre-login")
      expect(page).not_to have_css("div.usefull-links")

      # *** LOGIN ***
      within("form#concours-membre-login") do
        fill_in("member_mail", with: member.mail)
        fill_in("member_password", with: member.password)
        click_on("M’identifier")
      end
      screenshot("after-login-member")
      expect(page).to be_cartes_synopsis
      expect(page).to have_css("form#goto-evaluate-synopsis-form"),
        "La page devrait présenter un formulaire permettant de se rendre à la fiche d'évaluation du fichier."

      expect(page).to have_css("div.usefull-links"),
        "La page devrait afficher des boutons de classement des fiches"

      # Les boutons que le membre du jury doit toujours trouver
      expect(page).to have_css("div.top-buttons")
      within("div.top-buttons") do
        expect(page).to have_link("Notes >", href: "concours/evaluation?view=&ks=note&ss=desc")
        expect(page).to have_link("Notes <", href: "concours/evaluation?view=&ks=note&ss=asc")
      end
      # Il possède une fiche conforme pour chaque synopsis reçu
      TConcurrent.find(avec_fichier_conforme: true).each_with_index do |conc, idx|
        syno_id = "#{conc.id}-#{annee}"
        fiche_id = "synopsis-#{syno_id}"
        expect(page).to have_css("div.synopsis", id: fiche_id)
        # Comme il n'est pas administrateur, il ne peut pas trouver le bouton pour
        # éditer la fiche
        within("div.synopsis##{fiche_id}") do
          expect(page).not_to have_link("Éditer"),
            "#{member} ne devrait pas avoir de bouton 'Éditer' sur la fiche pour éditer la fiche du synosis"
          expect(page).to have_link('Télécharger', href:"concours/evaluation?synoid=#{syno_id}&op=download"),
            "#{member} devrait avoir un bouton 'Télécharger' sur la fiche pour télécharger le fichier"
          expect(page).to have_button('Évaluer'),
            "#{member} devrait avoir un bouton 'Évaluer' sur la fiche pour l'évaluer"
        end

        case idx
        when 0
          # Le bouton Télécharger permet au membre du jury de télécharger
          # le texte.
          pending "On vérifie le téléchargement du fichier"
        when 1
          # Le bouton Évaluer permet au membre du jury d'évaluer le synopsis
          pending("on vérifie juste l'ouverture de la fenêtre")
        end
      end
    end

    scenario 'peut télécharger un fichier de candidature', only:true do
      member.rejoint_le_concours
      expect(page).to be_cartes_synopsis
      concurrent = TConcurrent.find(avec_fichier_conforme: true, count:1).first
      syno_id = "#{concurrent.id}-#{annee}"
      div_syno_id = "synopsis-#{syno_id}"
      within("div##{div_syno_id}") do
        click_on("Télécharger")
      end
      # sleep 30
      expect(page).to have_titre "Télécharger le fichier de candidature"
      expect(page).to have_link("TÉLÉCHARGER")
      click_on("TÉLÉCHARGER")
      sleep 2
      # Le fichier doit avoir été enregistré (note : le profile Firefox
      # utilisé, 'Testeur', demande à l'enregistrer tout de suite)
      syno_path = File.join(Dir.home,"Downloads","#{syno_id}.pdf")
      expect(File).to be_exists(syno_path)
      File.delete(syno_path)

    end

    scenario 'peut évaluer un fichier de candidature par la fiche', only:true do
      member.rejoint_le_concours
      expect(page).to be_cartes_synopsis
      concurrent = TConcurrent.find(avec_fichier_conforme: true).shuffle.shuffle.first
      syno_id = "#{concurrent.id}-#{annee}"
      div_syno_id = "synopsis-#{syno_id}"
      within("div##{div_syno_id}") do
        click_on("Évaluer")
      end
      expect(page).to have_titre "Évaluer le projet"
      pending("On vérifie que la page soit conforme")

    end

    scenario 'peut évaluer un fichier de candidature par le mini-champ', only:true do
      within("form#goto-evaluate-synopsis-form") do

      end
    end

  end
end
