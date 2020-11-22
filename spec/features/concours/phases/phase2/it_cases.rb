# encoding: UTF-8
# frozen_string_literal: true

def trouve_une_home_page_concours_conforme
  goto("concours")
  expect(page).to have_content("Les 13 synopsis sont en cours de préselection.")
  expect(page).to have_titre "Concours de synopsis de l’atelier Icare"
  expect(page).to have_content("Rendez-vous aux alentours du 15 avril #{annee} pour les résultats de la première sélection !")
  expect(page).to have_link("Inscription au prochain concours")
  expect(page).to have_content("il s'agissait d'écrire le SYNOPSIS")
  expect(page).to have_link("Règlement du concours")
end #/ trouve_une_home_page_concours_conforme
