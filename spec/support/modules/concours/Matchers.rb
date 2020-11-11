# encoding: UTF-8
# frozen_string_literal: true
=begin
  Matchers pour le concours
=end
RSpec::Matchers.define :be_accueil_concours do
  match do |page|
    page.has_css?("h2.page-title", text: "Concours de Synopsis de l'atelier Icare")
  end
  description do
    "C'est bien la page d'accueil du concours"
  end
  failure_message do
    "Ce n'est pas la page d'accueil du concours, ou alors elle n'est pas conforme."
  end
end

RSpec::Matchers.define :be_accueil_jury do
  match do |page|
    page.has_css?("h2.page-title", text: "Accueil des membres du jury du concours")
  end
  description do
    "C'est bien la page d'accueil du concours"
  end
  failure_message do
    "Ce n'est pas la page d'accueil du concours, ou alors elle n'est pas conforme."
  end
end

RSpec::Matchers.define :be_identification do
  match do |page|
    page.has_css?("h2.page-title", text: "Identification") &&
    page.has_css?("form#concours-login-form")
  end
  description do
    "C'est bien la page d'identification du concours"
  end
  failure_message do
    "Ce n'est pas la page d'identification du concours, ou alors elle n'est pas conforme."
  end
end

RSpec::Matchers.define :be_identification_evaluator do
  match do |page|
    page.has_css?("h2.page-title", text: "Identification") &&
    page.has_css?("form#concours-membre-login")
  end
  description do
    "C'est bien la page d'identification des membres du jury du concours"
  end
  failure_message do
    "Ce n'est pas la page d'identification des membres du jury du concours, ou alors elle n'est pas conforme."
  end
end

RSpec::Matchers.define :be_cartes_synopsis do
  match do |page|
    page.has_css?("h2.page-title", text: "Cartes des synopsis")
  end
  description do
    "C'est bien la page des cartes des synopsis"
  end
  failure_message do
    "Ce n'est pas la page des cartes des synopsis."
  end
end

RSpec::Matchers.define :be_fiches_lecture do
  match do |page|
    page.has_css?("h2.page-title", text: "Fiches de lecture")
  end
  description do
    "C'est bien la page des fiches de lecture"
  end
  failure_message do
    "Ce n'est pas la page des fiches de lecture."
  end
end

RSpec::Matchers.define :be_formulaire_synopsis do |options=nil|
  match do |page|
    raisons = []
    ok = page.has_css?("h2.page-title", text: "Édition du synopsis")
    if ok
      raisons << "C'est la page de l'édition du synopsis mais"
    else
      raisons << "Ce n'est pas la page d'édition du synopsis"
    end
    if ok && options && options[:conformite]
      ok = ok && page.has_css?('h3', text: "Signalement de non conformité")
      if not ok
        raisons << "la section de signalement de non conformité est introuvable…"
      end
      ok = ok && page.has_css?('form#non-conformite-form')
      if not ok
        raisons << "le formulaire pour signaler la non conformité est introuvable…"
      end
    end
    @raisons = raisons.join(' ')
    return ok
  end
  description do
    "C'est bien la page de l'édition du synopsis"
  end
  failure_message do
    @raisons
  end
end

RSpec::Matchers.define :be_espace_personnel do
  match do |page|
    page.has_css?("h2.page-title", text: "Espace personnel")
  end
  description do
    "C'est bien la page de l'espace personnel du concours"
  end
  failure_message do
    "Ce n'est pas la page de l'espace personnel du concours, ou alors elle n'est pas conforme."
  end
end

RSpec::Matchers.define :be_checklist_page_for do |syno_id|
  match do |page|
    # puts "page: #{page.html}"
    ok = true
    r = [] # pour mettre les raisons d'erreurs
    if not page.has_css?("h2.page-title", text: "Évaluation de #{syno_id}")
      r << "le titre devrait être “Évaluation du synopsis #{syno_id}”"
      ok = false
    end
    if not page.has_css?("div#checklist")
      r << "la page devrait contenir un div#checklist"
      ok = false
    end
    if not page.has_css?("div#checklist form#checklist-form")
      r << "la page devrait contenir le formulaire form#checklist-form"
      ok = false
    end
    if not page.has_css?("div#checklist div#row-buttons")
      r << "le formulaire devrait contenir la rangée des boutons"
      ok = false
    end
    if not page.has_css?("div#checklist div#row-buttons button", text: "Enregistrer")
      r << "le formulaire devrait contenir le bouton pour Enregistrer l'évaluation"
      ok = false
    end
    if not page.has_css?("form#checklist-form input[value=\"#{syno_id}\"]", id: "synoid", visible:false)
      r << "le formulaire devrait contenir le champ 'synoid' avec l'identifiant du synopsis évalué"
      ok = false
    end
    @raisons = r
    return ok
  end
  description do
    "C'est bien la page pour évaluer le synopsis ##{syno_id}"
  end
  failure_message do
    "Ce n'est pas la page pour évaluer le synopsis ##{syno_id} pour les raisons suivantes : #{@raisons.join(', ')}"
  end
end

RSpec::Matchers.define :be_palmares do
  match do |page|
    @titre = "Résultats du concours de synopsis"
    page.has_css?("h2.page-title", text: @titre)
  end
  description do
    "C'est bien la page du palmarès du concours"
  end
  failure_message do
    "Ce n'est pas la page du palmarès concours, elle devrait avoir le titre #{@titre}."
  end
end
