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

    scenario 'peut modifier son évaluation', only:true do

      pitch("Un membre du jury peut rejoindre le concours, passer à l'évaluation d'une fiche en modifiant son évaluation précédente.")
      headless(false)
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
        # --------------------
        # Pour se faire, on va augmenter toutes les valeurs de 2, et lorsqu'elle
        # dépasseront 5 on les passera en dessous
        # ATTENTION : il faut d'abord attendre que les valeurs aient été
        # affectée. En 3 secondes, ça devrait être suffisant
        sleep 3
        fiche_evaluation.each do |key, value|
          new_value = value + 2
          new_value = new_value - 5 if new_value > 5
          # find("select[name=\"#{key}\"]").click
          select(CONCOURS_EVALUATION_VAL2TIT[new_value], from: key) rescue nil
        end
      end
      within("div#row-buttons") do
        click_on("Enregistrer")
      end
      sleep 5 # le temps d'enregistrer

      old_fiche_evaluation = fiche_evaluation.dup
      new_fiche_evaluation = YAML.load_file(member.path_fiche_evaluation(concurrent))
      # puts "old_fiche_evaluation: #{old_fiche_evaluation}"
      # puts "new_fiche_evaluation: #{new_fiche_evaluation}"


      # L'évaluation doit avoir été modifiée
      # Comme certaines questions ont pu être passées pour erreur, on compte
      # grossièrement. Il faut qu'au moins 3 quarts des corrections soient
      # bonnes
      bonnes = 0
      old_fiche_evaluation.each do |key, old_value|
        new_expected = old_value + 2
        new_expected = new_expected - 5 if new_expected > 5
        bonnes += 1 if new_expected == new_fiche_evaluation[key]
      end
      troisquart = ((old_fiche_evaluation.count.to_f / 4) * 3).to_i
      expect(bonnes).to be > troisquart,
        "Au moins trois quart des nouvelles réponses devraient correspondre… (seulement #{bonnes} sur #{troisquart} correspondent)."

      pitch("La nouvelle note est remontée par le programme et affichée dans le message de confirmation.")
      expect(page).to have_message("Nouveau score enregistré. La nouvelle note est 12.3 (14.5 pour l'ensemble des évaluations)")
      # On mémorise cette note affichée pour la retrouver dans la liste des
      note_evaluator = page.find("#message-note_evaluator").text
      note_generale  = page.find("#message-note_generale").text
      expect(page).to have_css("span#note_evaluator", text: note_evaluator)
      expect(page).to have_css("span#note_generale",  text: note_generale)

      pitch("Le membre du jury, grâce à un lien évident, retourne à la liste des synopsis pour voir la nouvelle note affichée")
      expect(page).to have_link("Fiches des synopsis")
      member.click_on("Fiches des synopsis")
      expect(page).to be_page_evaluation

      # La note doit avoir été recalculée et rectifiée
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
