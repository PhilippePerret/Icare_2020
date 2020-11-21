# encoding: UTF-8
# frozen_string_literal: true
require_relative '../_required'

feature "Gestion de la non conformité d'un fichier de candidature" do
  before(:all) do
    headless # mode sans entête
    require './_lib/_pages_/concours/evaluation/lib/constants'
    require './_lib/data/secret/concours'
    BUTTON_NON_CONFORME = UI_TEXTS[:button_marquer_non_conforme]
    degel('concours-phase-1')
    @concurrent = TConcurrent.get_random(avec_fichier: true, conformite_definie: false)
    expect(@concurrent).not_to eq(nil)
    @member = TEvaluator.get_random
  end

  let(:annee) { ANNEE_CONCOURS_COURANTE }
  let(:concurrent) { @concurrent }
  let(:member) { @member }
  let(:synopsis) { @synopsis ||= concurrent.synopsis }
  let(:fiche_concurrent_selector) { @fiche_concurrent_selector ||=  "div#synopsis-#{synopsis.id}"}

  context 'Un administrateur' do
    scenario 'peut refuser un fichier pour non conformité' do
      # headless(false)

      pitch("Quand une concurrente avec un fichier non encore vérifié rejoint l'espace personnel, elle ne trouve plus le champ de saisie pour transmettre son fichier.")
      concurrent.rejoint_le_concours
      goto("concours/espace_concurrent")
      expect(page).to be_espace_personnel
      expect(page).not_to have_css("form#concours-fichier-form")
      expect(page).not_to have_content("Vous pouvez transmettre un nouveau fichier conforme.")

      start_time = Time.now.to_i - 1

      # *** Vérifications préliminaires ***
      expect(concurrent.specs[0]).to eq('1')
      expect(concurrent.specs[1]).to eq('0')

      pitch("Un administrateur peut venir marquer le synopsis non conforme en précisant les raisons. Le concurrent est alors averti et on l'invite à corriger son document.")
      phil.rejoint_le_site
      goto("concours/evaluation")
      expect(page).to be_fiches_synopsis
      expect(page).to have_css(fiche_concurrent_selector)
      screenshot("avec-bouton-fichier-concours-non-conforme")
      within(fiche_concurrent_selector) do
        expect(page).to have_link(BUTTON_NON_CONFORME)
        phil.click_on(BUTTON_NON_CONFORME)
      end
      screenshot("phil-on-synopsis-form-pour-non-conformite")
      expect(page).to be_formulaire_synopsis(conformite: true)

      # Liste des points de non conformité
      premier_motif_ajouted = "ceci est une raison détaillée du refus (à ne pas corriger)"
      second_motif_ajouted = "une autre raison finale (à ne pas corriger)"
      # non_conformites = [:incomplet, :titre, :bio]
      non_conformites = MOTIF_NON_CONFORMITE.keys
      motif_detailled = "#{premier_motif_ajouted}\n#{second_motif_ajouted}"
      within("form#non-conformite-form") do
        non_conformites.each do |motif|
          check("motif_#{motif}")
        end
        fill_in('motif_detailled', with: motif_detailled)
        phil.click_on(BUTTON_NON_CONFORME)
      end
      screenshot("phil-envoie-non-conformite")

      # Un message confirme la bonne manœuvre
      expect(page).to have_message("Le synopsis a été marqué non conforme. #{concurrent.pseudo} a été averti#{concurrent.fem(:e)}")

      # Le synopsis a été marqué non conforme
      concurrent.reset
      expect(concurrent.specs[0]).to eq('1')
      expect(concurrent.specs[1]).to eq('2'),
        "Le deuxième bit des specs du synopsis devrait être à 2 (non conforme) il est à #{concurrent.specs[1].inspect}"


      # La concurrent a reçu le mail avec chaque motif explicité
      bouts = [] # les bouts à trouver dans le mail
      non_conformites.each do |motif|
        dmotif = MOTIF_NON_CONFORMITE[motif]
        bouts << dmotif[:motif]
        bouts << dmotif[:precision] unless dmotif[:precision].nil?
      end
      bouts << "#{premier_motif_ajouted}," # noter la virgule
      bouts << "#{second_motif_ajouted}." # noter le point
      expect(concurrent).to have_mail(after: start_time, from:CONCOURS_MAIL, subject:"Votre fichier n'est pas conforme", message: bouts)

      goto("concours/evaluation")
      expect(page).to have_css("div#synopsis-#{synopsis.id}.not-conforme"),
        "La page devrait contenir la fiche du synopsis entourée de rouge (class not-conforme)"
      within(fiche_concurrent_selector) do
        expect(page).not_to have_link("Marquer conforme")
        expect(page).not_to have_link(BUTTON_NON_CONFORME)
      end

      phil.se_deconnecte

      pitch("Quand la concurrente revient sur l'espace personnel, elle trouve à nouveau le champ de saisie pour transmettre son fichier corrigé, avec le bon message. Elle peut transmettre son nouveau fichier, ce qui en change le statut.")
      concurrent.rejoint_le_concours
      goto("concours/espace_concurrent")
      expect(page).to have_css("form#concours-fichier-form")
      screenshot("concurrent-non-conforme-revient-espace-personnel")
      expect(page).to have_content("Vous pouvez transmettre un nouveau fichier conforme.")

      # La concurrent soumet son nouveau fichier
      syno_path = File.expand_path(File.join('.','spec','support','asset','documents','synopsis_concours.pdf'))
      within("form#concours-fichier-form") do
        fill_in("p_titre",    with: "Mon nouveau fichier conforme")
        fill_in("p_auteurs",  with: "")
        attach_file("p_fichier_candidature", syno_path)
        click_on(UI_TEXTS[:concours_bouton_send_dossier])
      end
      screenshot("after-send-fichier-conforme")

      concurrent.reset
      # puts db_exec("SELECT specs FROM concurrents_per_concours WHERE concurrent_id = ? AND annee = ?", [concurrent.id, annee]).inspect
      expect(concurrent.specs[0]).to eq('1'),
        "Le premier bit des specs devrait être 1 (il vaut #{concurrent.specs[0]})"
      expect(concurrent.specs[1]).to eq('0'),
        "Le deuxième bit des specs aurait dû être remis à 0 (il vaut #{concurrent.specs[1]})"

    end
  end

  context 'Un membre du jury' do
    scenario 'ne peut pas refuser un fichier pour non conformité' do
      member.rejoint_le_concours
      expect(page).to be_fiches_synopsis
      expect(page).to have_css(fiche_concurrent_selector)
      within(fiche_concurrent_selector) do
        expect(page).not_to have_link(BUTTON_NON_CONFORME)
      end
    end
    scenario 'ne peut pas refuser un fichier même par route directe' do
      member.rejoint_le_concours
      goto("concours/evaluation?view=synopsis_form&op=set_non_conforme&synoid=#{synopsis.id}&motif=support")
      expect(concurrent.specs[1]).not_to eq("2")
      expect(concurrent.specs[1]).to eq("0")
    end
  end
end
