# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'

feature "Gestion de la non conformité d'un fichier de candidature" do
  before(:all) do
    headless # mode sans entête
    require './_lib/_pages_/concours/evaluation/lib/constants'
    degel('concours-phase-1')
    @concurrent = TConcurrent.get_random(avec_fichier_conforme: false)
    expect(@concurrent).not_to eq(nil)
    @member = TEvaluator.get_random
  end

  let(:annee) { ANNEE_CONCOURS_COURANTE }
  let(:concurrent) { @concurrent }
  let(:member) { @member }
  let(:synopsis) { @synopsis ||= concurrent.synopsis }
  let(:fiche_concurrent_selector) { @fiche_concurrent_selector ||=  "div#synopsis-#{synopsis.id}"}

  BUTTON_NON_CONFORME = UI_TEXTS[:button_marquer_non_conforme]
  context 'Un administrateur' do
    scenario 'peut refuser un fichier pour non conformité', only:true do

      pitch("Un administrateur peut venir marquer le synopsis non conforme en précisant les raisons. Le concurrent est alors averti et on l'invite à corriger son document.")
      phil.rejoint_le_site
      goto("concours/evaluation")
      expect(page).to be_cartes_synopsis
      expect(page).to have_css(fiche_concurrent_selector)
      within(fiche_concurrent_selector) do
        expect(page).to have_link(BUTTON_NON_CONFORME)
        phil.click_on(BUTTON_NON_CONFORME)
      end
      screenshot("phil-on-synopsis-form-pour-non-conformite")
      expect(page).to be_formulaire_synopsis(conformite: true)

      within("form#non-conformite-form") do
        check('motif_incomplet')
        check('motif_titre')
        check('motif_bio')
        fill_in('motif_detailled', with: "<li>Ceci est la raison détaillée du refus</li>")
        phil.click_on(BUTTON_NON_CONFORME)
      end
      screenshot("phil-envoie-non-conformite")

      # Un message confirme la bonne manœuvre
      expect(page).to have_message("Le synopsis a été marqué non conforme. #{concurrent.pseudo} a été averti#{concurrent.fem(:e)}")

      # La concurrent a reçu le mail
      # TODO

      # Le synopsis a été marqué non conforme
      # TODO

      pitch("Quand la concurrente revient sur l'espace personnel, elle trouve à nouveau le champ de saisie pour transmettre son fichier corrigé, avec le bon message.")
      # TODO

    end
  end

  context 'Un membre du jury' do
    scenario 'ne peut pas refuser un fichier pour non conformité' do
      member.rejoint_le_concours
      expect(page).to be_cartes_synopsis
      expect(page).to have_css(fiche_concurrent_selector)
      within(fiche_concurrent_selector) do
        expect(page).not_to have_link(BUTTON_NON_CONFORME)
      end
    end
    scenario 'ne peut pas refuser un fichier même par route directe' do
      member.rejoint_le_concours
      goto("concours/evaluation?view=synopsis_form&op=set_non_conforme&synoid=#{synopsis.id}&motif=support")
      expect(synopsis.specs[1]).not_to eq(2)
    end
  end
end
