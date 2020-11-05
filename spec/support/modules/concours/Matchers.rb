# encoding: UTF-8
# frozen_string_literal: true
=begin
  Matchers pour le concours
=end
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

RSpec::Matchers.define :be_page_evaluation do
  match do |page|
    page.has_css?("h2.page-title", text: "Évaluation des synopsis")
  end
  description do
    "C'est bien la page d'évaluation des synopsis"
  end
  failure_message do
    "Ce n'est pas la page d'évaluation des synopsis."
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
