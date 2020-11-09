# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'
=begin
  Tests des évaluateurs en phase 1

  En phase 1, c'est-à-dire quand le concours est ouvert et que les
  concurrents peuvent s'inscrire, un évaluateur peut déjà consulter et
  évaluer un synopsis qui aurait déjà été déposé.
=end
require 'yaml'
require 'json'

feature "ÉVALUATEUR EN PHASE 1 DU CONCOURS" do
  before(:all) do
    # headless()
    degel('concours-phase-1')
    require './_lib/_pages_/concours/evaluation/lib/constants'
    DATA_QUESTIONS = YAML.load_file('./_lib/_pages_/concours/evaluation/data/data_evaluation.yaml')
    # puts "DATA_QUESTIONS: #{DATA_QUESTIONS}"
    @concurrent = TConcurrent.find(avec_fichier_conforme: true).shuffle.shuffle.first
    @member = TEvaluator.get_random(fiche_evaluation: @concurrent)
  end
  let(:member) { @member }
  let(:fiche_evaluation) { @fiche_evaluation ||= member.fiche_evaluation(concurrent) }
  let(:concurrent) { @concurrent }
  let(:synopsis_id) { @synopsis_id = "#{concurrent.id}-#{annee}" }
  let(:annee) { ANNEE_CONCOURS_COURANTE }
  context 'un vrai évaluateur' do
    scenario 'peut évaluer un fichier de candidature par la fiche' do

      pitch("Un membre du jury peut rejoindre le concours, passer à l'évaluation d'une fiche en trouvant son évaluation précédente correctement affichée.")
      headless
      member.rejoint_le_concours
      expect(page).to be_cartes_synopsis
      syno_id = "#{concurrent.id}-#{annee}"
      div_syno_id = "synopsis-#{syno_id}"
      within("div##{div_syno_id}") do
        click_on("Évaluer")
      end
      expect(page).to be_checklist_page_for(synopsis_id)
      # puts "fiche_evaluation: #{fiche_evaluation.inspect}"
      within("form#checklist-form") do
        fiche_evaluation.each do |key, value|
          expect(page).to have_select(key, selected: CONCOURS_EVALUATION_VAL2TIT[value]),
            "Le menu #{key} est mal réglé. Il devrait être sur #{CONCOURS_EVALUATION_VAL2TIT[value]}."
        end
      end
    end

    pending 'peut modifier son évaluation', only:true do

      pitch("Un membre du jury peut rejoindre le concours, passer à l'évaluation d'une fiche en modifiant son évaluation précédente.")
      headless
      member.rejoint_le_concours
      expect(page).to be_cartes_synopsis
      syno_id = "#{concurrent.id}-#{annee}"
      div_syno_id = "synopsis-#{syno_id}"
      within("div##{div_syno_id}") do
        click_on("Évaluer")
      end
      expect(page).to be_checklist_page_for(synopsis_id)
      # puts "fiche_evaluation: #{fiche_evaluation.inspect}"
      # fiche_evaluation contient sa fiche actuelle, qui existe toujours
      within("form#checklist-form") do
        # Modifier des valeurs
        # TODO
        click_on("Enregistrer")
      end

      # L'évaluation doit avoir été modifiée
      # TODO
      # La note doit avoir été recalculée
      # TODO
      # La note générale du synopsis doit avoir changé
      # TODO
      # Je dois être averti de cette modification (les autres membres aussi ?
      # ou faire plutôt une information quotidienne ?)
      # TODO
    end

    pending 'peut créer une nouvelle évaluation' do

    end

    scenario 'peut évaluer un fichier de candidature par le mini-champ' do
      member.rejoint_le_concours
      goto("concours/evaluation")
      within("form#goto-evaluate-synopsis-form") do
        fill_in("synoid", with: synopsis_id)
        click_on("Évaluer")
      end
      expect(page).to be_checklist_page_for(synopsis_id)
    end

  end
end
