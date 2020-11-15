# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce module doit permettre de charger des méthodes communes pour les différentes
  sortes d'utilisateur, TUser, TEvaluator, etc.
=end

module PeopleMatchersModule
  include RSpec::Matchers
  include Capybara::DSL

  # Méthode qui regarde si l'utilisateur a été redirigé vers la page
  # désignée par +where+
  # alias def redirect_to?
  def on_page?(where)
    case where
    when String # => c'est le titre de la page
      expect(page).to have_titre(where)
    when Symbol # => C'est un identifiant de page
      case where
      when :identification
        expect(page).to have_route("user/login")
        expect(page).to have_titre("Identification")
      when :concours_identification
        expect(page).to have_route("concours/identification")
        expect(page).to have_titre("Identification")
      when :jury_identification
        expect(page).to have_route("concours/evaluation", {query: 'view=login'})
        expect(page).to have_titre("Identification")
      when :accueil_jury_concours
        screenshot("accueil-jury-concours-wanted")
        expect(page).to have_route("concours/evaluation")
        expect(page).to have_titre("Accueil du jury du concours")
      when :fiches_synopsis
        screenshot("fiches-synopsis-wanted")
        expect(page).to have_route("concours/evaluation")
        expect(page).to have_titre("Fiches de lecture")
      when :fiches_lecture
        screenshot("fiches-lecture-wanted")
        expect(page).to have_route("concours/evaluation", {query: "view=fiches_lecture"})
        expect(page).to have_titre("Fiches de lecture")
      end
    end
  end #/ on_page?
  alias :redirect_to? :on_page?

end #/ module VisitorMatchersModule
