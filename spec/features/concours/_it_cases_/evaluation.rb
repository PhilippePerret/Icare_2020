# encoding: UTF-8
# frozen_string_literal: true
=begin
  Cmd R   ---> liste des méthodes
=end

def trouve_les_dix_synopsis_preselectionnes
  it 'trouve les dix cartes des synopsis présélectionnés à évaluer' do
    visitor.rejoint_le_site
    # On s'assure que c'est la bonne phase
    goto("concours/admin")
    expect(page).to have_select("current_phase", selected:"Sélection finale en cours")
    goto("concours/evaluation")
    expect(page).to be_fiches_synopsis
    expect(page).to have_css("div#synopsis-container")
    # sleep 10
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
end #/trouve_les_dix_synopsis_preselectionnes

def peut_evaluer_un_projet
  it "peut évaluer un projet" do
    goto('concours/evaluation')
    expect(page).to be_page_evaluation
    id_synopsis = first('div.synopsis')[:id].split('-')[1..2].join('-')
    id_concurrent = id_synopsis.split('-')[0]
    first('div.synopsis').click_on('Évaluer')
    expect(page).to have_titre("Évaluation de #{id_synopsis}")
    pending "à implémenter"
  end
end #/ peut_evaluer_un_projet

def ne_peut_plus_evaluer_les_projets
  it "ne peut plus evaluer les projets" do
    visit("concours/evaluation")
    expect(page).to be_page_evaluation
    id_synopsis = first('div.synopsis')[:id].split('-')[1..2].join('-')
    expect(first('div.synopsis')).not_to have_link('Évaluer')
  end
end #/ ne_peut_plus_evaluer_les_projets


def peut_evaluer_un_synopsis_par_la_fiche
  visitor.rejoint_le_concours
  expect(page).to be_fiches_synopsis
  syno_id = "#{concurrent.id}-#{annee}"
  div_syno_id = "synopsis-#{syno_id}"
  expect(page).to have_css("div##{div_syno_id}")
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
end #/ peut_evaluer_un_synopsis_par_la_fiche

def peut_modifier_son_evaluation
  visitor.rejoint_le_concours
  expect(page).to be_fiches_synopsis
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
    sleep 3 # NE PAS TOUCHER !!!
    fiche_evaluation.each do |key, value|
      new_value = value + 2
      new_value = new_value - 5 if new_value > 5
      # find("select[name=\"#{key}\"]").click
      select(CONCOURS_EVALUATION_VAL2TIT[new_value], from: key) rescue nil

      # break # pour l'essai, on en fait qu'un
    end
  end
  within("div#row-buttons") do
    click_on("Enregistrer")
  end

  screenshot("apres-save-score")
  expect(page).to have_message("Le nouveau score est enregistré.")
  # On mémorise cette note affichée pour la retrouver dans la liste des
  nouvelle_note = page.find("span#nouvelle-note").text

  # sleep 5 # le temps d'enregistrer (non puisqu'on attend sur le message ci-dessus)

  old_fiche_evaluation = fiche_evaluation.dup
  new_fiche_evaluation = YAML.load_file(visitor.path_fiche_evaluation(concurrent))

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

  pitch("Le membre du jury, grâce à un lien évident, retourne à la liste des synopsis pour voir la nouvelle note affichée")
  expect(page).to have_link("Fiches des synopsis")
  visitor.click_on("Fiches des synopsis")
  expect(page).to be_fiches_synopsis

  # La note doit avoir été recalculée et rectifiée
  expect(page).to have_css("div##{div_syno_id} span.note-evaluator", text: nouvelle_note)
end #/ peut_modifier_son_evaluation

def peut_evaluer_un_synopsis_par_le_minichamp
  visitor.rejoint_le_concours
  goto("concours/evaluation")
  within("form#goto-evaluate-synopsis-form") do
    fill_in("synoid", with: synopsis_id)
    click_on("Évaluer")
  end
  expect(page).to be_checklist_page_for(synopsis_id)
end #/ peut_evaluer_un_synopsis_par_minichamp
