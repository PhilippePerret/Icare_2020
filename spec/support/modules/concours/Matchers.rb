# encoding: UTF-8
# frozen_string_literal: true
=begin
  Matchers pour le concours
=end
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
