# encoding: UTF-8
# frozen_string_literal: true
=begin
  Section concours
  ----------------
  Test de la présence de toutes les pages
=end
require_relative './_required'

RSpec.shared_examples 'rejoint_le_concours' do |from_url|
  scenario "est accessible depuis la partie" do
    goto(from_url)
    expect(page).to have_link("Concours 2021")
    click_link("Concours 2021")
    expect(page).to have_titre("Concours de synopsis de l’atelier Icare")
  end
end


feature "La page d'accueil" do
  it_behaves_like "rejoint_le_concours", ""
end
feature "Le plan" do
  it_behaves_like "rejoint_le_concours", "plan"
end

feature "La section concours" do
  before(:all) do
    degel('concours-phase-1')
  end
  scenario 'est visible sur les trois premières pages visitées' do
    pitch("Quelle que soit la page, un panneau en bas à gauche de l'écran permet de rejoindre le concours.")
    implementer(__FILE__,__LINE__)
  end

  scenario "présente toutes les pages nécessaires" do
    pitch(<<-TEXT)
Un visiteur quelconque trouve les pages suivantes :
  * Accueil du concours avec les liens vers les différentes parties
    TEXT
    goto("concours/accueil")
    expect(page).to be_accueil_concours
    goto("concours/faq")
    expect(page).to be_faq_concours
    goto("concours/identification")
    expect(page).to be_identification_concours
    goto("concours/inscription")
    expect(page).to be_inscription_concours
    goto("concours/palmares")
    expect(page).to be_palmares_concours
  end
end
